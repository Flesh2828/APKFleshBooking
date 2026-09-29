'use client';

import React, { useMemo } from 'react';
import { useApp } from '@/context/AppContext';
import {
  BarChart3,
  TrendingUp,
  CheckCircle2,
  XCircle,
  Clock,
  Building,
  Printer,
  History,
} from 'lucide-react';

export const ReportsView = () => {
  const { rooms, reservations, logs } = useApp();

  // Metrics
  const total = reservations.length;
  const approved = reservations.filter((r) => r.status === 'APPROVED').length;
  const pending = reservations.filter((r) => r.status === 'PENDING').length;
  const rejected = reservations.filter((r) => r.status === 'REJECTED').length;
  const cancelled = reservations.filter((r) => r.status === 'CANCELLED').length;

  const approvalRate = total > 0 ? Math.round((approved / total) * 100) : 0;

  // Room frequency
  const roomFrequency = useMemo(() => {
    const map: Record<string, number> = {};
    reservations.forEach((r) => {
      map[r.roomId] = (map[r.roomId] || 0) + 1;
    });

    return rooms
      .map((room) => ({
        room,
        count: map[room.id] || 0,
      }))
      .sort((a, b) => b.count - a.count);
  }, [rooms, reservations]);

  const maxCount = Math.max(...roomFrequency.map((rf) => rf.count), 1);

  return (
    <div className="space-y-6 animate-in fade-in duration-300">
      {/* Title */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tight">
            Laporan & Analisis Utilisasi Ruangan
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Ringkasan data analitik frekuensi penggunaan sarana, rasio persetujuan, dan rekam audit.
          </p>
        </div>

        <button
          onClick={() => window.print()}
          className="px-4 py-2.5 rounded-2xl bg-indigo-600 hover:bg-indigo-700 text-white font-bold text-xs shadow-md shadow-indigo-600/20 transition-all flex items-center gap-2 self-start sm:self-auto"
        >
          <Printer className="w-4 h-4" />
          <span>Cetak Laporan Lengkap</span>
        </button>
      </div>

      {/* KPI Stats */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="p-5 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm">
          <p className="text-xs font-semibold text-slate-500">Total Pengajuan Masuk</p>
          <h3 className="text-2xl font-black text-slate-900 dark:text-white mt-1">{total}</h3>
          <p className="text-[11px] text-slate-400 mt-1">Seluruh Periode</p>
        </div>

        <div className="p-5 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm">
          <p className="text-xs font-semibold text-slate-500">Tingkat Persetujuan</p>
          <h3 className="text-2xl font-black text-emerald-600 mt-1">{approvalRate}%</h3>
          <p className="text-[11px] text-slate-400 mt-1">{approved} Disetujui</p>
        </div>

        <div className="p-5 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm">
          <p className="text-xs font-semibold text-slate-500">Pengajuan Pending</p>
          <h3 className="text-2xl font-black text-amber-500 mt-1">{pending}</h3>
          <p className="text-[11px] text-slate-400 mt-1">Dalam proses peninjauan</p>
        </div>

        <div className="p-5 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm">
          <p className="text-xs font-semibold text-slate-500">Pengajuan Ditolak</p>
          <h3 className="text-2xl font-black text-rose-500 mt-1">{rejected}</h3>
          <p className="text-[11px] text-slate-400 mt-1">{cancelled} Dibatalkan Pemesan</p>
        </div>
      </div>

      {/* Grid: Room Frequency & Status Distribution */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left 2 Cols: Frequency Bars */}
        <div className="lg:col-span-2 p-6 rounded-3xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm space-y-4">
          <div className="flex items-center justify-between">
            <h3 className="text-sm font-bold text-slate-900 dark:text-white flex items-center gap-2">
              <BarChart3 className="w-4 h-4 text-indigo-600" />
              Frekuensi Pemesanan Tiap Ruangan
            </h3>
            <span className="text-xs text-slate-400">Peringkat Terpopuler</span>
          </div>

          <div className="space-y-4 pt-2">
            {roomFrequency.map(({ room, count }) => {
              const percentage = Math.round((count / maxCount) * 100);

              return (
                <div key={room.id} className="space-y-1">
                  <div className="flex items-center justify-between text-xs">
                    <span className="font-bold text-slate-800 dark:text-slate-200">
                      {room.name}
                    </span>
                    <span className="font-mono font-semibold text-indigo-600 dark:text-indigo-400">
                      {count} Reservasi
                    </span>
                  </div>
                  <div className="w-full h-3 rounded-full bg-slate-100 dark:bg-slate-800 overflow-hidden">
                    <div
                      className="h-full rounded-full bg-gradient-to-r from-indigo-500 to-sky-400 transition-all duration-500"
                      style={{ width: `${Math.max(percentage, 8)}%` }}
                    />
                  </div>
                  <div className="flex items-center justify-between text-[10px] text-slate-400">
                    <span>{room.building}</span>
                    <span>Kapasitas: {room.capacity} Orang</span>
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Right 1 Col: Status Breakdown */}
        <div className="p-6 rounded-3xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm space-y-4">
          <h3 className="text-sm font-bold text-slate-900 dark:text-white flex items-center gap-2">
            <TrendingUp className="w-4 h-4 text-indigo-600" />
            Distribusi Status Reservasi
          </h3>

          <div className="space-y-3 pt-2">
            <div className="p-3.5 rounded-2xl bg-emerald-50 dark:bg-emerald-950/30 border border-emerald-100 dark:border-emerald-900/40 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                <span className="text-xs font-bold text-emerald-950 dark:text-emerald-200">Disetujui</span>
              </div>
              <span className="font-mono text-xs font-black text-emerald-800 dark:text-emerald-300">{approved}</span>
            </div>

            <div className="p-3.5 rounded-2xl bg-amber-50 dark:bg-amber-950/30 border border-amber-100 dark:border-amber-900/40 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Clock className="w-4 h-4 text-amber-600" />
                <span className="text-xs font-bold text-amber-950 dark:text-amber-200">Pending Review</span>
              </div>
              <span className="font-mono text-xs font-black text-amber-800 dark:text-amber-300">{pending}</span>
            </div>

            <div className="p-3.5 rounded-2xl bg-rose-50 dark:bg-rose-950/30 border border-rose-100 dark:border-rose-900/40 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <XCircle className="w-4 h-4 text-rose-600" />
                <span className="text-xs font-bold text-rose-950 dark:text-rose-200">Ditolak Admin</span>
              </div>
              <span className="font-mono text-xs font-black text-rose-800 dark:text-rose-300">{rejected}</span>
            </div>

            <div className="p-3.5 rounded-2xl bg-slate-50 dark:bg-slate-800/50 border border-slate-200 dark:border-slate-700/60 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Clock className="w-4 h-4 text-slate-500" />
                <span className="text-xs font-bold text-slate-700 dark:text-slate-300">Dibatalkan Pemesan</span>
              </div>
              <span className="font-mono text-xs font-black text-slate-700 dark:text-slate-300">{cancelled}</span>
            </div>
          </div>
        </div>
      </div>

      {/* Audit Log Table */}
      <div className="p-6 rounded-3xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm space-y-4">
        <h3 className="text-sm font-bold text-slate-900 dark:text-white flex items-center gap-2">
          <History className="w-4 h-4 text-indigo-600" />
          Rekam Jejak Aktivitas Persetujuan & Log Status (Audit Log)
        </h3>

        <div className="overflow-x-auto">
          <table className="w-full text-left border-collapse text-xs">
            <thead>
              <tr className="border-b text-slate-400 text-[10px] uppercase font-bold">
                <th className="py-2.5 px-3">Waktu</th>
                <th className="py-2.5 px-3">No. Reservasi</th>
                <th className="py-2.5 px-3">Petugas Verifikator</th>
                <th className="py-2.5 px-3">Perubahan Status</th>
                <th className="py-2.5 px-3">Catatan / Alasan</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
              {logs.map((log) => (
                <tr key={log.id} className="hover:bg-slate-50 dark:hover:bg-slate-800/40">
                  <td className="py-2.5 px-3 text-slate-400">
                    {new Date(log.createdAt).toLocaleString('id-ID')}
                  </td>
                  <td className="py-2.5 px-3 font-mono font-bold text-indigo-600">
                    {log.reservationId}
                  </td>
                  <td className="py-2.5 px-3 font-semibold text-slate-800 dark:text-slate-200">
                    {log.adminName}
                  </td>
                  <td className="py-2.5 px-3">
                    <span className="font-semibold text-slate-600 dark:text-slate-300">
                      {log.previousStatus} &rarr; <span className="text-indigo-600 font-bold">{log.newStatus}</span>
                    </span>
                  </td>
                  <td className="py-2.5 px-3 text-slate-600 dark:text-slate-300 italic">
                    {log.reason ? `"${log.reason}"` : '-'}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
