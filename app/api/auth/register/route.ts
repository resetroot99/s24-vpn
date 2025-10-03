import { NextRequest, NextResponse } from 'next/server';
import { createUser, generateSecurePassword, updateUserVpnCredentials } from '@/lib/users-supabase';
import { createAccount } from '@/lib/vpn-api';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { email, password } = body;

    // Validate input
    if (!email || !password) {
      return NextResponse.json(
        { error: 'Email and password are required' },
        { status: 400 }
      );
    }

    if (password.length < 8) {
      return NextResponse.json(
        { error: 'Password must be at least 8 characters' },
        { status: 400 }
      );
    }

    // Create user
    console.log('[Register] Creating user:', email);
    const user = await createUser(email, password);

    // Create VPN account
    console.log('[Register] Provisioning VPN account...');
    const vpnPassword = generateSecurePassword();
    
    try {
      const vpnAccount = await createAccount(user.licenseKey, vpnPassword);
      
      // Update user with VPN credentials in database
      await updateUserVpnCredentials(user.id, {
        vpnAccountId: vpnAccount.id,
        vpnUsername: vpnAccount.username,
        vpnPassword: vpnPassword,
        wgPrivateKey: vpnAccount.wg_private_key,
        wgPublicKey: vpnAccount.wg_public_key,
        wgIpAddress: vpnAccount.wg_ip,
      });
      
      console.log('[Register] ✅ VPN account created:', vpnAccount.id);
    } catch (vpnError) {
      console.error('[Register] VPN provisioning failed:', vpnError);
      // Continue anyway - user can retry later
    }

    return NextResponse.json({
      success: true,
      user: {
        id: user.id,
        email: user.email,
        licenseKey: user.licenseKey,
        status: user.status,
      },
    });
  } catch (error) {
    console.error('[Register] Error:', error);
    
    if (error instanceof Error && error.message === 'User already exists') {
      return NextResponse.json(
        { error: 'User already exists' },
        { status: 409 }
      );
    }

    return NextResponse.json(
      { error: 'Registration failed' },
      { status: 500 }
    );
  }
}
