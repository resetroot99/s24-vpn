import { NextRequest, NextResponse } from 'next/server';
import { getUserById } from '@/lib/users-supabase';

export async function GET(request: NextRequest) {
  try {
    const userId = request.cookies.get('user_id')?.value;

    if (!userId) {
      return NextResponse.json(
        { user: null },
        { status: 401 }
      );
    }

    const user = await getUserById(userId);

    if (!user) {
      return NextResponse.json(
        { user: null },
        { status: 401 }
      );
    }

    return NextResponse.json({
      user: {
        id: user.id,
        email: user.email,
        licenseKey: user.licenseKey,
        status: user.status,
      },
    });
  } catch (error) {
    console.error('[Session] Error:', error);
    return NextResponse.json(
      { user: null },
      { status: 500 }
    );
  }
}

