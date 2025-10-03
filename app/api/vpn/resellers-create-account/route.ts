import { NextRequest, NextResponse } from 'next/server';

const API_BASE = 'https://api.vpnresellers.com/v3';
const API_TOKEN = process.env.VPN_RESELLERS_API_TOKEN;

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { username, password } = body;

    if (!username || !password) {
      return NextResponse.json({ success: false, error: 'Username and password required' }, { status: 400 });
    }

    // Validate username format per VPN Resellers requirements
    if (!/^[a-zA-Z0-9_-]+$/.test(username)) {
      return NextResponse.json({ 
        success: false, 
        error: 'Username must be alphanumeric (letters, numbers, dashes, underscores only)' 
      }, { status: 400 });
    }

    if (username.length < 3 || username.length > 50) {
      return NextResponse.json({ 
        success: false, 
        error: 'Username must be 3-50 characters' 
      }, { status: 400 });
    }

    if (password.length < 3 || password.length > 50) {
      return NextResponse.json({ 
        success: false, 
        error: 'Password must be 3-50 characters' 
      }, { status: 400 });
    }

    const response = await fetch(`${API_BASE}/accounts`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${API_TOKEN}`,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ username, password }),
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => null);
      const errorMsg = errorData?.message || errorData?.errors?.username?.[0] || 'Failed to create account';
      console.error('[VPN Resellers] Create account error:', errorData);
      return NextResponse.json({ success: false, error: errorMsg }, { status: response.status });
    }

    const data = await response.json();
    
    return NextResponse.json({
      success: true,
      account: data.data,
    });
  } catch (error) {
    console.error('[VPN Resellers] Error:', error);
    return NextResponse.json({ success: false, error: 'Server error' }, { status: 500 });
  }
}

