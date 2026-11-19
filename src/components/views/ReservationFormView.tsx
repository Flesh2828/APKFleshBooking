'use client';

import React, { useState, useEffect, useMemo } from 'react';
import { useApp } from '@/context/AppContext';
import { Room } from '@/types';
import { StorageService } from '@/lib/storage';
import { evaluateGuildSpaceMl } from '@/lib/mlEngine';
import {
  Calendar,
  Clock,
  Building,
  Users,
  FileText,
  CheckCircle2,
  AlertTriangle,
  Send,
  HelpCircle,
  Sparkles,
  Cpu,
  Zap,
  ShieldCheck,
  TrendingUp,
} from 'lucide-react';

export const ReservationFormView = () => {
  const { currentUser, rooms, selectedRoomForBooking, setSelectedRoomForBooking, createReservation, setActiveTab } = useApp();

  // Selected Room
  const [roomId, setRoomId] = useState<string>(
    selectedRoomForBooking?.id || rooms[0]?.id || ''
  );

  // Form Fields
  const [userName, setUserName] = useState(currentUser.name || '');
  const [organization, setOrganization] = useState(currentUser.department || '');
  const [date, setDate] = useState(() => {
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    return tomorrow.toISOString().split('T')[0];
  });
  const [startTime, setStartTime] = useState('09:00');
  const [endTime, setEndTime] = useState('11:00');
  const [participantCount, setParticipantCount] = useState<number>(30);
  const [purpose, setPurpose] = useState('');
  const [additionalFacilities, setAdditionalFacilities] = useState('');
  const [notes, setNotes] = useState('');

  // Keep userName & organization synced if current user switches
  useEffect(() => {
    setUserName(currentUser.name);
    setOrganization(currentUser.department);
  }, [currentUser]);

  // Keep roomId synced if selectedRoomForBooking was set from another screen
  useEffect(() => {
    if (selectedRoomForBooking) {
      setRoomId(selectedRoomForBooking.id);
    }
  }, [selectedRoomForBooking]);

  const selectedRoom = useMemo(() => {
    return rooms.find((r) => r.id === roomId) || rooms[0];
  }, [rooms, roomId]);

  // Real-time conflict & validation check
  const validationStatus = useMemo(() => {
    if (!selectedRoom) return { isValid: false, message: 'Pilih ruangan terlebih dahulu.' };

    // Capacity validation
    if (participantCount > selectedRoom.capacity) {
      return {
        isValid: false,
        type: 'ERROR',
        message: `Jumlah peserta (${participantCount}) melebihi daya tampung ${selectedRoom.name} (Maksimal: ${selectedRoom.capacity} orang).`,
      };
    }

    if (participantCount <= 0) {
      return {
        isValid: false,
        type: 'ERROR',
        message: 'Jumlah peserta harus minimal 1 orang.',
      };
    }

    // Time validation
    const startHourInt = parseInt(startTime.split(':')[0], 10);
    const endHourInt = parseInt(endTime.split(':')[0], 10);
    const startMinInt = parseInt(startTime.split(':')[1], 10);
    const endMinInt = parseInt(endTime.split(':')[1], 10);

    const startTotal = startHourInt * 60 + startMinInt;
    const endTotal = endHourInt * 60 + endMinInt;

    if (endTotal <= startTotal) {
      return {
        isValid: false,
        type: 'ERROR',
        message: 'Waktu selesai harus lebih besar dari waktu mulai.',
      };
    }

    // Operational hours check
    const openParts = selectedRoom.openingHour.split(':');
    const closeParts = selectedRoom.closingHour.split(':');
    const roomOpenTotal = parseInt(openParts[0], 10) * 60 + parseInt(openParts[1], 10);
    const roomCloseTotal = parseInt(closeParts[0], 10) * 60 + parseInt(closeParts[1], 10);

    if (startTotal < roomOpenTotal || endTotal > roomCloseTotal) {
      return {
        isValid: false,
        type: 'ERROR',
        message: `Pengajuan harus berada dalam jam operasional ruangan (${selectedRoom.openingHour} - ${selectedRoom.closingHour} WIB).`,
      };
    }

    // Interval overlap conflict check
    const startIso = `${date}T${startTime}:00.000Z`;
    const endIso = `${date}T${endTime}:00.000Z`;

    const conflict = StorageService.findConflicts(selectedRoom.id, startIso, endIso);
    if (conflict.hasConflict) {
      return {
        isValid: false,
        type: 'CONFLICT',
        message: `Jadwal bentrok dengan reservasi yang telah disetujui: "${conflict.conflictingBooking?.purpose}" (${conflict.conflictingBooking?.userName}). Silakan pilih jam atau ruangan lain.`,
      };
    }

    return {
      isValid: true,
      type: 'SUCCESS',
      message: 'Jadwal dan kapasitas valid! Slot waktu tersedia dan siap diajukan.',
    };
  }, [selectedRoom, participantCount, date, startTime, endTime]);

  const durationHours = useMemo(() => {
    try {
      const [sH, sM] = startTime.split(':').map(Number);
      const [eH, eM] = endTime.split(':').map(Number);
      const diff = (eH * 60 + eM) - (sH * 60 + sM);
      return diff > 0 ? diff / 60 : 1;
    } catch {
      return 2;
    }
  }, [startTime, endTime]);

  const mlPrediction = useMemo(() => {
    return evaluateGuildSpaceMl({
      purpose,
      participantCount,
      capacity: selectedRoom?.capacity || 30,
      durationHours,
      userRole: currentUser.role,
      pastNoShowCount: 0,
      roomFacilities: selectedRoom?.facilities || [],
      hasScheduleConflict: validationStatus.type === 'CONFLICT',
    });
  }, [purpose, participantCount, selectedRoom, durationHours, currentUser.role, validationStatus.type]);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();

    if (!purpose.trim()) {
      alert('Tujuan penggunaan ruangan wajib diisi!');
      return;
    }

    if (!validationStatus.isValid) {
      alert(`Validasi gagal: ${validationStatus.message}`);
      return;
    }

    const startIso = `${date}T${startTime}:00.000Z`;
    const endIso = `${date}T${endTime}:00.000Z`;

    const result = createReservation({
      userId: currentUser.id,
      roomId: selectedRoom.id,
      userName,
      organization,
      startTime: startIso,
      endTime: endIso,
      purpose,
      participantCount,
      additionalFacilities: additionalFacilities.trim() || undefined,
      notes: notes.trim() || undefined,
    });

    if (result.success) {
      // Clear specific fields
      setPurpose('');
      setAdditionalFacilities('');
      setNotes('');
      // Navigate to My Bookings
      setActiveTab('my_bookings');
    }
  };

  return (
    <div className="space-y-6 max-w-4xl mx-auto animate-in fade-in duration-300">
      {/* Header */}
      <div>
        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-indigo-50 dark:bg-indigo-950/50 text-indigo-700 dark:text-indigo-300 text-xs font-semibold mb-2">
          <Sparkles className="w-3.5 h-3.5" />
          Formulir Pengajuan Terstandarisasi
        </div>
        <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tight">
          Formulir Reservasi Ruangan
        </h1>
        <p className="text-xs sm:text-sm text-slate-500 mt-1">
          Lengkapi formulir di bawah ini dengan akurat. Pengajuan akan segera diproses oleh Administrator Sarana & Prasarana.
        </p>
      </div>

      {/* Real-time Validation / Conflict Alert Banner */}
      <div
        className={`p-4 rounded-2xl border text-xs sm:text-sm flex items-start gap-3 transition-all duration-200 ${
          validationStatus.type === 'SUCCESS'
            ? 'bg-emerald-50 dark:bg-emerald-950/40 border-emerald-200 text-emerald-800 dark:text-emerald-200'
            : validationStatus.type === 'CONFLICT'
            ? 'bg-rose-50 dark:bg-rose-950/40 border-rose-300 text-rose-800 dark:text-rose-200'
            : 'bg-amber-50 dark:bg-amber-950/40 border-amber-200 text-amber-800 dark:text-amber-200'
        }`}
      >
        <div className="mt-0.5">
          {validationStatus.type === 'SUCCESS' && <CheckCircle2 className="w-5 h-5 text-emerald-600 flex-shrink-0" />}
          {validationStatus.type === 'CONFLICT' && <AlertTriangle className="w-5 h-5 text-rose-600 flex-shrink-0 animate-bounce" />}
          {validationStatus.type === 'ERROR' && <HelpCircle className="w-5 h-5 text-amber-600 flex-shrink-0" />}
        </div>
        <div>
          <h4 className="font-bold">
            {validationStatus.type === 'SUCCESS' && 'Status Slot: Tersedia'}
            {validationStatus.type === 'CONFLICT' && 'Peringatan: Bentrok Jadwal Terdeteksi!'}
            {validationStatus.type === 'ERROR' && 'Koreksi Data Diperlukan'}
          </h4>
          <p className="mt-0.5 leading-relaxed">{validationStatus.message}</p>
        </div>
      </div>

      {/* Main Form */}
      <form onSubmit={handleSubmit} className="bg-white dark:bg-slate-900 rounded-3xl border border-slate-200/80 dark:border-slate-800 shadow-sm p-6 sm:p-8 space-y-6">
        {/* Section 1: Identitas Pemesan */}
        <div>
          <h3 className="text-xs font-bold uppercase tracking-wider text-slate-400 mb-3">
            1. Identitas Pemesan
          </h3>
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-slate-700 dark:text-slate-300">
                Nama Lengkap Pemesan <span className="text-rose-500">*</span>
              </label>
              <input
                type="text"
                required
                value={userName}
                onChange={(e) => setUserName(e.target.value)}
                placeholder="Masukkan nama lengkap"
                className="w-full px-3.5 py-2.5 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-bold text-slate-700 dark:text-slate-300">
                Unit / Organisasi / Lembaga <span className="text-rose-500">*</span>
              </label>
              <input
                type="text"
                required
                value={organization}
                onChange={(e) => setOrganization(e.target.value)}
                placeholder="Contoh: BEM Univ, Himpunan, Prodi TI"
                className="w-full px-3.5 py-2.5 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>
          </div>
        </div>

        {/* Section 2: Pilihan Ruangan & Waktu */}
        <div className="pt-2 border-t border-slate-100 dark:border-slate-800">
          <h3 className="text-xs font-bold uppercase tracking-wider text-slate-400 mb-3">
            2. Ruangan & Waktu Penggunaan
          </h3>

          <div className="space-y-4">
            <div className="space-y-1.5">
              <label className="text-xs font-bold text-slate-700 dark:text-slate-300 flex items-center justify-between">
                <span>Pilih Ruangan <span className="text-rose-500">*</span></span>
                {selectedRoom && (
                  <span className="text-[11px] text-indigo-600 font-semibold">
                    Daya Tampung: {selectedRoom.capacity} Peserta ({selectedRoom.building})
                  </span>
                )}
              </label>
              <select
                value={roomId}
                onChange={(e) => {
                  setRoomId(e.target.value);
                  const found = rooms.find((r) => r.id === e.target.value);
                  if (found) setSelectedRoomForBooking(found);
                }}
                className="w-full px-3.5 py-2.5 text-xs font-semibold rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
              >
                {rooms.map((room) => (
                  <option key={room.id} value={room.id}>
                    {room.name} — {room.building} (Kapasitas: {room.capacity} org | Jam: {room.openingHour}-{room.closingHour})
                  </option>
                ))}
              </select>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div className="space-y-1.5">
                <label className="text-xs font-bold text-slate-700 dark:text-slate-300">
                  Tanggal Pemakaian <span className="text-rose-500">*</span>
                </label>
                <input
                  type="date"
                  required
                  value={date}
                  onChange={(e) => setDate(e.target.value)}
                  className="w-full px-3.5 py-2.5 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-bold text-slate-700 dark:text-slate-300">
                  Jam Mulai <span className="text-rose-500">*</span>
                </label>
                <select
                  value={startTime}
                  onChange={(e) => setStartTime(e.target.value)}
                  className="w-full px-3.5 py-2.5 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
                >
                  {['08:00', '08:30', '09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '12:00', '13:00', '13:30', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30'].map((t) => (
                    <option key={t} value={t}>{t} WIB</option>
                  ))}
                </select>
              </div>

              <div className="space-y-1.5">
                <label className="text-xs font-bold text-slate-700 dark:text-slate-300">
                  Jam Selesai <span className="text-rose-500">*</span>
                </label>
                <select
                  value={endTime}
                  onChange={(e) => setEndTime(e.target.value)}
                  className="w-full px-3.5 py-2.5 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
                >
                  {['09:00', '09:30', '10:00', '10:30', '11:00', '11:30', '12:00', '12:30', '13:00', '14:00', '14:30', '15:00', '15:30', '16:00', '16:30', '17:00', '17:30', '18:00'].map((t) => (
                    <option key={t} value={t}>{t} WIB</option>
                  ))}
                </select>
              </div>
            </div>
          </div>
        </div>

        {/* Section 3: Detail Kegiatan & Kebutuhan */}
        <div className="pt-2 border-t border-slate-100 dark:border-slate-800">
          <h3 className="text-xs font-bold uppercase tracking-wider text-slate-400 mb-3">
            3. Rincian Kegiatan & Kapasitas
          </h3>

          <div className="space-y-4">
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              <div className="sm:col-span-1 space-y-1.5">
                <label className="text-xs font-bold text-slate-700 dark:text-slate-300">
                  Jumlah Peserta <span className="text-rose-500">*</span>
                </label>
                <input
                  type="number"
                  required
                  min={1}
                  max={selectedRoom?.capacity || 500}
                  value={participantCount}
                  onChange={(e) => setParticipantCount(parseInt(e.target.value, 10) || 0)}
                  className="w-full px-3.5 py-2.5 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>

              <div className="sm:col-span-2 space-y-1.5">
                <label className="text-xs font-bold text-slate-700 dark:text-slate-300">
                  Tujuan Penggunaan Ruangan <span className="text-rose-500">*</span>
                </label>
                <input
                  type="text"
                  required
                  value={purpose}
                  onChange={(e) => setPurpose(e.target.value)}
                  placeholder="Contoh: Seminar Nasional, Rapat Kerja Organisasi, Bimbingan Tugas Akhir"
                  className="w-full px-3.5 py-2.5 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-bold text-slate-700 dark:text-slate-300">
                Fasilitas Tambahan yang Dibutuhkan (Opsional)
              </label>
              <input
                type="text"
                value={additionalFacilities}
                onChange={(e) => setAdditionalFacilities(e.target.value)}
                placeholder="Contoh: 2 Mic Wireless ekstra, Kabel rol, Pointer presentasi, Meja registrasi"
                className="w-full px-3.5 py-2.5 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>

            <div className="space-y-1.5">
              <label className="text-xs font-bold text-slate-700 dark:text-slate-300">
                Catatan Khusus (Opsional)
              </label>
              <textarea
                rows={2}
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                placeholder="Keterangan lain yang perlu diketahui oleh petugas kebersihan atau pengelola ruangan"
                className="w-full px-3.5 py-2 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
              />
            </div>
          </div>
        </div>

        {/* Section 4: GUILDSPACE AI ENGINE (4-MODEL INTEGRATED) */}
        <div className="pt-3 border-t border-slate-100 dark:border-slate-800">
          <div className="p-4 sm:p-5 rounded-2xl bg-gradient-to-br from-indigo-950 via-slate-900 to-emerald-950 text-white border border-indigo-500/30 shadow-xl relative overflow-hidden space-y-4">
            {/* Engine Header */}
            <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 border-b border-white/10 pb-3">
              <div className="flex items-center gap-2.5">
                <div className="w-8 h-8 rounded-xl bg-gradient-to-tr from-indigo-500 to-emerald-400 flex items-center justify-center text-white shadow-md">
                  <Cpu className="w-4 h-4" />
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <h3 className="text-sm font-extrabold tracking-tight text-white flex items-center gap-1.5">
                      GuildSpace AI Engine
                    </h3>
                    <span className="px-2 py-0.5 text-[9px] font-mono font-bold rounded-full bg-emerald-500/20 text-emerald-300 border border-emerald-400/30 flex items-center gap-1">
                      <span className="w-1.5 h-1.5 rounded-full bg-emerald-400 animate-pulse" />
                      4-MODEL ACTIVE
                    </span>
                  </div>
                  <p className="text-[11px] text-slate-300">
                    Inferensi prediktif real-time berbasis Naive Bayes, SVM, Logistic & Linear Regression
                  </p>
                </div>
              </div>

              <div className="text-[10px] font-mono text-emerald-400 self-start sm:self-auto bg-white/5 px-2.5 py-1 rounded-lg border border-white/10">
                Latensi: &lt; 25ms (Local Edge)
              </div>
            </div>

            {/* 4 Models Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3 text-xs">
              {/* Model 1: Naive Bayes */}
              <div className="p-3.5 rounded-xl bg-white/5 border border-white/10 space-y-2">
                <div className="flex items-center justify-between">
                  <span className="font-bold text-indigo-300 flex items-center gap-1.5 text-[11px]">
                    <Sparkles className="w-3.5 h-3.5 text-indigo-400" />
                    a. Naive Bayes (NLP & Anti-Spam)
                  </span>
                  <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-indigo-500/20 text-indigo-200">
                    {Math.round(mlPrediction.naiveBayes.confidence * 100)}% Conf
                  </span>
                </div>
                <div className="space-y-1 text-[11px]">
                  <div className="flex justify-between">
                    <span className="text-slate-400">Kategori Kegiatan:</span>
                    <span className="font-bold text-emerald-300">
                      {mlPrediction.naiveBayes.predictedCategory}
                    </span>
                  </div>
                  <div className="flex justify-between">
                    <span className="text-slate-400">Filter Anti-Spam:</span>
                    <span className={`font-semibold ${mlPrediction.naiveBayes.isSpam ? 'text-rose-400' : 'text-emerald-400'}`}>
                      {mlPrediction.naiveBayes.isSpam ? '⚠️ Terdeteksi Spam/Ringkas' : '✓ Lolos Validasi'}
                    </span>
                  </div>
                </div>
              </div>

              {/* Model 2: SVM */}
              <div className="p-3.5 rounded-xl bg-white/5 border border-white/10 space-y-2">
                <div className="flex items-center justify-between">
                  <span className="font-bold text-emerald-300 flex items-center gap-1.5 text-[11px]">
                    <ShieldCheck className="w-3.5 h-3.5 text-emerald-400" />
                    b. Support Vector Machine (SVM)
                  </span>
                  <span className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                    mlPrediction.svm.recommendation === 'AUTO_APPROVE'
                      ? 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/40'
                      : mlPrediction.svm.recommendation === 'AUTO_REJECT'
                      ? 'bg-rose-500/20 text-rose-300 border border-rose-500/40'
                      : 'bg-amber-500/20 text-amber-300 border border-amber-500/40'
                  }`}>
                    {mlPrediction.svm.recommendation}
                  </span>
                </div>
                <div className="space-y-1 text-[11px]">
                  <div className="flex justify-between">
                    <span className="text-slate-400">Deteksi Risiko Bentrok:</span>
                    <span className={`font-semibold ${mlPrediction.svm.hasConflictRisk ? 'text-rose-400' : 'text-emerald-400'}`}>
                      {mlPrediction.svm.hasConflictRisk ? 'BENTROK TERDETEKSI' : 'Bebas Konflik Slot'}
                    </span>
                  </div>
                  <div className="text-[10px] text-slate-300 truncate">
                    {mlPrediction.svm.reasons[0] || 'Kapasitas dan slot jadwal terverifikasi'}
                  </div>
                </div>
              </div>

              {/* Model 3: Logistic Regression */}
              <div className="p-3.5 rounded-xl bg-white/5 border border-white/10 space-y-2">
                <div className="flex items-center justify-between">
                  <span className="font-bold text-amber-300 flex items-center gap-1.5 text-[11px]">
                    <TrendingUp className="w-3.5 h-3.5 text-amber-400" />
                    c. Logistic Regression (No-Show Risk)
                  </span>
                  <span className={`px-2 py-0.5 rounded text-[10px] font-bold ${
                    mlPrediction.logisticRegression.isHighRisk
                      ? 'bg-rose-500/20 text-rose-300'
                      : 'bg-emerald-500/20 text-emerald-300'
                  }`}>
                    {mlPrediction.logisticRegression.noShowProbability}%
                  </span>
                </div>
                <div className="space-y-1 text-[11px]">
                  <div className="flex justify-between">
                    <span className="text-slate-400">Tingkat Risiko Mangkir:</span>
                    <span className={`font-semibold ${mlPrediction.logisticRegression.isHighRisk ? 'text-rose-400' : 'text-emerald-400'}`}>
                      {mlPrediction.logisticRegression.riskLevel === 'LOW' ? 'Rendah (Aman)' : 'Tinggi (Perlu Deposit/Konfirmasi)'}
                    </span>
                  </div>
                  <p className="text-[10px] text-slate-400">
                    Berdasarkan rekam jejak peran {currentUser.role} & durasi {durationHours} jam
                  </p>
                </div>
              </div>

              {/* Model 4: Linear Regression */}
              <div className="p-3.5 rounded-xl bg-white/5 border border-white/10 space-y-2">
                <div className="flex items-center justify-between">
                  <span className="font-bold text-sky-300 flex items-center gap-1.5 text-[11px]">
                    <Zap className="w-3.5 h-3.5 text-sky-400" />
                    d. Linear Regression (Energi Listrik)
                  </span>
                  <span className="px-2 py-0.5 rounded text-[10px] font-bold bg-sky-500/20 text-sky-200">
                    {mlPrediction.linearRegression.estimatedEnergyKwh} kWh
                  </span>
                </div>
                <div className="space-y-1 text-[11px]">
                  <div className="flex justify-between">
                    <span className="text-slate-400">Estimasi Beban Daya:</span>
                    <span className="font-bold text-sky-300">
                      AC: {mlPrediction.linearRegression.breakdown.coolingKwh} kWh | Alat: {mlPrediction.linearRegression.breakdown.deviceKwh} kWh
                    </span>
                  </div>
                  <div className="flex justify-between text-[10px] text-slate-400">
                    <span>Estimasi Okupansi Mingguan:</span>
                    <span className="text-slate-200 font-semibold">{mlPrediction.linearRegression.predictedOccupancyHours} Jam</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Submit Actions */}
        <div className="pt-4 border-t border-slate-100 dark:border-slate-800 flex flex-col sm:flex-row sm:items-center justify-between gap-4">
          <div className="text-[11px] text-slate-400">
            Setiap pengajuan baru akan memperoleh kode ID unik dan berstatus <strong>Pending</strong>.
          </div>

          <div className="flex items-center gap-3">
            <button
              type="button"
              onClick={() => setActiveTab('catalog')}
              className="px-5 py-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-bold transition-colors"
            >
              Batal
            </button>

            <button
              type="submit"
              disabled={!validationStatus.isValid}
              className={`px-6 py-2.5 rounded-xl font-bold text-xs shadow-lg transition-all flex items-center gap-2 ${
                validationStatus.isValid
                  ? 'bg-indigo-600 hover:bg-indigo-700 text-white shadow-indigo-600/25 cursor-pointer'
                  : 'bg-slate-300 text-slate-500 cursor-not-allowed'
              }`}
            >
              <Send className="w-3.5 h-3.5" />
              <span>Kirim Pengajuan Reservasi</span>
            </button>
          </div>
        </div>
      </form>
    </div>
  );
};
