import { NextRequest, NextResponse } from 'next/server';

const API_BASE = 'https://api.vpnresellers.com/v3';
const API_TOKEN = process.env.VPN_RESELLERS_API_TOKEN;

export async function GET(request: NextRequest) {
  try {
    const searchParams = request.nextUrl.searchParams;
    const accountId = searchParams.get('account_id');
    const serverId = searchParams.get('server_id');
    const platform = searchParams.get('platform') || 'desktop';

    if (!accountId || !serverId) {
      return NextResponse.json({ error: 'Account ID and Server ID required' }, { status: 400 });
    }

    let configData;
    let filename;
    let contentType = 'text/plain';

    if (platform === 'wireguard' || platform === 'ios' || platform === 'desktop') {
      // Get WireGuard configuration
      const response = await fetch(
        `${API_BASE}/accounts/${accountId}/wireguard-configuration?server_id=${serverId}`,
        {
          headers: {
            'Authorization': `Bearer ${API_TOKEN}`,
            'Accept': 'application/json',
          },
        }
      );

      if (!response.ok) {
        const errorText = await response.text();
        console.error('[VPN Resellers] Config error:', errorText);
        return NextResponse.json({ error: 'Failed to get configuration' }, { status: 500 });
      }

      const data = await response.json();
      configData = data.data.file_body;
      filename = `strat24-vpn-${serverId}.conf`;

      // iOS mobileconfig wrapper
      if (platform === 'ios') {
        const uuid1 = crypto.randomUUID().toUpperCase();
        const uuid2 = crypto.randomUUID().toUpperCase();
        
        configData = `<?xml version="1.0" encoding="UTF-8"?>
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
            <string>com.strat24.wireguard.${uuid2}</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
            <key>PayloadEnabled</key>
            <true/>
            <key>WireGuardConfig</key>
            <string>${data.data.file_body.replace(/\n/g, '\\n')}</string>
        </dict>
    </array>
    <key>PayloadDisplayName</key>
    <string>Strat24 VPN</string>
    <key>PayloadIdentifier</key>
    <string>com.strat24.${uuid1}</string>
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
        filename = `strat24-vpn.mobileconfig`;
        contentType = 'application/x-apple-aspen-config';
      }
    } else if (platform === 'openvpn') {
      // Get OpenVPN configuration
      const response = await fetch(
        `${API_BASE}/configuration?server_id=${serverId}`,
        {
          headers: {
            'Authorization': `Bearer ${API_TOKEN}`,
            'Accept': 'application/json',
          },
        }
      );

      if (!response.ok) {
        const errorText = await response.text();
        console.error('[VPN Resellers] OpenVPN config error:', errorText);
        return NextResponse.json({ error: 'Failed to get OpenVPN configuration' }, { status: 500 });
      }

      const data = await response.json();
      configData = data.data.file_body;
      filename = `strat24-vpn-${serverId}.ovpn`;
    }

    return new NextResponse(configData, {
      headers: {
        'Content-Type': contentType,
        'Content-Disposition': `attachment; filename="${filename}"`,
      },
    });

  } catch (error) {
    console.error('[VPN Resellers] Error:', error);
    return NextResponse.json({ error: 'Server error' }, { status: 500 });
  }
}

