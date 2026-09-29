import { NextResponse } from 'next/server';
import { INITIAL_USERS } from '@/lib/data';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { email, password, authMethod, gcpProfile } = body;

    // Handle GCP Google Cloud SSO Method
    if (authMethod === 'GCP_GOOGLE' || gcpProfile) {
      const gcpEmail = gcpProfile?.email || email || 'sarah.wijaya@campus.ac.id';
      const existing = INITIAL_USERS.find((u) => u.email.toLowerCase() === gcpEmail.toLowerCase());

      const user = existing || {
        id: `usr-gcp-${Date.now()}`,
        name: gcpProfile?.name || 'Pengguna GCP Google',
        email: gcpEmail,
        role: gcpEmail.includes('admin') ? 'ADMIN' : gcpEmail.includes('dosen') ? 'DOSEN' : 'MAHASISWA',
        department: 'Fakultas / Unit Terintegrasi Google Cloud Platform',
        avatarUrl: gcpProfile?.avatarUrl || 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
        authProvider: 'GCP_GOOGLE',
      };

      return NextResponse.json({
        success: true,
        message: 'Otentikasi Google Cloud Platform (GCP) SSO berhasil.',
        authProvider: 'GCP_GOOGLE',
        user,
      });
    }

    // Handle Standard Email & Password Method
    if (!email || !password) {
      return NextResponse.json(
        { success: false, error: 'Email dan kata sandi wajib diisi.' },
        { status: 400 }
      );
    }

    const matchedUser = INITIAL_USERS.find(
      (u) => u.email.toLowerCase() === email.trim().toLowerCase()
    );

    if (!matchedUser) {
      return NextResponse.json(
        { success: false, error: 'Email tidak ditemukan dalam sistem.' },
        { status: 401 }
      );
    }

    if (matchedUser.password && matchedUser.password !== password) {
      return NextResponse.json(
        { success: false, error: 'Kata sandi tidak sesuai.' },
        { status: 401 }
      );
    }

    return NextResponse.json({
      success: true,
      message: 'Login berhasil.',
      authProvider: 'EMAIL',
      user: {
        id: matchedUser.id,
        name: matchedUser.name,
        email: matchedUser.email,
        role: matchedUser.role,
        department: matchedUser.department,
        avatarUrl: matchedUser.avatarUrl,
      },
    });
  } catch {
    return NextResponse.json(
      { success: false, error: 'Permintaan otentikasi tidak valid.' },
      { status: 400 }
    );
  }
}
