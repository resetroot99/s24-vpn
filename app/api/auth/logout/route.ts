import { NextRequest, NextResponse } from 'next/server';

/**
 * Logout endpoint
 * Clears the session cookie
 */
export async function POST(request: NextRequest) {
  try {
    const response = NextResponse.json({ 
      success: true,
      message: 'Logged out successfully'
    });
    
    // Clear session cookie
    response.cookies.delete('user_id');
    
    console.log('[Logout] User logged out');
    
    return response;
  } catch (error) {
    console.error('[Logout] Error:', error);
    return NextResponse.json(
      { error: 'Logout failed' },
      { status: 500 }
    );
  }
}
