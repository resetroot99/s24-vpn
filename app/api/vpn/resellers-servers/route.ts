import { NextResponse } from 'next/server';

const API_BASE = 'https://api.vpnresellers.com/v3';
const API_TOKEN = process.env.VPN_RESELLERS_API_TOKEN;

export async function GET() {
  try {
    const response = await fetch(`${API_BASE}/servers`, {
      headers: {
        'Authorization': `Bearer ${API_TOKEN}`,
        'Accept': 'application/json',
      },
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error('[VPN Resellers] Server list error:', errorText);
      return NextResponse.json({ success: false, error: 'Failed to fetch servers' }, { status: 500 });
    }

    const data = await response.json();
    
    return NextResponse.json({
      success: true,
      servers: data.data || [],
    });
  } catch (error) {
    console.error('[VPN Resellers] Error:', error);
    return NextResponse.json({ success: false, error: 'Server error' }, { status: 500 });
  }
}

