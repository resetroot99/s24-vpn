import { NextResponse } from 'next/server';
import { listServers } from '@/lib/vpn-api';

export async function GET() {
  try {
    const servers = await listServers();
    
    return NextResponse.json({
      success: true,
      servers: servers.map(server => ({
        id: server.id,
        name: server.name,
        city: server.city,
        country: server.country_code,
        hostname: server.hostname,
      })),
    });
  } catch (error) {
    console.error('[Servers] Error:', error);
    return NextResponse.json(
      { 
        error: 'Failed to fetch servers',
        details: error instanceof Error ? error.message : 'Unknown error'
      },
      { status: 500 }
    );
  }
}
