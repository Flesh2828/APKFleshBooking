'use client';

import React from 'react';
import { useApp } from '@/context/AppContext';
import {
  Building2,
  Clock,
  CheckCircle2,
  XCircle,
  Calendar,
  Users,
  ArrowRight,
  Sparkles,
  AlertCircle,
  TrendingUp,
  MapPin,
  CalendarCheck,
} from 'lucide-react';

export const DashboardView = () => {
  const { currentUser, rooms, reservations, setActiveTab, setSelectedRoomForBooking, approveReservation, rejectReservation } = useApp();

  const isUserAdmin = currentUser.role === 'ADMIN';

  // Metrics for Admin
  const activeRoomsCount = rooms.filter((r) => r.status === 'ACTIVE').length;
  const pendingReservations = reservations.filter((r) => r.status === 'PENDING');
  const approvedReservations = reservations.filter((r) => r.status === 'APPROVED');
  
  // Today's bookings
  const todayStr = new Date().toISOString().split('T')[0];
  const todayBookings = reservations.filter(
    (r) => r.startTime.startsWith(todayStr) && r.status === 'APPROVED'
  );

  // Metrics for Regular User
  const myReservations = reservations.filter((r) => r.userId === currentUser.id);
  const myPending = myReservations.filter((r) => r.status === 'PENDING');
  const myApproved = myReservations.filter((r) => r.status === 'APPROVED');
  const myRejected = myReservations.filter((r) => r.status === 'REJECTED');

  // Next upcoming booking for user
  const nowTime = new Date().getTime();
  const nextBooking = myApproved
    .filter((r) => new Date(r.startTime).getTime() >= nowTime)
    .sort((a, b) => new Date(a.startTime).getTime() - new Date(b.startTime).getTime())[0];

  const formatTimeRange = (startIso: string, endIso: string) => {
    try {
      const s = new Date(startIso);
      const e = new Date(endIso);
      const sH = String(s.getHours()).padStart(2, '0');
      const sM = String(s.getMinutes()).padStart(2, '0');
      const eH = String(e.getHours()).padStart(2, '0');
      const eM = String(e.getMinutes()).padStart(2, '0');
      return `${sH}:${sM} - ${eH}:${eM}`;
    } catch {
      return '';
    }
  };

  const formatDateDisplay = (iso: string) => {
    try {
      const d = new Date(iso);
      return d.toLocaleDateString('id-ID', {
        weekday: 'short',
        day: 'numeric',
        month: 'short',
        year: 'numeric',
      });
    } catch {
      return iso;
    }
  };

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      {/* Welcome Banner */}
      <div className="relative overflow-hidden rounded-3xl bg-gradient-to-r from-indigo-700 via-indigo-600 to-sky-600 p-6 sm:p-8 text-white shadow-xl shadow-indigo-600/20">
        <div className="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
          <div className="space-y-2 max-w-xl">
            <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/15 backdrop-blur-md text-xs font-semibold">
              <Sparkles className="w-3.5 h-3.5 text-yellow-300" />
              Sistem Manajemen & Booking Ruangan Terpusat
            </div>
            <h1 className="text-2xl sm:text-3xl font-black tracking-tight">
              Selamat Datang, {currentUser.name}!
            </h1>
            <p className="text-indigo-100 text-xs sm:text-sm leading-relaxed">
              {isUserAdmin
                ? 'Kelola ketersediaan fasilitas kampus, pantau penggunaan ruangan, dan tindak lanjuti pengajuan pemesanan yang masuk secara real-time.'
                : 'Temukan ruangan ideal untuk kegiatan akademik, perkuliahan hibrida, maupun agenda organisasi Anda dengan validasi bebas bentrok.'}
            </p>
          </div>

          <div className="flex flex-wrap items-center gap-3">
            <button
              onClick={() => setActiveTab('new_booking')}
              className="px-5 py-3 rounded-2xl bg-white text-indigo-700 hover:bg-indigo-50 font-bold text-xs sm:text-sm shadow-lg shadow-black/10 transition-all flex items-center gap-2 group"
            >
              <span>Ajukan Booking Sekarang</span>
              <ArrowRight className="w-4 h-4 transition-transform group-hover:translate-x-1" />
            </button>
            <button
              onClick={() => setActiveTab('availability')}
              className="px-5 py-3 rounded-2xl bg-white/10 hover:bg-white/20 backdrop-blur-md text-white font-semibold text-xs sm:text-sm transition-all"
            >
              Cek Kalender Jadwal
            </button>
          </div>
        </div>

        {/* Ambient background decoration */}
        <div className="absolute -right-10 -bottom-10 w-72 h-72 bg-white/10 rounded-full blur-2xl pointer-events-none" />
      </div>

      {/* KPI Stats Grid */}
      {isUserAdmin ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <div className="p-5 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm flex items-center justify-between">
            <div>
              <p className="text-xs font-semibold text-slate-500">Total Ruangan Aktif</p>
              <h3 className="text-2xl font-black text-slate-900 dark:text-white mt-1">
                {activeRoomsCount}
              </h3>
              <p className="text-[11px] text-emerald-600 font-medium mt-1 flex items-center gap-1">
                <span>Siap Digunakan</span>
              </p>
            </div>
            <div className="w-12 h-12 rounded-2xl bg-indigo-50 dark:bg-indigo-950/40 text-indigo-600 dark:text-indigo-400 flex items-center justify-center">
              <Building2 className="w-6 h-6" />
            </div>
          </div>

          <div className="p-5 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm flex items-center justify-between">
            <div>
              <p className="text-xs font-semibold text-slate-500">Pengajuan Pending</p>
              <h3 className="text-2xl font-black text-amber-500 mt-1">
                {pendingReservations.length}
              </h3>
              <button
                onClick={() => setActiveTab('approvals')}
                className="text-[11px] text-indigo-600 hover:underline font-semibold mt-1 flex items-center gap-1"
              >
                Lihat Antrean &rarr;
              </button>
            </div>
            <div className="w-12 h-12 rounded-2xl bg-amber-50 dark:bg-amber-950/40 text-amber-500 flex items-center justify-center">
              <Clock className="w-6 h-6" />
            </div>
          </div>

          <div className="p-5 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm flex items-center justify-between">
            <div>
              <p className="text-xs font-semibold text-slate-500">Reservasi Disetujui</p>
              <h3 className="text-2xl font-black text-emerald-600 mt-1">
                {approvedReservations.length}
              </h3>
              <p className="text-[11px] text-slate-400 mt-1">Terverifikasi</p>
            </div>
            <div className="w-12 h-12 rounded-2xl bg-emerald-50 dark:bg-emerald-950/40 text-emerald-600 flex items-center justify-center">
              <CheckCircle2 className="w-6 h-6" />
            </div>
          </div>

          <div className="p-5 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm flex items-center justify-between">
            <div>
              <p className="text-xs font-semibold text-slate-500">Jadwal Hari Ini</p>
              <h3 className="text-2xl font-black text-sky-600 mt-1">
                {todayBookings.length}
              </h3>
              <p className="text-[11px] text-slate-400 mt-1">Sesi Berlangsung</p>
            </div>
            <div className="w-12 h-12 rounded-2xl bg-sky-50 dark:bg-sky-950/40 text-sky-600 flex items-center justify-center">
              <CalendarCheck className="w-6 h-6" />
            </div>
          </div>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div className="p-5 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm flex items-center justify-between">
            <div>
              <p className="text-xs font-semibold text-slate-500">Pengajuan Pending</p>
              <h3 className="text-2xl font-black text-amber-500 mt-1">{myPending.length}</h3>
              <p className="text-[11px] text-slate-400 mt-1">Menunggu review admin</p>
            </div>
            <div className="w-12 h-12 rounded-2xl bg-amber-50 text-amber-500 flex items-center justify-center">
              <Clock className="w-6 h-6" />
            </div>
          </div>

          <div className="p-5 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm flex items-center justify-between">
            <div>
              <p className="text-xs font-semibold text-slate-500">Reservasi Disetujui</p>
              <h3 className="text-2xl font-black text-emerald-600 mt-1">{myApproved.length}</h3>
              <p className="text-[11px] text-slate-400 mt-1">Jadwal terkonfirmasi</p>
            </div>
            <div className="w-12 h-12 rounded-2xl bg-emerald-50 text-emerald-600 flex items-center justify-center">
              <CheckCircle2 className="w-6 h-6" />
            </div>
          </div>

          <div className="p-5 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm flex items-center justify-between">
            <div>
              <p className="text-xs font-semibold text-slate-500">Pengajuan Ditolak</p>
              <h3 className="text-2xl font-black text-rose-500 mt-1">{myRejected.length}</h3>
              <p className="text-[11px] text-slate-400 mt-1">Dapat dicek alasannya</p>
            </div>
            <div className="w-12 h-12 rounded-2xl bg-rose-50 text-rose-500 flex items-center justify-center">
              <XCircle className="w-6 h-6" />
            </div>
          </div>
        </div>
      )}

      {/* Main Dashboard Content Layout */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Left 2 Cols: Admin Pending Queue or User Upcoming Booking & Rooms Spotlight */}
        <div className="lg:col-span-2 space-y-6">
          {/* Admin Pending Action Queue */}
          {isUserAdmin && pendingReservations.length > 0 && (
            <div className="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200/80 dark:border-slate-800 shadow-sm overflow-hidden">
              <div className="p-5 border-b border-slate-100 dark:border-slate-800 flex items-center justify-between">
                <div className="flex items-center gap-2">
                  <div className="w-2.5 h-2.5 rounded-full bg-amber-500 animate-ping" />
                  <h2 className="text-sm font-bold text-slate-900 dark:text-white">
                    Perlu Persetujuan Segera ({pendingReservations.length})
                  </h2>
                </div>
                <button
                  onClick={() => setActiveTab('approvals')}
                  className="text-xs font-semibold text-indigo-600 hover:text-indigo-700"
                >
                  Lihat Semua &rarr;
                </button>
              </div>

              <div className="divide-y divide-slate-100 dark:divide-slate-800">
                {pendingReservations.slice(0, 3).map((res) => {
                  const targetRoom = rooms.find((r) => r.id === res.roomId);
                  return (
                    <div key={res.id} className="p-4 sm:p-5 flex flex-col sm:flex-row sm:items-center justify-between gap-4 hover:bg-slate-50/50 dark:hover:bg-slate-800/40 transition-colors">
                      <div className="space-y-1">
                        <div className="flex items-center gap-2">
                          <span className="font-mono text-xs font-bold text-indigo-600 bg-indigo-50 dark:bg-indigo-950/50 px-2 py-0.5 rounded">
                            {res.id}
                          </span>
                          <span className="text-xs font-semibold text-slate-700 dark:text-slate-300">
                            {res.organization}
                          </span>
                        </div>
                        <h4 className="text-sm font-bold text-slate-900 dark:text-white">
                          {res.purpose}
                        </h4>
                        <div className="flex flex-wrap items-center gap-3 text-xs text-slate-500">
                          <span className="flex items-center gap-1">
                            <Building2 className="w-3.5 h-3.5" />
                            {targetRoom?.name || 'Ruangan'}
                          </span>
                          <span className="flex items-center gap-1">
                            <Calendar className="w-3.5 h-3.5" />
                            {formatDateDisplay(res.startTime)}
                          </span>
                          <span className="flex items-center gap-1">
                            <Clock className="w-3.5 h-3.5" />
                            {formatTimeRange(res.startTime, res.endTime)}
                          </span>
                          <span className="flex items-center gap-1">
                            <Users className="w-3.5 h-3.5" />
                            {res.participantCount} Orang
                          </span>
                        </div>
                      </div>

                      <div className="flex items-center gap-2 flex-shrink-0">
                        <button
                          onClick={() => {
                            if (confirm(`Setujui pengajuan "${res.purpose}"?`)) {
                              approveReservation(res.id, 'Disetujui oleh admin dari dashboard.');
                            }
                          }}
                          className="px-3 py-1.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white text-xs font-semibold shadow-sm transition-all"
                        >
                          Setujui
                        </button>
                        <button
                          onClick={() => {
                            const reason = prompt('Masukkan alasan penolakan:');
                            if (reason !== null && reason.trim() !== '') {
                              rejectReservation(res.id, reason);
                            } else if (reason !== null) {
                              alert('Alasan penolakan wajib diisi!');
                            }
                          }}
                          className="px-3 py-1.5 rounded-xl bg-rose-50 hover:bg-rose-100 text-rose-600 text-xs font-semibold transition-all"
                        >
                          Tolak
                        </button>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          )}

          {/* User Next Booking Card */}
          {!isUserAdmin && nextBooking && (
            <div className="bg-gradient-to-br from-indigo-50 to-white dark:from-slate-900 dark:to-indigo-950/30 p-6 rounded-3xl border border-indigo-100 dark:border-indigo-900/50 shadow-sm">
              <div className="flex items-center justify-between mb-4">
                <span className="px-3 py-1 text-xs font-bold rounded-full bg-emerald-100 text-emerald-800 dark:bg-emerald-950/60 dark:text-emerald-300 flex items-center gap-1.5">
                  <CheckCircle2 className="w-3.5 h-3.5" />
                  Jadwal Reservasi Mendatang Anda
                </span>
                <span className="font-mono text-xs font-semibold text-slate-400">
                  {nextBooking.id}
                </span>
              </div>

              <h3 className="text-lg font-black text-slate-900 dark:text-white mb-2">
                {nextBooking.purpose}
              </h3>

              <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 my-4 text-xs">
                <div className="p-3 rounded-xl bg-white dark:bg-slate-800/80 border border-slate-100 dark:border-slate-700/50">
                  <span className="text-slate-400 block mb-1">Ruangan</span>
                  <span className="font-bold text-slate-800 dark:text-slate-200">
                    {rooms.find((r) => r.id === nextBooking.roomId)?.name}
                  </span>
                </div>
                <div className="p-3 rounded-xl bg-white dark:bg-slate-800/80 border border-slate-100 dark:border-slate-700/50">
                  <span className="text-slate-400 block mb-1">Waktu</span>
                  <span className="font-bold text-slate-800 dark:text-slate-200">
                    {formatTimeRange(nextBooking.startTime, nextBooking.endTime)}
                  </span>
                </div>
                <div className="p-3 rounded-xl bg-white dark:bg-slate-800/80 border border-slate-100 dark:border-slate-700/50">
                  <span className="text-slate-400 block mb-1">Tanggal</span>
                  <span className="font-bold text-slate-800 dark:text-slate-200">
                    {formatDateDisplay(nextBooking.startTime)}
                  </span>
                </div>
              </div>

              <button
                onClick={() => setActiveTab('my_bookings')}
                className="text-xs font-bold text-indigo-600 hover:text-indigo-800 flex items-center gap-1"
              >
                Lihat Detail Lengkap di 'Reservasi Saya' &rarr;
              </button>
            </div>
          )}

          {/* Quick Room Spotlight */}
          <div className="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200/80 dark:border-slate-800 p-6 shadow-sm">
            <div className="flex items-center justify-between mb-4">
              <div>
                <h3 className="text-sm font-bold text-slate-900 dark:text-white">
                  Pilihan Ruangan Kampus
                </h3>
                <p className="text-xs text-slate-500">
                  Fasilitas terkini untuk berbagai macam skala kegiatan
                </p>
              </div>
              <button
                onClick={() => setActiveTab('catalog')}
                className="text-xs font-semibold text-indigo-600 hover:underline"
              >
                Lihat Semua Ruangan &rarr;
              </button>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              {rooms.slice(0, 2).map((room) => (
                <div
                  key={room.id}
                  className="group rounded-2xl border border-slate-200/80 dark:border-slate-800 overflow-hidden hover:shadow-md transition-all flex flex-col justify-between"
                >
                  <div className="relative h-36 w-full overflow-hidden bg-slate-100">
                    <img
                      src={room.imageUrl}
                      alt={room.name}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                    />
                    <span className="absolute top-2 right-2 px-2.5 py-1 text-[10px] font-extrabold rounded-full bg-slate-900/80 backdrop-blur-md text-white">
                      Maks {room.capacity} Org
                    </span>
                  </div>

                  <div className="p-4 space-y-2">
                    <h4 className="text-xs font-bold text-slate-900 dark:text-white line-clamp-1">
                      {room.name}
                    </h4>
                    <p className="text-[11px] text-slate-500 flex items-center gap-1">
                      <MapPin className="w-3 h-3 text-indigo-500" />
                      {room.building}
                    </p>
                    <div className="flex flex-wrap gap-1 pt-1">
                      {room.facilities.slice(0, 2).map((f) => (
                        <span
                          key={f}
                          className="px-2 py-0.5 text-[10px] rounded-md bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300"
                        >
                          {f}
                        </span>
                      ))}
                    </div>
                  </div>

                  <div className="p-4 pt-0">
                    <button
                      onClick={() => {
                        setSelectedRoomForBooking(room);
                        setActiveTab('new_booking');
                      }}
                      className="w-full py-2 rounded-xl bg-indigo-50 hover:bg-indigo-600 text-indigo-700 hover:text-white font-bold text-xs transition-colors text-center"
                    >
                      Pesan Ruangan Ini
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Right 1 Col: Today's Schedule & Quick Information */}
        <div className="space-y-6">
          {/* Today's Schedule Sidebar Card */}
          <div className="bg-white dark:bg-slate-900 rounded-2xl border border-slate-200/80 dark:border-slate-800 p-5 shadow-sm space-y-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Calendar className="w-4 h-4 text-indigo-600" />
                <h3 className="text-sm font-bold text-slate-900 dark:text-white">
                  Jadwal Pemakaian Hari Ini
                </h3>
              </div>
              <span className="text-[11px] text-slate-400 font-medium">
                {new Date().toLocaleDateString('id-ID', { day: 'numeric', month: 'short' })}
              </span>
            </div>

            {todayBookings.length === 0 ? (
              <div className="p-6 text-center text-slate-400 text-xs">
                <CalendarCheck className="w-8 h-8 mx-auto mb-2 opacity-30 text-indigo-500" />
                Belum ada kegiatan yang terkonfirmasi hari ini.
              </div>
            ) : (
              <div className="space-y-3">
                {todayBookings.map((b) => {
                  const room = rooms.find((r) => r.id === b.roomId);
                  return (
                    <div
                      key={b.id}
                      className="p-3.5 rounded-xl bg-slate-50 dark:bg-slate-800/50 border border-slate-100 dark:border-slate-700/60 space-y-1.5"
                    >
                      <div className="flex items-center justify-between text-[11px]">
                        <span className="font-bold text-indigo-600 dark:text-indigo-400">
                          {formatTimeRange(b.startTime, b.endTime)}
                        </span>
                        <span className="px-1.5 py-0.5 rounded text-[10px] font-semibold bg-emerald-100 text-emerald-800 dark:bg-emerald-950/60 dark:text-emerald-300">
                          Terkonfirmasi
                        </span>
                      </div>
                      <h4 className="text-xs font-bold text-slate-900 dark:text-white line-clamp-1">
                        {b.purpose}
                      </h4>
                      <p className="text-[11px] text-slate-500 flex items-center justify-between">
                        <span>{room?.name}</span>
                        <span className="font-medium text-slate-700 dark:text-slate-300">
                          {b.userName}
                        </span>
                      </p>
                    </div>
                  );
                })}
              </div>
            )}
          </div>

          {/* Quick Help Card */}
          <div className="bg-gradient-to-br from-slate-900 to-indigo-950 text-white rounded-2xl p-5 shadow-sm space-y-3">
            <h4 className="text-xs font-bold uppercase tracking-wider text-indigo-400 flex items-center gap-1.5">
              <TrendingUp className="w-3.5 h-3.5" />
              Ketentuan Reservasi
            </h4>
            <ul className="text-xs text-slate-300 space-y-2 leading-relaxed">
              <li className="flex items-start gap-2">
                <span className="text-emerald-400 font-bold">•</span>
                <span>Pengajuan wajib diisi lengkap (tujuan, peserta, jadwal).</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-emerald-400 font-bold">•</span>
                <span>Pemesanan otomatis divalidasi dengan jadwal yang sudah disetujui.</span>
              </li>
              <li className="flex items-start gap-2">
                <span className="text-emerald-400 font-bold">•</span>
                <span>Persetujuan diproses admin maksimal 1x24 jam kerja.</span>
              </li>
            </ul>
            <div className="pt-2">
              <button
                onClick={() => setActiveTab('docs')}
                className="w-full py-2 rounded-xl bg-white/10 hover:bg-white/20 text-xs font-semibold text-center transition-colors"
              >
                Baca Dokumentasi Lengkap &rarr;
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
