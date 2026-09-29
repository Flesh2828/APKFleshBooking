'use client';

import React, { useState, useMemo } from 'react';
import { useApp } from '@/context/AppContext';
import { Reservation } from '@/types';
import {
  CheckCircle2,
  XCircle,
  Clock,
  Building,
  User,
  Calendar,
  Users,
  Search,
  Filter,
  Eye,
  FileCheck,
  AlertTriangle,
  History,
  X,
} from 'lucide-react';

export const ApprovalsView = () => {
  const { rooms, reservations, logs, approveReservation, rejectReservation } = useApp();

  const [activeFilter, setActiveFilter] = useState<'PENDING' | 'APPROVED' | 'REJECTED' | 'ALL'>('PENDING');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedReservation, setSelectedReservation] = useState<Reservation | null>(null);
  const [rejectModalOpen, setRejectModalOpen] = useState(false);
  const [rejectionReason, setRejectionReason] = useState('');

  // Filter reservations
  const filteredReservations = useMemo(() => {
    return reservations.filter((r) => {
      const matchesFilter = activeFilter === 'ALL' || r.status === activeFilter;
      const room = rooms.find((rm) => rm.id === r.roomId);
      const matchesSearch =
        r.id.toLowerCase().includes(searchQuery.toLowerCase()) ||
        r.userName.toLowerCase().includes(searchQuery.toLowerCase()) ||
        r.organization.toLowerCase().includes(searchQuery.toLowerCase()) ||
        r.purpose.toLowerCase().includes(searchQuery.toLowerCase()) ||
        (room && room.name.toLowerCase().includes(searchQuery.toLowerCase()));

      return matchesFilter && matchesSearch;
    });
  }, [reservations, activeFilter, searchQuery, rooms]);

  const pendingCount = reservations.filter((r) => r.status === 'PENDING').length;
  const approvedCount = reservations.filter((r) => r.status === 'APPROVED').length;
  const rejectedCount = reservations.filter((r) => r.status === 'REJECTED').length;

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
      return `${dateStr} (${sH}:${sM} - ${eH}:${eM} WIB)`;
    } catch {
      return '';
    }
  };

  const handleApprove = (reservation: Reservation) => {
    if (confirm(`Konfirmasi: Setujui pengajuan "${reservation.purpose}" oleh ${reservation.userName}?`)) {
      const res = approveReservation(reservation.id, 'Disetujui oleh Administrator Sarana & Prasarana.');
      if (res.success && selectedReservation?.id === reservation.id) {
        setSelectedReservation(null);
      }
    }
  };

  const handleOpenReject = (reservation: Reservation) => {
    setSelectedReservation(reservation);
    setRejectionReason('');
    setRejectModalOpen(true);
  };

  const handleConfirmReject = () => {
    if (!rejectionReason.trim()) {
      alert('Alasan penolakan wajib diisi!');
      return;
    }
    if (selectedReservation) {
      const res = rejectReservation(selectedReservation.id, rejectionReason.trim());
      if (res.success) {
        setRejectModalOpen(false);
        setSelectedReservation(null);
      }
    }
  };

  return (
    <div className="space-y-6 animate-in fade-in duration-300">
      {/* Title & Stats */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tight">
            Persetujuan & Verifikasi Reservasi
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Tinjau identitas pemesan, tujuan kegiatan, serta validasi ketersediaan jadwal ruangan.
          </p>
        </div>

        {/* Tab Badges */}
        <div className="flex items-center gap-1.5 p-1 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm text-xs font-semibold">
          <button
            onClick={() => setActiveFilter('PENDING')}
            className={`px-3 py-1.5 rounded-xl transition-all flex items-center gap-1.5 ${
              activeFilter === 'PENDING'
                ? 'bg-amber-500 text-white shadow-sm'
                : 'text-slate-600 dark:text-slate-400 hover:text-slate-900'
            }`}
          >
            <span>Menunggu Review</span>
            <span className="px-1.5 py-0.2 rounded-full text-[10px] bg-white/20">
              {pendingCount}
            </span>
          </button>

          <button
            onClick={() => setActiveFilter('APPROVED')}
            className={`px-3 py-1.5 rounded-xl transition-all flex items-center gap-1.5 ${
              activeFilter === 'APPROVED'
                ? 'bg-emerald-600 text-white shadow-sm'
                : 'text-slate-600 dark:text-slate-400 hover:text-slate-900'
            }`}
          >
            <span>Disetujui</span>
            <span className="px-1.5 py-0.2 rounded-full text-[10px] bg-white/20">
              {approvedCount}
            </span>
          </button>

          <button
            onClick={() => setActiveFilter('REJECTED')}
            className={`px-3 py-1.5 rounded-xl transition-all flex items-center gap-1.5 ${
              activeFilter === 'REJECTED'
                ? 'bg-rose-600 text-white shadow-sm'
                : 'text-slate-600 dark:text-slate-400 hover:text-slate-900'
            }`}
          >
            <span>Ditolak</span>
            <span className="px-1.5 py-0.2 rounded-full text-[10px] bg-white/20">
              {rejectedCount}
            </span>
          </button>

          <button
            onClick={() => setActiveFilter('ALL')}
            className={`px-3 py-1.5 rounded-xl transition-all ${
              activeFilter === 'ALL'
                ? 'bg-slate-900 text-white dark:bg-white dark:text-slate-900'
                : 'text-slate-600 dark:text-slate-400 hover:text-slate-900'
            }`}
          >
            Semua
          </button>
        </div>
      </div>

      {/* Search Bar */}
      <div className="p-4 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm flex items-center gap-3">
        <Search className="w-4 h-4 text-slate-400" />
        <input
          type="text"
          placeholder="Cari ID pengajuan, pemesan, organisasi, ruangan, atau tujuan..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="flex-1 text-xs bg-transparent focus:outline-none text-slate-900 dark:text-white"
        />
        {searchQuery && (
          <button
            onClick={() => setSearchQuery('')}
            className="text-xs text-slate-400 hover:text-slate-600"
          >
            Bersihkan
          </button>
        )}
      </div>

      {/* Table / List View */}
      <div className="bg-white dark:bg-slate-900 rounded-3xl border border-slate-200/80 dark:border-slate-800 shadow-sm overflow-hidden">
        {filteredReservations.length === 0 ? (
          <div className="p-12 text-center text-slate-400 text-xs">
            <FileCheck className="w-10 h-10 mx-auto mb-2 opacity-30 text-indigo-500" />
            Tidak ada pengajuan yang sesuai dengan kriteria filter saat ini.
          </div>
        ) : (
          <div className="overflow-x-auto">
            <table className="w-full text-left border-collapse text-xs">
              <thead>
                <tr className="border-b border-slate-100 dark:border-slate-800 bg-slate-50/50 dark:bg-slate-900/50 text-slate-400 uppercase tracking-wider text-[10px]">
                  <th className="py-3.5 px-4 font-bold">ID & Tanggal</th>
                  <th className="py-3.5 px-4 font-bold">Pemesan & Lembaga</th>
                  <th className="py-3.5 px-4 font-bold">Ruangan</th>
                  <th className="py-3.5 px-4 font-bold">Jadwal Penggunaan</th>
                  <th className="py-3.5 px-4 font-bold">Peserta</th>
                  <th className="py-3.5 px-4 font-bold">Status</th>
                  <th className="py-3.5 px-4 font-bold text-right">Aksi Tindakan</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                {filteredReservations.map((res) => {
                  const targetRoom = rooms.find((r) => r.id === res.roomId);

                  return (
                    <tr
                      key={res.id}
                      className="hover:bg-slate-50/60 dark:hover:bg-slate-800/40 transition-colors"
                    >
                      <td className="py-3.5 px-4">
                        <span className="font-mono font-bold text-indigo-600 dark:text-indigo-400">
                          {res.id}
                        </span>
                        <div className="text-[10px] text-slate-400">
                          {new Date(res.createdAt).toLocaleDateString('id-ID')}
                        </div>
                      </td>

                      <td className="py-3.5 px-4">
                        <div className="font-bold text-slate-900 dark:text-slate-100">
                          {res.userName}
                        </div>
                        <div className="text-[11px] text-slate-500">{res.organization}</div>
                      </td>

                      <td className="py-3.5 px-4">
                        <div className="font-semibold text-slate-800 dark:text-slate-200">
                          {targetRoom?.name || 'Ruangan'}
                        </div>
                        <div className="text-[10px] text-slate-400">{targetRoom?.building}</div>
                      </td>

                      <td className="py-3.5 px-4 font-medium text-slate-700 dark:text-slate-300">
                        {formatDateTime(res.startTime, res.endTime)}
                      </td>

                      <td className="py-3.5 px-4 font-semibold text-slate-700 dark:text-slate-300">
                        {res.participantCount} Orang
                      </td>

                      <td className="py-3.5 px-4">
                        <span
                          className={`px-2.5 py-1 text-[10px] font-extrabold rounded-full inline-flex items-center gap-1 ${
                            res.status === 'APPROVED'
                              ? 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950/60 dark:text-emerald-300'
                              : res.status === 'PENDING'
                              ? 'bg-amber-100 text-amber-800 dark:bg-amber-950/60 dark:text-amber-300'
                              : res.status === 'REJECTED'
                              ? 'bg-rose-100 text-rose-800 dark:bg-rose-950/60 dark:text-rose-300'
                              : 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300'
                          }`}
                        >
                          {res.status === 'APPROVED' && <CheckCircle2 className="w-3 h-3" />}
                          {res.status === 'PENDING' && <Clock className="w-3 h-3" />}
                          {res.status === 'REJECTED' && <XCircle className="w-3 h-3" />}
                          <span>{res.status}</span>
                        </span>
                      </td>

                      <td className="py-3.5 px-4 text-right">
                        <div className="flex items-center justify-end gap-1.5">
                          <button
                            onClick={() => setSelectedReservation(res)}
                            className="p-1.5 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-700 dark:bg-slate-800 dark:hover:bg-slate-700 dark:text-slate-300 transition-colors"
                            title="Tinjau Detail"
                          >
                            <Eye className="w-3.5 h-3.5" />
                          </button>

                          {res.status === 'PENDING' && (
                            <>
                              <button
                                onClick={() => handleApprove(res)}
                                className="px-2.5 py-1.5 rounded-lg bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-[11px] transition-colors shadow-sm"
                              >
                                Setujui
                              </button>
                              <button
                                onClick={() => handleOpenReject(res)}
                                className="px-2.5 py-1.5 rounded-lg bg-rose-50 hover:bg-rose-100 text-rose-600 font-bold text-[11px] transition-colors"
                              >
                                Tolak
                              </button>
                            </>
                          )}
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </div>

      {/* Detail Review Modal */}
      {selectedReservation && !rejectModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="bg-white dark:bg-slate-900 rounded-3xl max-w-xl w-full p-6 space-y-5 border border-slate-200 dark:border-slate-800 shadow-2xl relative max-h-[90vh] overflow-y-auto">
            <button
              onClick={() => setSelectedReservation(null)}
              className="absolute top-4 right-4 p-2 rounded-full bg-slate-100 dark:bg-slate-800 text-slate-500 hover:text-slate-900"
            >
              <X className="w-4 h-4" />
            </button>

            <div>
              <div className="flex items-center gap-2">
                <span className="font-mono text-xs font-bold text-indigo-600 bg-indigo-50 dark:bg-indigo-950/50 px-2 py-0.5 rounded">
                  {selectedReservation.id}
                </span>
                <span
                  className={`px-2 py-0.5 text-[10px] font-extrabold rounded-full ${
                    selectedReservation.status === 'APPROVED'
                      ? 'bg-emerald-100 text-emerald-800'
                      : selectedReservation.status === 'PENDING'
                      ? 'bg-amber-100 text-amber-800'
                      : 'bg-rose-100 text-rose-800'
                  }`}
                >
                  {selectedReservation.status}
                </span>
              </div>
              <h2 className="text-lg font-black text-slate-900 dark:text-white mt-1">
                {selectedReservation.purpose}
              </h2>
            </div>

            <div className="grid grid-cols-2 gap-3 text-xs">
              <div className="p-3 rounded-xl bg-slate-50 dark:bg-slate-800">
                <span className="text-slate-400 block mb-0.5">Nama Pemesan</span>
                <span className="font-bold text-slate-800 dark:text-slate-200">
                  {selectedReservation.userName}
                </span>
              </div>

              <div className="p-3 rounded-xl bg-slate-50 dark:bg-slate-800">
                <span className="text-slate-400 block mb-0.5">Unit / Lembaga</span>
                <span className="font-bold text-slate-800 dark:text-slate-200">
                  {selectedReservation.organization}
                </span>
              </div>

              <div className="p-3 rounded-xl bg-slate-50 dark:bg-slate-800">
                <span className="text-slate-400 block mb-0.5">Ruangan</span>
                <span className="font-bold text-slate-800 dark:text-slate-200">
                  {rooms.find((r) => r.id === selectedReservation.roomId)?.name}
                </span>
              </div>

              <div className="p-3 rounded-xl bg-slate-50 dark:bg-slate-800">
                <span className="text-slate-400 block mb-0.5">Estimasi Hadir</span>
                <span className="font-bold text-slate-800 dark:text-slate-200">
                  {selectedReservation.participantCount} Orang
                </span>
              </div>
            </div>

            <div className="p-3.5 rounded-xl bg-indigo-50/60 dark:bg-indigo-950/30 border border-indigo-100 dark:border-indigo-900/50 text-xs">
              <span className="text-slate-400 block mb-1">Jadwal Waktu:</span>
              <span className="font-bold text-indigo-950 dark:text-indigo-200">
                {formatDateTime(selectedReservation.startTime, selectedReservation.endTime)}
              </span>
            </div>

            {selectedReservation.additionalFacilities && (
              <div className="text-xs">
                <span className="font-bold text-slate-700 dark:text-slate-300 block mb-1">
                  Kebutuhan Fasilitas Tambahan:
                </span>
                <p className="p-2.5 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-600 dark:text-slate-300">
                  {selectedReservation.additionalFacilities}
                </p>
              </div>
            )}

            {selectedReservation.notes && (
              <div className="text-xs">
                <span className="font-bold text-slate-700 dark:text-slate-300 block mb-1">
                  Catatan Pemohon:
                </span>
                <p className="p-2.5 rounded-xl bg-slate-50 dark:bg-slate-800 text-slate-600 dark:text-slate-300">
                  {selectedReservation.notes}
                </p>
              </div>
            )}

            {/* Audit Logs for this reservation */}
            {logs.filter((l) => l.reservationId === selectedReservation.id).length > 0 && (
              <div className="border-t border-slate-100 dark:border-slate-800 pt-3">
                <h4 className="text-xs font-bold text-slate-700 dark:text-slate-300 flex items-center gap-1.5 mb-2">
                  <History className="w-3.5 h-3.5 text-indigo-600" />
                  Rekam Jejak Persetujuan (Audit Trail)
                </h4>
                <div className="space-y-1.5">
                  {logs
                    .filter((l) => l.reservationId === selectedReservation.id)
                    .map((log) => (
                      <div
                        key={log.id}
                        className="p-2 rounded-lg bg-slate-50 dark:bg-slate-800 text-[11px] space-y-0.5"
                      >
                        <div className="flex items-center justify-between text-slate-400">
                          <span>Oleh: {log.adminName}</span>
                          <span>{new Date(log.createdAt).toLocaleString('id-ID')}</span>
                        </div>
                        <div className="font-semibold text-slate-700 dark:text-slate-200">
                          Status: {log.previousStatus} &rarr; {log.newStatus}
                        </div>
                        {log.reason && (
                          <div className="text-slate-500 italic">"Catatan: {log.reason}"</div>
                        )}
                      </div>
                    ))}
                </div>
              </div>
            )}

            {/* Modal Actions */}
            {selectedReservation.status === 'PENDING' && (
              <div className="flex items-center gap-3 pt-3 border-t border-slate-100 dark:border-slate-800">
                <button
                  onClick={() => handleOpenReject(selectedReservation)}
                  className="flex-1 py-2.5 rounded-xl bg-rose-50 hover:bg-rose-100 text-rose-600 font-bold text-xs transition-colors"
                >
                  Tolak Pengajuan
                </button>
                <button
                  onClick={() => handleApprove(selectedReservation)}
                  className="flex-1 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-xs shadow-md shadow-emerald-600/20 transition-colors"
                >
                  Setujui Pengajuan
                </button>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Reject Reason Modal */}
      {rejectModalOpen && selectedReservation && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="bg-white dark:bg-slate-900 rounded-3xl max-w-md w-full p-6 space-y-4 border border-slate-200 dark:border-slate-800 shadow-2xl relative">
            <h3 className="text-base font-black text-slate-900 dark:text-white flex items-center gap-2">
              <AlertTriangle className="w-5 h-5 text-rose-500" />
              Tolak Pengajuan Reservasi
            </h3>
            <p className="text-xs text-slate-500 leading-relaxed">
              Sesuai PRD Section 8.5, penolakan pengajuan <strong>wajib menyertakan alasan</strong> yang jelas agar dapat dipahami oleh pemesan.
            </p>

            <div className="space-y-1.5">
              <label className="text-xs font-bold text-slate-700 dark:text-slate-300">
                Alasan Penolakan <span className="text-rose-500">*</span>
              </label>
              <textarea
                required
                rows={3}
                value={rejectionReason}
                onChange={(e) => setRejectionReason(e.target.value)}
                placeholder="Contoh: Ruangan dialokasikan untuk visitasi asesor akreditasi internasional."
                className="w-full px-3.5 py-2.5 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 focus:outline-none focus:ring-2 focus:ring-rose-500"
              />
            </div>

            <div className="flex items-center gap-2 pt-2">
              <button
                onClick={() => setRejectModalOpen(false)}
                className="flex-1 py-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-bold transition-colors"
              >
                Batal
              </button>
              <button
                onClick={handleConfirmReject}
                className="flex-1 py-2.5 rounded-xl bg-rose-600 hover:bg-rose-700 text-white text-xs font-bold shadow-md shadow-rose-600/20 transition-colors"
              >
                Konfirmasi Penolakan
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
