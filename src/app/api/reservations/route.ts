import { NextResponse } from 'next/server';
import { INITIAL_RESERVATIONS, INITIAL_ROOMS } from '@/lib/data';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const status = searchParams.get('status');
  const userId = searchParams.get('userId');

  let list = [...INITIAL_RESERVATIONS];

  if (status) {
    list = list.filter((r) => r.status === status);
  }
  if (userId) {
    list = list.filter((r) => r.userId === userId);
  }

  return NextResponse.json({
    success: true,
    count: list.length,
    data: list,
  });
}

export async function POST(request: Request) {
  try {
    const body = await request.json();

    if (!body.roomId || !body.startTime || !body.endTime || !body.purpose || !body.participantCount) {
      return NextResponse.json(
        { success: false, error: 'Data formulir tidak lengkap.' },
        { status: 400 }
      );
    }

    const room = INITIAL_ROOMS.find((r) => r.id === body.roomId);
    if (!room) {
      return NextResponse.json(
        { success: false, error: 'Ruangan tidak ditemukan.' },
        { status: 404 }
      );
    }

    if (body.participantCount > room.capacity) {
      return NextResponse.json(
        {
          success: false,
          error: `Jumlah peserta (${body.participantCount}) melebihi daya tampung ruangan (${room.capacity}).`,
        },
        { status: 422 }
      );
    }

    const sTime = new Date(body.startTime).getTime();
    const eTime = new Date(body.endTime).getTime();

    if (eTime <= sTime) {
      return NextResponse.json(
        { success: false, error: 'Waktu selesai harus lebih besar dari waktu mulai.' },
        { status: 422 }
      );
    }

    // Check conflict against APPROVED reservations
    const conflict = INITIAL_RESERVATIONS.find((r) => {
      if (r.roomId !== body.roomId || r.status !== 'APPROVED') return false;
      const bStart = new Date(r.startTime).getTime();
      const bEnd = new Date(r.endTime).getTime();
      return sTime < bEnd && eTime > bStart;
    });

    if (conflict) {
      return NextResponse.json(
        {
          success: false,
          error: `Jadwal bentrok dengan reservasi yang telah disetujui sebelumnya: "${conflict.purpose}".`,
        },
        { status: 409 }
      );
    }

    const now = new Date();
    const newReservation = {
      id: `RB-${now.getFullYear()}${String(now.getMonth() + 1).padStart(2, '0')}-${Math.floor(
        Math.random() * 900 + 100
      )}`,
      userId: body.userId || 'usr-mhs1',
      roomId: body.roomId,
      userName: body.userName || 'Pemesan',
      organization: body.organization || 'Unit Kampus',
      startTime: body.startTime,
      endTime: body.endTime,
      purpose: body.purpose,
      participantCount: Number(body.participantCount),
      additionalFacilities: body.additionalFacilities || '',
      notes: body.notes || '',
      status: 'PENDING',
      createdAt: now.toISOString(),
      updatedAt: now.toISOString(),
    };

    return NextResponse.json(
      {
        success: true,
        message: 'Pengajuan reservasi berhasil disimpan dan menunggu persetujuan.',
        data: newReservation,
      },
      { status: 201 }
    );
  } catch {
    return NextResponse.json({ success: false, error: 'Invalid JSON request body' }, { status: 400 });
  }
}
