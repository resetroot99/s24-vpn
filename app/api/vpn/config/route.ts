import { NextRequest, NextResponse } from 'next/server';
import { getUserByLicense } from '@/lib/users-supabase';
import { getWireGuardConfig, getOpenVPNConfig, listServers } from '@/lib/vpn-api';

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const licenseKey = searchParams.get('license');
    const protocol = searchParams.get('protocol') || 'wireguard';
    const serverId = searchParams.get('server');
    const platform = searchParams.get('platform') || 'desktop';

    // Validate license key
    if (!licenseKey) {
      return NextResponse.json(
        { error: 'License key is required' },
        { status: 400 }
      );
    }

    // Get user
    const user = await getUserByLicense(licenseKey);
    if (!user) {
      return NextResponse.json(
        { error: 'Invalid license key' },
        { status: 404 }
      );
    }

    // Check if user has VPN account
    if (!user.vpnAccountId) {
      return NextResponse.json(
        { error: 'VPN account not provisioned. Please contact support.' },
        { status: 400 }
      );
    }

    // Get server list
    const servers = await listServers();
    if (servers.length === 0) {
      return NextResponse.json(
        { error: 'No VPN servers available' },
        { status: 503 }
      );
    }

    // Select server
    const selectedServer = serverId 
      ? servers.find(s => s.id === serverId) || servers[0]
      : servers[0];

    console.log('[Config] Generating config:', {
      user: user.email,
      protocol,
      server: selectedServer.name,
      platform,
    });

    // Generate configuration
    let configData;
    let filename;
    
    if (protocol === 'wireguard') {
      configData = await getWireGuardConfig(user.vpnAccountId, selectedServer.id);
      filename = `s24-vpn-${platform}-${selectedServer.city}-wireguard.conf`;
      
      // Add iOS mobileconfig wrapper if needed
      if (platform === 'ios') {
        const mobileconfig = generateIOSMobileConfig(
          configData.file_body,
          selectedServer.name
        );
        
        return new NextResponse(mobileconfig, {
          headers: {
            'Content-Type': 'application/x-apple-aspen-config',
            'Content-Disposition': `attachment; filename="s24-vpn-${selectedServer.city}.mobileconfig"`,
          },
        });
      }
      
    } else if (protocol === 'openvpn') {
      configData = await getOpenVPNConfig(selectedServer.id);
      filename = `s24-vpn-${platform}-${selectedServer.city}-openvpn.ovpn`;
      
      // Add user credentials to OpenVPN config
      let configBody = configData.file_body;
      
      if (user.vpnUsername && user.vpnPassword) {
        // Replace or add auth-user-pass section
        if (configBody.includes('<auth-user-pass>')) {
          configBody = configBody.replace(
            /<auth-user-pass>[\s\S]*?<\/auth-user-pass>/,
            `<auth-user-pass>\n${user.vpnUsername}\n${user.vpnPassword}\n</auth-user-pass>`
          );
        } else {
          configBody += `\n\n<auth-user-pass>\n${user.vpnUsername}\n${user.vpnPassword}\n</auth-user-pass>\n`;
        }
      }
      
      configData.file_body = configBody;
    } else {
      return NextResponse.json(
        { error: 'Invalid protocol. Use "wireguard" or "openvpn"' },
        { status: 400 }
      );
    }

    // Return configuration file
    return new NextResponse(configData.file_body, {
      headers: {
        'Content-Type': 'text/plain',
        'Content-Disposition': `attachment; filename="${filename}"`,
        'X-VPN-Protocol': protocol,
        'X-VPN-Server': selectedServer.name,
        'X-VPN-Platform': platform,
      },
    });

  } catch (error) {
    console.error('[Config] Error:', error);
    return NextResponse.json(
      { 
        error: 'Failed to generate configuration',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}

/**
 * Generate iOS mobileconfig file for WireGuard
 */
function generateIOSMobileConfig(wgConfig: string, serverName: string): string {
  const uuid1 = crypto.randomUUID().toUpperCase();
  const uuid2 = crypto.randomUUID().toUpperCase();
  
  return `<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>PayloadContent</key>
    <array>
        <dict>
            <key>PayloadType</key>
            <string>com.wireguard.ios.config</string>
            <key>PayloadUUID</key>
            <string>${uuid2}</string>
            <key>PayloadIdentifier</key>
            <string>com.s24vpn.wireguard.${uuid2}</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
            <key>PayloadEnabled</key>
            <true/>
            <key>WireGuardConfig</key>
            <string>${wgConfig.replace(/\n/g, '\\n')}</string>
        </dict>
    </array>
    <key>PayloadDisplayName</key>
    <string>S24 VPN - ${serverName}</string>
    <key>PayloadIdentifier</key>
    <string>com.s24vpn.${uuid1}</string>
    <key>PayloadRemovalDisallowed</key>
    <false/>
    <key>PayloadType</key>
    <string>Configuration</string>
    <key>PayloadUUID</key>
    <string>${uuid1}</string>
    <key>PayloadVersion</key>
    <integer>1</integer>
</dict>
</plist>`;
}
