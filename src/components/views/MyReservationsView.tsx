'use client';

import React, { useState, useMemo } from 'react';
import { useApp } from '@/context/AppContext';
import { Reservation } from '@/types';
import {
  Calendar,
  Clock,
  Building,
  CheckCircle2,
  XCircle,
  AlertTriangle,
  Ban,
  Printer,
  Eye,
  Search,
  Users,
  FileText,
  X,
  PlusCircle,
  QrCode,
  Smartphone,
  Timer,
  ShieldAlert,
  Sparkles,
} from 'lucide-react';

export const MyReservationsView = () => {
  const { currentUser, rooms, reservations, logs, cancelReservation, checkInReservation, expireGhostBooking, setActiveTab } = useApp();

  const [activeFilter, setActiveFilter] = useState<'ALL' | 'PENDING' | 'APPROVED' | 'IN_USE' | 'REJECTED' | 'CANCELLED'>('ALL');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedSlipReservation, setSelectedSlipReservation] = useState<Reservation | null>(null);
  const [selectedQrReservation, setSelectedQrReservation] = useState<Reservation | null>(null);
  const [countdownSeconds, setCountdownSeconds] = useState<number>(14 * 60 + 58); // 14m 58s
  const [isScanningSimulated, setIsScanningSimulated] = useState(false);

  // 15-minute countdown timer effect for active QR Pass modal
  React.useEffect(() => {
    if (!selectedQrReservation) return;
    const interval = setInterval(() => {
      setCountdownSeconds((prev) => {
        if (prev <= 1) {
          clearInterval(interval);
          expireGhostBooking(selectedQrReservation.id);
          setSelectedQrReservation(null);
          return 0;
        }
        return prev - 1;
      });
    }, 1000);
    return () => clearInterval(interval);
  }, [selectedQrReservation, expireGhostBooking]);

  const formatCountdown = (totalSec: number) => {
    const mins = Math.floor(totalSec / 60);
    const secs = totalSec % 60;
    return `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
  };

  // Filter reservations for current user
  const userReservations = useMemo(() => {
    return reservations.filter((r) => {
      // If admin, show all or show created by user; for standard view, show current user's
      const isOwner = r.userId === currentUser.id;
      if (!isOwner && currentUser.role !== 'ADMIN') return false;

      const matchesStatus = activeFilter === 'ALL' || r.status === activeFilter;
      const room = rooms.find((rm) => rm.id === r.roomId);
      const matchesSearch =
        r.id.toLowerCase().includes(searchQuery.toLowerCase()) ||
        r.purpose.toLowerCase().includes(searchQuery.toLowerCase()) ||
        (room && room.name.toLowerCase().includes(searchQuery.toLowerCase()));

      return matchesStatus && matchesSearch;
    });
  }, [reservations, currentUser, activeFilter, searchQuery, rooms]);

  const formatDateTime = (startIso: string, endIso: string) => {
    try {
      const s = new Date(startIso);
      const e = new Date(endIso);
      const dateStr = s.toLocaleDateString('id-ID', {
        weekday: 'short',
        day: 'numeric',
        month: 'short',
        year: 'numeric',
      });
      const sH = String(s.getHours()).padStart(2, '0');
      const sM = String(s.getMinutes()).padStart(2, '0');
      const eH = String(e.getHours()).padStart(2, '0');
      const eM = String(e.getMinutes()).padStart(2, '0');
      return `${dateStr}, ${sH}:${sM} - ${eH}:${eM} WIB`;
    } catch {
      return '';
    }
  };

  const getRejectionReason = (reservationId: string) => {
    const log = logs.find((l) => l.reservationId === reservationId && l.newStatus === 'REJECTED');
    return log?.reason || 'Tidak ada catatan alasan penolakan dari admin.';
  };

  const handleCancel = (r: Reservation) => {
    const reason = prompt('Masukkan alasan pembatalan reservasi:');
    if (reason !== null) {
      cancelReservation(r.id, reason.trim() || 'Dibatalkan oleh pemesan.');
    }
  };

  return (
    <div className="space-y-6 animate-in fade-in duration-300">
      {/* Title */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tight">
            Reservasi & Riwayat Pengajuan Saya
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Pantau status verifikasi, cetak slip izin penggunaan ruangan, atau batalkan pengajuan.
          </p>
        </div>

        <button
          onClick={() => setActiveTab('new_booking')}
          className="px-4 py-2.5 rounded-2xl bg-indigo-600 hover:bg-indigo-700 text-white font-bold text-xs shadow-md shadow-indigo-600/20 transition-all flex items-center gap-2 self-start sm:self-auto"
        >
          <PlusCircle className="w-4 h-4" />
          <span>Buat Pengajuan Baru</span>
        </button>
      </div>

      {/* Filter Tabs & Search */}
      <div className="flex flex-col sm:flex-row gap-3">
        {/* Status Tabs */}
        <div className="flex items-center gap-1 p-1 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm text-xs font-semibold overflow-x-auto">
          {(['ALL', 'PENDING', 'APPROVED', 'REJECTED', 'CANCELLED'] as const).map((st) => (
            <button
              key={st}
              onClick={() => setActiveFilter(st)}
              className={`px-3 py-1.5 rounded-xl whitespace-nowrap transition-all ${
                activeFilter === st
                  ? 'bg-indigo-600 text-white shadow-sm'
                  : 'text-slate-600 dark:text-slate-400 hover:text-slate-900'
              }`}
            >
              {st === 'ALL'
                ? 'Semua'
                : st === 'PENDING'
                ? 'Pending'
                : st === 'APPROVED'
                ? 'Disetujui'
                : st === 'REJECTED'
                ? 'Ditolak'
                : 'Dibatalkan'}
            </button>
          ))}
        </div>

        {/* Search */}
        <div className="flex-1 p-2 px-3 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm flex items-center gap-2">
          <Search className="w-4 h-4 text-slate-400" />
          <input
            type="text"
            placeholder="Cari nomor ID, nama kegiatan, ruangan..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full text-xs bg-transparent focus:outline-none text-slate-800 dark:text-slate-200"
          />
        </div>
      </div>

      {/* Cards List */}
      {userReservations.length === 0 ? (
        <div className="p-12 text-center bg-white dark:bg-slate-900 rounded-3xl border border-slate-200 dark:border-slate-800 space-y-3">
          <FileText className="w-10 h-10 text-slate-300 mx-auto" />
          <h3 className="text-base font-bold text-slate-800 dark:text-slate-200">
            Belum ada data reservasi
          </h3>
          <p className="text-xs text-slate-400 max-w-sm mx-auto">
            Anda belum memiliki riwayat reservasi pada kategori filter ini. Silakan buat pengajuan baru.
          </p>
          <button
            onClick={() => setActiveTab('new_booking')}
            className="px-4 py-2 rounded-xl bg-indigo-50 text-indigo-700 hover:bg-indigo-100 text-xs font-bold transition-colors"
          >
            Ajukan Peminjaman Ruangan &rarr;
          </button>
        </div>
      ) : (
        <div className="space-y-4">
          {userReservations.map((res) => {
            const room = rooms.find((r) => r.id === res.roomId);

            return (
              <div
                key={res.id}
                className="p-5 rounded-3xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm hover:shadow-md transition-shadow space-y-4"
              >
                {/* Header Row */}
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 border-b border-slate-100 dark:border-slate-800 pb-3">
                  <div className="flex items-center gap-2">
                    <span className="font-mono text-xs font-bold px-2.5 py-1 rounded-lg bg-indigo-50 dark:bg-indigo-950/60 text-indigo-700 dark:text-indigo-300 border border-indigo-200/50">
                      {res.id}
                    </span>
                    <span className="text-xs text-slate-400">
                      Diajukan pada {new Date(res.createdAt).toLocaleDateString('id-ID')}
                    </span>
                  </div>

                  {/* Status Badge */}
                  <div className="flex items-center gap-2">
                    <span
                      className={`px-3 py-1 rounded-full text-xs font-extrabold flex items-center gap-1.5 ${
                        res.status === 'IN_USE'
                          ? 'bg-emerald-500 text-white shadow-sm ring-2 ring-emerald-400/40'
                          : res.status === 'APPROVED'
                          ? 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950/60 dark:text-emerald-300'
                          : res.status === 'PENDING'
                          ? 'bg-amber-100 text-amber-800 dark:bg-amber-950/60 dark:text-amber-300'
                          : res.status === 'CANCELLED_GHOST'
                          ? 'bg-rose-100 text-rose-800 dark:bg-rose-950/60 dark:text-rose-300 border border-rose-300'
                          : res.status === 'REJECTED'
                          ? 'bg-rose-100 text-rose-800 dark:bg-rose-950/60 dark:text-rose-300'
                          : 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300'
                      }`}
                    >
                      {res.status === 'IN_USE' && <span className="w-2 h-2 rounded-full bg-white animate-ping" />}
                      {res.status === 'APPROVED' && <CheckCircle2 className="w-3.5 h-3.5" />}
                      {res.status === 'PENDING' && <Clock className="w-3.5 h-3.5" />}
                      {res.status === 'CANCELLED_GHOST' && <ShieldAlert className="w-3.5 h-3.5 text-rose-600" />}
                      {res.status === 'REJECTED' && <XCircle className="w-3.5 h-3.5" />}
                      {res.status === 'CANCELLED' && <Ban className="w-3.5 h-3.5" />}
                      <span>
                        {res.status === 'IN_USE'
                          ? 'Aktif Digunakan'
                          : res.status === 'APPROVED'
                          ? 'Disetujui'
                          : res.status === 'PENDING'
                          ? 'Menunggu Persetujuan'
                          : res.status === 'CANCELLED_GHOST'
                          ? 'Dibatalkan (Ghost-Booking Terdeteksi)'
                          : res.status === 'REJECTED'
                          ? 'Ditolak'
                          : 'Dibatalkan'}
                      </span>
                    </span>
                  </div>
                </div>

                {/* Content */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                  <div className="md:col-span-2 space-y-2">
                    <h3 className="text-base font-extrabold text-slate-900 dark:text-white">
                      {res.purpose}
                    </h3>
                    <div className="flex flex-wrap items-center gap-4 text-xs text-slate-500">
                      <span className="flex items-center gap-1 font-semibold text-slate-700 dark:text-slate-300">
                        <Building className="w-3.5 h-3.5 text-indigo-600" />
                        {room?.name} ({room?.building})
                      </span>
                      <span className="flex items-center gap-1">
                        <Clock className="w-3.5 h-3.5 text-indigo-600" />
                        {formatDateTime(res.startTime, res.endTime)}
                      </span>
                      <span className="flex items-center gap-1">
                        <Users className="w-3.5 h-3.5 text-indigo-600" />
                        {res.participantCount} Orang
                      </span>
                    </div>

                    {res.additionalFacilities && (
                      <p className="text-xs text-slate-500 pt-1">
                        <span className="font-semibold text-slate-600 dark:text-slate-300">Fasilitas Ekstra:</span>{' '}
                        {res.additionalFacilities}
                      </p>
                    )}

                    {res.status === 'IN_USE' && (
                      <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-xl bg-emerald-50 dark:bg-emerald-950/40 text-emerald-700 dark:text-emerald-300 text-xs font-semibold border border-emerald-200 dark:border-emerald-800">
                        <span className="w-2 h-2 rounded-full bg-emerald-500" />
                        Presensi fisik terverifikasi via Smart Pass. Ruangan aktif digunakan.
                      </div>
                    )}

                    {res.status === 'CANCELLED_GHOST' && (
                      <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-xl bg-rose-50 dark:bg-rose-950/40 text-rose-700 dark:text-rose-300 text-xs font-semibold border border-rose-200 dark:border-rose-800">
                        <ShieldAlert className="w-3.5 h-3.5" />
                        Sistem mendeteksi no-show: tidak ada scan QR presensi dalam toleransi 15 menit.
                      </div>
                    )}
                  </div>

                  {/* Actions Column */}
                  <div className="flex md:flex-col justify-end md:justify-center items-end gap-2">
                    {res.status === 'APPROVED' && (
                      <>
                        <button
                          onClick={() => {
                            setCountdownSeconds(14 * 60 + 58);
                            setSelectedQrReservation(res);
                          }}
                          className="px-3.5 py-2 rounded-xl bg-gradient-to-r from-indigo-600 to-emerald-600 hover:from-indigo-700 hover:to-emerald-700 text-white text-xs font-bold transition-all shadow-md shadow-indigo-600/20 flex items-center gap-1.5"
                        >
                          <QrCode className="w-3.5 h-3.5" />
                          <span>Smart Pass & QR</span>
                        </button>

                        <button
                          onClick={() => setSelectedSlipReservation(res)}
                          className="px-3 py-1.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-semibold transition-colors flex items-center gap-1.5"
                        >
                          <Printer className="w-3.5 h-3.5" />
                          <span>Slip Izin</span>
                        </button>
                      </>
                    )}

                    {res.status === 'IN_USE' && (
                      <button
                        onClick={() => setSelectedSlipReservation(res)}
                        className="px-3.5 py-2 rounded-xl bg-emerald-50 hover:bg-emerald-100 text-emerald-700 text-xs font-bold transition-colors flex items-center gap-1.5 border border-emerald-200"
                      >
                        <Printer className="w-3.5 h-3.5" />
                        <span>Slip Izin Aktif</span>
                      </button>
                    )}

                    {(res.status === 'PENDING' || res.status === 'APPROVED') && (
                      <button
                        onClick={() => handleCancel(res)}
                        className="px-3.5 py-2 rounded-xl bg-slate-100 hover:bg-rose-50 text-slate-600 hover:text-rose-600 text-xs font-bold transition-colors"
                      >
                        Batalkan Reservasi
                      </button>
                    )}
                  </div>
                </div>

                {/* Rejection Reason Alert if rejected */}
                {res.status === 'REJECTED' && (
                  <div className="p-3.5 rounded-2xl bg-rose-50 dark:bg-rose-950/40 border border-rose-200 dark:border-rose-900/50 text-xs text-rose-800 dark:text-rose-200 space-y-1">
                    <div className="font-bold flex items-center gap-1.5">
                      <AlertTriangle className="w-3.5 h-3.5" />
                      Alasan Penolakan dari Administrator:
                    </div>
                    <p className="leading-relaxed pl-5">
                      "{getRejectionReason(res.id)}"
                    </p>
                  </div>
                )}
              </div>
            );
          })}
        </div>
      )}

      {/* Printable Booking Slip Modal */}
      {selectedSlipReservation && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="bg-white text-slate-900 rounded-3xl max-w-lg w-full p-6 sm:p-8 space-y-6 shadow-2xl relative border border-slate-200">
            <button
              onClick={() => setSelectedSlipReservation(null)}
              className="absolute top-4 right-4 p-2 rounded-full hover:bg-slate-100 text-slate-400 hover:text-slate-800"
            >
              <X className="w-4 h-4" />
            </button>

            {/* Slip Header */}
            <div className="text-center border-b pb-4 space-y-1">
              <span className="text-[10px] uppercase font-bold tracking-widest text-slate-400">
                Surat Izin Pemakaian Ruangan Resmi
              </span>
              <h2 className="text-xl font-black tracking-tight">GUILDSPACE CAMPUS SMART HUB</h2>
              <p className="text-xs text-slate-500">
                Bagian Sarana & Prasarana Kampus • Validasi Digital Sistem Terpusat
              </p>
            </div>

            {/* Booking Slip Details */}
            <div className="space-y-3 text-xs">
              <div className="flex justify-between py-1 border-b border-dashed">
                <span className="text-slate-500">Nomor Registrasi:</span>
                <span className="font-mono font-bold text-indigo-700">{selectedSlipReservation.id}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-dashed">
                <span className="text-slate-500">Nama Pemesan:</span>
                <span className="font-bold">{selectedSlipReservation.userName}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-dashed">
                <span className="text-slate-500">Unit / Lembaga:</span>
                <span className="font-bold">{selectedSlipReservation.organization}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-dashed">
                <span className="text-slate-500">Ruangan Disetujui:</span>
                <span className="font-bold">
                  {rooms.find((r) => r.id === selectedSlipReservation.roomId)?.name}
                </span>
              </div>
              <div className="flex justify-between py-1 border-b border-dashed">
                <span className="text-slate-500">Waktu Pelaksanaan:</span>
                <span className="font-bold">
                  {formatDateTime(selectedSlipReservation.startTime, selectedSlipReservation.endTime)}
                </span>
              </div>
              <div className="flex justify-between py-1 border-b border-dashed">
                <span className="text-slate-500">Peruntukan Acara:</span>
                <span className="font-bold">{selectedSlipReservation.purpose}</span>
              </div>
              <div className="flex justify-between py-1 border-b border-dashed">
                <span className="text-slate-500">Kapasitas Hadir:</span>
                <span className="font-bold">{selectedSlipReservation.participantCount} Orang</span>
              </div>
            </div>

            {/* Security Digital Seal */}
            <div className="p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-center space-y-1">
              <span className="text-xs font-black text-emerald-800 flex items-center justify-center gap-1.5">
                <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                DIVERIFIKASI & DISETUJUI RESMI
              </span>
              <p className="text-[10px] text-emerald-700">
                Tunjukkan bukti digital ini kepada petugas piket / satpam gedung saat serah terima kunci.
              </p>
            </div>

            <div className="flex items-center gap-3">
              <button
                onClick={() => window.print()}
                className="flex-1 py-3 rounded-2xl bg-indigo-600 hover:bg-indigo-700 text-white font-bold text-xs transition-colors shadow-lg shadow-indigo-600/20 flex items-center justify-center gap-2"
              >
                <Printer className="w-4 h-4" />
                <span>Cetak / Simpan PDF</span>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* SMART CHECK-IN DYNAMIC QR PASS & ANTI GHOST-BOOKING MODAL */}
      {selectedQrReservation && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/70 backdrop-blur-md animate-in fade-in duration-200">
          <div className="bg-white dark:bg-slate-900 text-slate-900 dark:text-white rounded-3xl max-w-md w-full p-6 sm:p-7 space-y-5 shadow-2xl relative border border-indigo-200 dark:border-indigo-900/50">
            <button
              onClick={() => setSelectedQrReservation(null)}
              className="absolute top-4 right-4 p-2 rounded-full hover:bg-slate-100 dark:hover:bg-slate-800 text-slate-400 hover:text-slate-800 dark:hover:text-white"
            >
              <X className="w-4 h-4" />
            </button>

            {/* Modal Title */}
            <div className="text-center space-y-1">
              <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-indigo-100 dark:bg-indigo-950/60 text-indigo-700 dark:text-indigo-300 text-[11px] font-black uppercase tracking-wider">
                <Sparkles className="w-3.5 h-3.5" />
                GuildSpace Smart Pass
              </div>
              <h2 className="text-xl font-black tracking-tight">Dynamic QR Check-In</h2>
              <p className="text-xs text-slate-500 dark:text-slate-400">
                Tunjukkan QR Code ini pada pemindai pintu ruangan untuk presensi fisik.
              </p>
            </div>

            {/* 15-Minute Countdown Badge (Anti Ghost-Booking) */}
            <div className="p-3.5 rounded-2xl bg-gradient-to-r from-amber-50 to-rose-50 dark:from-amber-950/30 dark:to-rose-950/30 border border-amber-200 dark:border-amber-800/40 text-center space-y-1">
              <div className="flex items-center justify-center gap-2 text-xs font-bold text-amber-800 dark:text-amber-300">
                <Timer className="w-4 h-4 animate-spin text-amber-600" />
                <span>Batas Waktu Validasi Presensi Fisik:</span>
                <span className="font-mono text-sm font-black text-rose-600 dark:text-rose-400 bg-white dark:bg-slate-800 px-2 py-0.5 rounded-lg border border-rose-200">
                  {formatCountdown(countdownSeconds)}
                </span>
              </div>
              <p className="text-[10px] text-amber-700/80 dark:text-amber-400/80">
                Jika batas 15 menit habis tanpa scan, status otomatis dibatalkan: <strong>Dibatalkan (Ghost-Booking Terdeteksi)</strong>.
              </p>
            </div>

            {/* Dynamic QR Display Box with High-Tech Frame */}
            <div className="flex flex-col items-center justify-center p-6 bg-slate-900 rounded-3xl border-2 border-indigo-500/40 shadow-inner relative overflow-hidden group">
              {/* Corner Accents */}
              <div className="absolute top-3 left-3 w-4 h-4 border-t-2 border-l-2 border-emerald-400" />
              <div className="absolute top-3 right-3 w-4 h-4 border-t-2 border-r-2 border-emerald-400" />
              <div className="absolute bottom-3 left-3 w-4 h-4 border-b-2 border-l-2 border-emerald-400" />
              <div className="absolute bottom-3 right-3 w-4 h-4 border-b-2 border-r-2 border-emerald-400" />

              {/* Laser Scanning Line Animation Simulation */}
              <div className="absolute inset-x-4 h-0.5 bg-gradient-to-r from-transparent via-emerald-400 to-transparent animate-pulse shadow-sm shadow-emerald-400" />

              {/* QR Pattern Representation */}
              <div className="w-44 h-44 bg-white rounded-2xl p-3 flex flex-col items-center justify-between shadow-2xl relative">
                <svg className="w-full h-full text-slate-900" viewBox="0 0 100 100" fill="currentColor">
                  {/* Outer Frame & Targets */}
                  <rect x="5" y="5" width="26" height="26" fill="black" rx="3" />
                  <rect x="9" y="9" width="18" height="18" fill="white" rx="2" />
                  <rect x="13" y="13" width="10" height="10" fill="black" rx="1" />

                  <rect x="69" y="5" width="26" height="26" fill="black" rx="3" />
                  <rect x="73" y="9" width="18" height="18" fill="white" rx="2" />
                  <rect x="77" y="13" width="10" height="10" fill="black" rx="1" />

                  <rect x="5" y="69" width="26" height="26" fill="black" rx="3" />
                  <rect x="9" y="73" width="18" height="18" fill="white" rx="2" />
                  <rect x="13" y="77" width="10" height="10" fill="black" rx="1" />

                  {/* QR Matrix Dots */}
                  <rect x="36" y="8" width="8" height="6" fill="black" />
                  <rect x="48" y="10" width="6" height="6" fill="black" />
                  <rect x="36" y="20" width="6" height="8" fill="black" />
                  <rect x="46" y="22" width="12" height="6" fill="black" />
                  
                  <rect x="8" y="36" width="6" height="8" fill="black" />
                  <rect x="20" y="38" width="10" height="6" fill="black" />
                  <rect x="8" y="48" width="8" height="8" fill="black" />
                  
                  {/* Center GuildSpace GS Logo Badge */}
                  <circle cx="50" cy="50" r="14" fill="#4F46E5" />
                  <text x="50" y="55" fontSize="11" fontWeight="900" fill="white" textAnchor="middle" fontFamily="sans-serif">GS</text>

                  <rect x="68" y="36" width="12" height="6" fill="black" />
                  <rect x="84" y="36" width="8" height="10" fill="black" />
                  <rect x="70" y="48" width="8" height="8" fill="black" />
                  <rect x="82" y="52" width="10" height="6" fill="black" />

                  <rect x="36" y="68" width="10" height="8" fill="black" />
                  <rect x="50" y="70" width="8" height="8" fill="black" />
                  <rect x="38" y="80" width="6" height="10" fill="black" />
                  <rect x="48" y="82" width="14" height="6" fill="black" />
                  
                  <rect x="68" y="68" width="8" height="8" fill="black" />
                  <rect x="80" y="72" width="10" height="6" fill="black" />
                  <rect x="72" y="82" width="8" height="8" fill="black" />
                  <rect x="84" y="82" width="8" height="8" fill="black" />
                </svg>
              </div>

              {/* Dynamic Hash String */}
              <div className="mt-3 text-center">
                <span className="font-mono text-[10px] text-emerald-300 font-bold tracking-wider block">
                  #{selectedQrReservation.id} • DYNAMIC TOKEN
                </span>
                <span className="text-[9px] text-slate-400 font-mono">
                  GUILDSPACE:CHECKIN:{selectedQrReservation.id}:{selectedQrReservation.roomId}
                </span>
              </div>
            </div>

            {/* Reservation Summary */}
            <div className="p-3.5 rounded-2xl bg-slate-50 dark:bg-slate-800 text-xs space-y-1.5 border border-slate-200 dark:border-slate-700">
              <div className="flex justify-between">
                <span className="text-slate-500">Ruangan:</span>
                <span className="font-bold text-slate-800 dark:text-slate-200">
                  {rooms.find((r) => r.id === selectedQrReservation.roomId)?.name}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-500">Pemohon:</span>
                <span className="font-semibold text-slate-800 dark:text-slate-200">
                  {selectedQrReservation.userName}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-500">Jadwal:</span>
                <span className="font-semibold text-slate-800 dark:text-slate-200">
                  {formatDateTime(selectedQrReservation.startTime, selectedQrReservation.endTime)}
                </span>
              </div>
            </div>

            {/* Interactive Simulation Controls */}
            <div className="space-y-2 pt-1">
              <button
                type="button"
                onClick={() => {
                  checkInReservation(selectedQrReservation.id);
                  setSelectedQrReservation(null);
                }}
                className="w-full py-3 rounded-2xl bg-gradient-to-r from-emerald-600 to-teal-600 hover:from-emerald-700 hover:to-teal-700 text-white font-extrabold text-xs shadow-lg shadow-emerald-600/25 transition-all flex items-center justify-center gap-2 cursor-pointer"
              >
                <Smartphone className="w-4 h-4" />
                <span>Simulasikan Scan QR Presensi Fisik (Check-In Sukses)</span>
              </button>

              <button
                type="button"
                onClick={() => {
                  expireGhostBooking(selectedQrReservation.id);
                  setSelectedQrReservation(null);
                }}
                className="w-full py-2.5 rounded-2xl bg-rose-50 hover:bg-rose-100 dark:bg-rose-950/40 dark:hover:bg-rose-950/60 text-rose-700 dark:text-rose-300 font-bold text-xs border border-rose-200 dark:border-rose-900/60 transition-colors flex items-center justify-center gap-2 cursor-pointer"
              >
                <ShieldAlert className="w-3.5 h-3.5" />
                <span>Simulasi Batas Waktu 15 Menit Habis (Ghost-Booking)</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
