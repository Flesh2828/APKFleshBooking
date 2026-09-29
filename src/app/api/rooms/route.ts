import { NextResponse } from 'next/server';
import { INITIAL_ROOMS } from '@/lib/data';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const search = searchParams.get('search')?.toLowerCase();
  const minCapacity = parseInt(searchParams.get('minCapacity') || '0', 10);
  const status = searchParams.get('status');

  let filtered = [...INITIAL_ROOMS];

  if (search) {
    filtered = filtered.filter(
      (r) =>
        r.name.toLowerCase().includes(search) ||
        r.building.toLowerCase().includes(search) ||
        r.description.toLowerCase().includes(search)
    );
  }

  if (minCapacity > 0) {
    filtered = filtered.filter((r) => r.capacity >= minCapacity);
  }

  if (status) {
    filtered = filtered.filter((r) => r.status === status);
  }

  return NextResponse.json({
    success: true,
    count: filtered.length,
    data: filtered,
  });
}

export async function POST(request: Request) {
  try {
    const body = await request.json();
    if (!body.name || !body.building || !body.capacity) {
      return NextResponse.json(
        { success: false, error: 'Nama ruangan, gedung, dan kapasitas wajib diisi.' },
        { status: 400 }
      );
    }

    const newRoom = {
      id: `room-${Date.now()}`,
      name: body.name,
      building: body.building,
      floor: body.floor || 1,
      capacity: Number(body.capacity),
      facilities: Array.isArray(body.facilities) ? body.facilities : ['AC', 'Proyektor'],
      status: body.status || 'ACTIVE',
      openingHour: body.openingHour || '08:00',
      closingHour: body.closingHour || '17:00',
      imageUrl: body.imageUrl || 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=800&q=80',
      description: body.description || '',
    };

    return NextResponse.json({ success: true, data: newRoom }, { status: 201 });
  } catch {
    return NextResponse.json({ success: false, error: 'Invalid JSON request body' }, { status: 400 });
  }
}
