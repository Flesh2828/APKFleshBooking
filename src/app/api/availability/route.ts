import { NextResponse } from 'next/server';
import { INITIAL_RESERVATIONS, INITIAL_ROOMS } from '@/lib/data';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const roomId = searchParams.get('roomId');
  const date = searchParams.get('date'); // YYYY-MM-DD

  if (!roomId || !date) {
    return NextResponse.json(
      { success: false, error: 'Parameter roomId dan date (YYYY-MM-DD) diperlukan.' },
      { status: 400 }
    );
  }

  const room = INITIAL_ROOMS.find((r) => r.id === roomId);
  if (!room) {
    return NextResponse.json({ success: false, error: 'Ruangan tidak ditemukan.' }, { status: 404 });
  }

  // Filter reservations for this room and date
  const bookingsForRoomAndDate = INITIAL_RESERVATIONS.filter(
    (r) => r.roomId === roomId && r.startTime.startsWith(date)
  );

  const bookedSlots = bookingsForRoomAndDate
    .filter((r) => r.status === 'APPROVED')
    .map((r) => ({
      reservationId: r.id,
      startTime: r.startTime,
      endTime: r.endTime,
      purpose: r.purpose,
      userName: r.userName,
      organization: r.organization,
    }));

  const pendingSlots = bookingsForRoomAndDate
    .filter((r) => r.status === 'PENDING')
    .map((r) => ({
      reservationId: r.id,
      startTime: r.startTime,
      endTime: r.endTime,
      purpose: r.purpose,
      userName: r.userName,
    }));

  return NextResponse.json({
    success: true,
    roomId,
    roomName: room.name,
    date,
    openingHour: room.openingHour,
    closingHour: room.closingHour,
    bookedSlots,
    pendingSlots,
  });
}
