'use client';

import React, { useState, useMemo } from 'react';
import { useApp } from '@/context/AppContext';
import {
  CalendarDays,
  Clock,
  Building,
  CheckCircle2,
  AlertTriangle,
  Lock,
  ChevronLeft,
  ChevronRight,
  ArrowRight,
  Sparkles,
} from 'lucide-react';

export const AvailabilityCalendarView = () => {
  const { rooms, reservations, selectedRoomForBooking, setSelectedRoomForBooking, setActiveTab } = useApp();

  // Active selected room
  const [selectedRoomId, setSelectedRoomId] = useState<string>(
    selectedRoomForBooking?.id || rooms[0]?.id || ''
  );

  // Active selected date (YYYY-MM-DD)
  const [selectedDate, setSelectedDate] = useState<string>(
    new Date().toISOString().split('T')[0]
  );

  const activeRoom = useMemo(() => {
    return rooms.find((r) => r.id === selectedRoomId) || rooms[0];
  }, [rooms, selectedRoomId]);

  // Hourly slots from 08:00 to 17:00 (representing slots until 18:00)
  const timeSlots = [
    { startHour: 8, label: '08:00 - 09:00' },
    { startHour: 9, label: '09:00 - 10:00' },
    { startHour: 10, label: '10:00 - 11:00' },
    { startHour: 11, label: '11:00 - 12:00' },
    { startHour: 12, label: '12:00 - 13:00' },
    { startHour: 13, label: '13:00 - 14:00' },
    { startHour: 14, label: '14:00 - 15:00' },
    { startHour: 15, label: '15:00 - 16:00' },
    { startHour: 16, label: '16:00 - 17:00' },
    { startHour: 17, label: '17:00 - 18:00' },
  ];

  // Helper to shift date by N days
  const shiftDate = (days: number) => {
    const current = new Date(selectedDate);
    current.setDate(current.getDate() + days);
    setSelectedDate(current.toISOString().split('T')[0]);
  };

  // Find slot status for a given slot hour
  const getSlotDetails = (startHour: number) => {
    if (!activeRoom) return { status: 'AVAILABLE' };

    // Check if outside room operational hours
    const roomOpen = parseInt(activeRoom.openingHour.split(':')[0], 10);
    const roomClose = parseInt(activeRoom.closingHour.split(':')[0], 10);
    if (startHour < roomOpen || startHour >= roomClose) {
      return { status: 'UNAVAILABLE', label: 'Di Luar Jam Operasional' };
    }

    if (activeRoom.status === 'MAINTENANCE') {
      return { status: 'MAINTENANCE', label: 'Jadwal Pemeliharaan Ruangan' };
    }

    // Construct slot timestamps
    const slotStart = new Date(`${selectedDate}T${String(startHour).padStart(2, '0')}:00:00`).getTime();
    const slotEnd = new Date(`${selectedDate}T${String(startHour + 1).padStart(2, '0')}:00:00`).getTime();

    // Check against approved bookings
    const approvedBooking = reservations.find((r) => {
      if (r.roomId !== activeRoom.id || r.status !== 'APPROVED') return false;
      const bStart = new Date(r.startTime).getTime();
      const bEnd = new Date(r.endTime).getTime();
      return slotStart < bEnd && slotEnd > bStart;
    });

    if (approvedBooking) {
      return {
        status: 'BOOKED',
        booking: approvedBooking,
      };
    }

    // Check against pending bookings
    const pendingBooking = reservations.find((r) => {
      if (r.roomId !== activeRoom.id || r.status !== 'PENDING') return false;
      const bStart = new Date(r.startTime).getTime();
      const bEnd = new Date(r.endTime).getTime();
      return slotStart < bEnd && slotEnd > bStart;
    });

    if (pendingBooking) {
      return {
        status: 'PENDING',
        booking: pendingBooking,
      };
    }

    return { status: 'AVAILABLE' };
  };

  const formattedDateHeader = useMemo(() => {
    try {
      const d = new Date(selectedDate);
      return d.toLocaleDateString('id-ID', {
        weekday: 'long',
        day: 'numeric',
        month: 'long',
        year: 'numeric',
      });
    } catch {
      return selectedDate;
    }
  }, [selectedDate]);

  return (
    <div className="space-y-6 animate-in fade-in duration-300">
      {/* Page Title */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tight">
            Cek Ketersediaan & Kalender Jadwal
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Pantau status ketersediaan slot jam per ruangan untuk menghindari bentrok jadwal.
          </p>
        </div>

        {/* Legend */}
        <div className="flex flex-wrap items-center gap-3 p-2.5 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 text-xs">
          <div className="flex items-center gap-1.5 font-medium text-slate-600 dark:text-slate-300">
            <span className="w-3 h-3 rounded-md bg-emerald-500" />
            <span>Available</span>
          </div>
          <div className="flex items-center gap-1.5 font-medium text-slate-600 dark:text-slate-300">
            <span className="w-3 h-3 rounded-md bg-blue-500" />
            <span>Booked (Approved)</span>
          </div>
          <div className="flex items-center gap-1.5 font-medium text-slate-600 dark:text-slate-300">
            <span className="w-3 h-3 rounded-md bg-amber-400" />
            <span>Pending</span>
          </div>
          <div className="flex items-center gap-1.5 font-medium text-slate-600 dark:text-slate-300">
            <span className="w-3 h-3 rounded-md bg-slate-400" />
            <span>Unavailable</span>
          </div>
        </div>
      </div>

      {/* Selector Controls: Room & Date */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {/* Room Picker */}
        <div className="p-4 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm space-y-2">
          <label className="text-xs font-bold text-slate-600 dark:text-slate-300 flex items-center gap-1.5">
            <Building className="w-3.5 h-3.5 text-indigo-600" />
            Pilih Ruangan yang Ingin Dicek:
          </label>
          <select
            value={selectedRoomId}
            onChange={(e) => {
              setSelectedRoomId(e.target.value);
              const r = rooms.find((room) => room.id === e.target.value);
              if (r) setSelectedRoomForBooking(r);
            }}
            className="w-full p-2.5 text-xs font-semibold rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-800 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500"
          >
            {rooms.map((room) => (
              <option key={room.id} value={room.id}>
                {room.name} — {room.building} (Kapasitas: {room.capacity} org)
              </option>
            ))}
          </select>
        </div>

        {/* Date Picker with Quick Navigator */}
        <div className="p-4 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm space-y-2">
          <label className="text-xs font-bold text-slate-600 dark:text-slate-300 flex items-center gap-1.5">
            <CalendarDays className="w-3.5 h-3.5 text-indigo-600" />
            Pilih Tanggal:
          </label>
          <div className="flex items-center gap-2">
            <button
              onClick={() => shiftDate(-1)}
              className="p-2 rounded-xl bg-slate-100 hover:bg-slate-200 dark:bg-slate-800 dark:hover:bg-slate-700 text-slate-600 dark:text-slate-300 transition-colors"
              title="Hari Sebelumnya"
            >
              <ChevronLeft className="w-4 h-4" />
            </button>
            <input
              type="date"
              value={selectedDate}
              onChange={(e) => setSelectedDate(e.target.value)}
              className="flex-1 p-2 text-xs font-semibold rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-800 dark:text-slate-100 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
            <button
              onClick={() => shiftDate(1)}
              className="p-2 rounded-xl bg-slate-100 hover:bg-slate-200 dark:bg-slate-800 dark:hover:bg-slate-700 text-slate-600 dark:text-slate-300 transition-colors"
              title="Hari Berikutnya"
            >
              <ChevronRight className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>

      {/* Selected Room Details Card */}
      {activeRoom && (
        <div className="p-5 rounded-3xl bg-gradient-to-r from-slate-900 to-indigo-950 text-white shadow-lg flex flex-col md:flex-row md:items-center justify-between gap-4">
          <div className="flex items-center gap-4">
            <img
              src={activeRoom.imageUrl}
              alt={activeRoom.name}
              className="w-16 h-16 rounded-2xl object-cover ring-2 ring-white/20 flex-shrink-0"
            />
            <div>
              <span className="text-[10px] uppercase font-bold tracking-wider text-indigo-300">
                {activeRoom.building} (Lantai {activeRoom.floor})
              </span>
              <h3 className="text-base sm:text-lg font-black">{activeRoom.name}</h3>
              <p className="text-xs text-slate-300 flex items-center gap-2 mt-0.5">
                <span>Kapasitas: Maks {activeRoom.capacity} Orang</span>
                <span>•</span>
                <span>Jam Buka: {activeRoom.openingHour} - {activeRoom.closingHour} WIB</span>
              </p>
            </div>
          </div>

          <button
            onClick={() => {
              setSelectedRoomForBooking(activeRoom);
              setActiveTab('new_booking');
            }}
            className="px-5 py-2.5 rounded-xl bg-indigo-500 hover:bg-indigo-400 text-white font-bold text-xs shadow-md transition-all self-start md:self-auto flex items-center gap-2"
          >
            <span>Pesan Ruangan Ini</span>
            <ArrowRight className="w-3.5 h-3.5" />
          </button>
        </div>
      )}

      {/* Timeline Slot Grid */}
      <div className="bg-white dark:bg-slate-900 rounded-3xl border border-slate-200/80 dark:border-slate-800 shadow-sm overflow-hidden">
        <div className="p-5 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between bg-slate-50/50 dark:bg-slate-900/50">
          <div className="flex items-center gap-2">
            <Clock className="w-4 h-4 text-indigo-600" />
            <h3 className="text-sm font-bold text-slate-900 dark:text-white">
              Slot Jadwal: <span className="text-indigo-600">{formattedDateHeader}</span>
            </h3>
          </div>
          <span className="text-xs text-slate-400">Klik slot kosong untuk reservasi instan</span>
        </div>

        <div className="p-5 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-5 gap-3">
          {timeSlots.map((slot) => {
            const detail = getSlotDetails(slot.startHour);

            if (detail.status === 'BOOKED' && detail.booking) {
              return (
                <div
                  key={slot.label}
                  className="p-4 rounded-2xl bg-blue-50 dark:bg-blue-950/40 border border-blue-200 dark:border-blue-800/60 shadow-sm flex flex-col justify-between space-y-2 relative overflow-hidden"
                >
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-blue-900 dark:text-blue-200">
                      {slot.label}
                    </span>
                    <span className="px-2 py-0.5 rounded-full text-[10px] font-extrabold bg-blue-600 text-white">
                      Booked
                    </span>
                  </div>
                  <div>
                    <h5 className="text-xs font-bold text-slate-800 dark:text-slate-100 line-clamp-1">
                      {detail.booking.purpose}
                    </h5>
                    <p className="text-[11px] text-slate-500 line-clamp-1">
                      {detail.booking.organization}
                    </p>
                  </div>
                  <div className="text-[10px] font-semibold text-blue-700 dark:text-blue-300 flex items-center gap-1">
                    <CheckCircle2 className="w-3 h-3" />
                    <span>Disetujui ({detail.booking.participantCount} org)</span>
                  </div>
                </div>
              );
            }

            if (detail.status === 'PENDING' && detail.booking) {
              return (
                <div
                  key={slot.label}
                  className="p-4 rounded-2xl bg-amber-50 dark:bg-amber-950/40 border border-amber-200 dark:border-amber-800/60 shadow-sm flex flex-col justify-between space-y-2"
                >
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-bold text-amber-900 dark:text-amber-200">
                      {slot.label}
                    </span>
                    <span className="px-2 py-0.5 rounded-full text-[10px] font-extrabold bg-amber-500 text-white">
                      Pending
                    </span>
                  </div>
                  <div>
                    <h5 className="text-xs font-bold text-slate-800 dark:text-slate-100 line-clamp-1">
                      {detail.booking.purpose}
                    </h5>
                    <p className="text-[11px] text-slate-500 line-clamp-1">
                      Diajukan oleh: {detail.booking.userName}
                    </p>
                  </div>
                  <div className="text-[10px] font-semibold text-amber-700 dark:text-amber-300 flex items-center gap-1">
                    <AlertTriangle className="w-3 h-3" />
                    <span>Menunggu Review Admin</span>
                  </div>
                </div>
              );
            }

            if (detail.status === 'UNAVAILABLE' || detail.status === 'MAINTENANCE') {
              return (
                <div
                  key={slot.label}
                  className="p-4 rounded-2xl bg-slate-100 dark:bg-slate-800/60 border border-slate-200 dark:border-slate-700 text-slate-400 flex flex-col justify-between space-y-2 opacity-60"
                >
                  <div className="flex items-center justify-between">
                    <span className="text-xs font-semibold">{slot.label}</span>
                    <Lock className="w-3.5 h-3.5" />
                  </div>
                  <p className="text-[11px] font-medium">{detail.label}</p>
                  <span className="text-[10px] font-bold text-slate-400">Tidak Tersedia</span>
                </div>
              );
            }

            // AVAILABLE
            return (
              <button
                key={slot.label}
                onClick={() => {
                  setSelectedRoomForBooking(activeRoom);
                  setActiveTab('new_booking');
                }}
                className="group p-4 rounded-2xl bg-emerald-50/60 hover:bg-emerald-100/80 dark:bg-emerald-950/20 dark:hover:bg-emerald-950/40 border border-emerald-200/80 dark:border-emerald-800/50 shadow-sm flex flex-col justify-between text-left transition-all duration-200 hover:scale-[1.02] cursor-pointer"
              >
                <div className="flex items-center justify-between w-full">
                  <span className="text-xs font-bold text-emerald-900 dark:text-emerald-200">
                    {slot.label}
                  </span>
                  <span className="w-2 h-2 rounded-full bg-emerald-500 group-hover:animate-ping" />
                </div>
                <div className="my-2">
                  <span className="text-xs font-extrabold text-emerald-700 dark:text-emerald-400 flex items-center gap-1">
                    <CheckCircle2 className="w-3.5 h-3.5" />
                    Tersedia
                  </span>
                  <p className="text-[10px] text-emerald-600 dark:text-emerald-500">
                    Bebas bentrok jadwal
                  </p>
                </div>
                <span className="text-[11px] font-bold text-indigo-600 dark:text-indigo-400 flex items-center gap-1 group-hover:translate-x-1 transition-transform">
                  Pesan Slot Ini &rarr;
                </span>
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
};
