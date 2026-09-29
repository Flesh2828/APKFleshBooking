'use client';

import React, { useState } from 'react';
import { useApp } from '@/context/AppContext';
import { UserRole } from '@/types';
import {
  Building2,
  Mail,
  Lock,
  Eye,
  EyeOff,
  ArrowRight,
  ShieldCheck,
  CheckCircle2,
  Cloud,
  Sparkles,
  UserCheck,
  GraduationCap,
  Briefcase,
  KeyRound,
} from 'lucide-react';

export const LoginView = () => {
  const { loginWithEmail, loginWithGCP, registerUser } = useApp();

  const [activeTab, setActiveTab] = useState<'LOGIN' | 'REGISTER'>('LOGIN');

  // Login form state
  const [email, setEmail] = useState('admin@roombook.ac.id');
  const [password, setPassword] = useState('admin123');
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  // Register form state
  const [regName, setRegName] = useState('');
  const [regEmail, setRegEmail] = useState('');
  const [regPassword, setRegPassword] = useState('');
  const [regRole, setRegRole] = useState<UserRole>('MAHASISWA');
  const [regDepartment, setRegDepartment] = useState('');
  const [regPhone, setRegPhone] = useState('');

  // GCP SSO Modal state
  const [isGcpModalOpen, setIsGcpModalOpen] = useState(false);
  const [customGcpEmail, setCustomGcpEmail] = useState('user.google@campus.ac.id');
  const [customGcpName, setCustomGcpName] = useState('Akun Google Kampus');

  const handleLoginSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    setTimeout(() => {
      loginWithEmail(email, password);
      setIsLoading(false);
    }, 400);
  };

  const handleRegisterSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!regName || !regEmail || !regPassword) {
      alert('Mohon lengkapi seluruh field wajib pendaftaran.');
      return;
    }
    setIsLoading(true);
    setTimeout(() => {
      const res = registerUser({
        name: regName,
        email: regEmail,
        password: regPassword,
        role: regRole,
        department: regDepartment || 'Civitas Akademika Kampus',
        phone: regPhone || undefined,
        avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
      });
      setIsLoading(false);
      if (res.success) {
        setActiveTab('LOGIN');
      }
    }, 400);
  };

  const handleQuickFill = (accEmail: string, accPass: string) => {
    setEmail(accEmail);
    setPassword(accPass);
    setActiveTab('LOGIN');
  };

  return (
    <div className="min-h-screen bg-slate-900 flex items-center justify-center p-4 sm:p-6 lg:p-8 font-sans">
      <div className="max-w-5xl w-full bg-white dark:bg-slate-900 rounded-3xl shadow-2xl border border-slate-200/80 dark:border-slate-800 overflow-hidden grid grid-cols-1 lg:grid-cols-12 min-h-[640px]">
        {/* Left Side: Brand & Feature Showcase (5 cols on lg) */}
        <div className="lg:col-span-5 bg-gradient-to-br from-indigo-700 via-indigo-600 to-sky-700 p-8 sm:p-10 text-white flex flex-col justify-between relative overflow-hidden">
          <div className="space-y-6 relative z-10">
            {/* Logo */}
            <div className="flex items-center gap-3">
              <div className="w-12 h-12 rounded-2xl bg-white text-indigo-700 flex items-center justify-center shadow-lg font-black text-xl">
                <Building2 className="w-6 h-6" />
              </div>
              <div>
                <span className="text-xl font-black tracking-tight block">RoomBook</span>
                <span className="text-xs text-indigo-200">Sistem Booking Ruangan Terpadu</span>
              </div>
            </div>

            {/* Headline */}
            <div className="space-y-3 pt-4">
              <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-white/15 backdrop-blur-md text-xs font-semibold">
                <Sparkles className="w-3.5 h-3.5 text-yellow-300" />
                Prototipe Resmi v1.0 (MVP)
              </div>
              <h2 className="text-2xl sm:text-3xl font-black leading-tight tracking-tight">
                Pengecekan Ketersediaan, Reservasi, dan Persetujuan Mudah.
              </h2>
              <p className="text-xs sm:text-sm text-indigo-100 leading-relaxed">
                Platform terpusat civitas akademika untuk meminjam fasilitas ruangan kampus tanpa risiko bentrok jadwal.
              </p>
            </div>

            {/* Feature Highlights */}
            <div className="space-y-3 pt-2 text-xs">
              <div className="flex items-center gap-3 bg-white/10 p-3 rounded-2xl backdrop-blur-sm border border-white/10">
                <CheckCircle2 className="w-5 h-5 text-emerald-300 flex-shrink-0" />
                <span>Validasi Otomatis Pencegah Bentrok Jadwal</span>
              </div>
              <div className="flex items-center gap-3 bg-white/10 p-3 rounded-2xl backdrop-blur-sm border border-white/10">
                <Cloud className="w-5 h-5 text-sky-300 flex-shrink-0" />
                <span>Mendukung Single Sign-On (SSO) Google Cloud (GCP)</span>
              </div>
              <div className="flex items-center gap-3 bg-white/10 p-3 rounded-2xl backdrop-blur-sm border border-white/10">
                <ShieldCheck className="w-5 h-5 text-amber-300 flex-shrink-0" />
                <span>Otorisasi Berbasis Role (Admin, Dosen, Mahasiswa, Staf)</span>
              </div>
            </div>
          </div>

          <div className="pt-8 text-xs text-indigo-200 relative z-10">
            &copy; 2026 Kampus Terpadu • RoomBook Management
          </div>

          {/* Ambient circles */}
          <div className="absolute -top-12 -right-12 w-64 h-64 rounded-full bg-white/10 blur-3xl pointer-events-none" />
          <div className="absolute -bottom-16 -left-16 w-64 h-64 rounded-full bg-indigo-500/30 blur-3xl pointer-events-none" />
        </div>

        {/* Right Side: Authentication Panel (7 cols on lg) */}
        <div className="lg:col-span-7 p-6 sm:p-10 flex flex-col justify-between space-y-6">
          <div className="space-y-6">
            {/* Tabs Header */}
            <div className="flex items-center justify-between border-b border-slate-100 dark:border-slate-800 pb-3">
              <div className="flex items-center gap-2">
                <button
                  type="button"
                  onClick={() => setActiveTab('LOGIN')}
                  className={`px-4 py-2 text-xs font-bold rounded-xl transition-all ${
                    activeTab === 'LOGIN'
                      ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/20'
                      : 'text-slate-500 hover:text-slate-900 dark:hover:text-white'
                  }`}
                >
                  Masuk (Sign In)
                </button>
                <button
                  type="button"
                  onClick={() => setActiveTab('REGISTER')}
                  className={`px-4 py-2 text-xs font-bold rounded-xl transition-all ${
                    activeTab === 'REGISTER'
                      ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/20'
                      : 'text-slate-500 hover:text-slate-900 dark:hover:text-white'
                  }`}
                >
                  Daftar Akun Baru
                </button>
              </div>

              <span className="text-[11px] text-slate-400 font-semibold hidden sm:inline">
                Akses Terproteksi
              </span>
            </div>

            {/* METHOD 1: GCP GOOGLE SSO BUTTON */}
            <div className="space-y-2">
              <button
                type="button"
                onClick={() => setIsGcpModalOpen(true)}
                className="w-full py-3 px-4 rounded-2xl border-2 border-slate-200 dark:border-slate-700 hover:border-indigo-500 hover:bg-slate-50 dark:hover:bg-slate-800/80 transition-all flex items-center justify-center gap-3 shadow-sm group"
              >
                {/* Official Google G Logo SVG */}
                <svg className="w-5 h-5 flex-shrink-0" viewBox="0 0 24 24">
                  <path
                    fill="#4285F4"
                    d="M23.745 12.27c0-.7-.06-1.4-.19-2.07H12v4.51h6.6c-.29 1.52-1.14 2.82-2.4 3.68v3.05h3.88c2.27-2.09 3.66-5.17 3.66-9.17z"
                  />
                  <path
                    fill="#34A853"
                    d="M12 24c3.24 0 5.95-1.08 7.93-2.91l-3.88-3.05c-1.08.72-2.45 1.16-4.05 1.16-3.12 0-5.77-2.1-6.72-4.93H1.25v3.15C3.26 21.36 7.34 24 12 24z"
                  />
                  <path
                    fill="#FBBC05"
                    d="M5.28 14.27c-.25-.72-.38-1.49-.38-2.27s.13-1.55.38-2.27V6.58H1.25C.45 8.18 0 9.98 0 12s.45 3.82 1.25 5.42l4.03-3.15z"
                  />
                  <path
                    fill="#EA4335"
                    d="M12 4.75c1.77 0 3.35.61 4.6 1.8l3.42-3.42C17.95 1.19 15.24 0 12 0 7.34 0 3.26 2.64 1.25 6.58l4.03 3.15c.95-2.83 3.6-4.98 6.72-4.98z"
                  />
                </svg>

                <div className="text-left flex-1">
                  <div className="text-xs font-bold text-slate-800 dark:text-slate-100 flex items-center gap-1.5">
                    <span>Masuk dengan Akun Google / GCP Workspace</span>
                    <span className="px-1.5 py-0.2 rounded text-[9px] font-extrabold bg-blue-100 text-blue-800 dark:bg-blue-950/60 dark:text-blue-300">
                      GCP SSO
                    </span>
                  </div>
                  <div className="text-[10px] text-slate-400">
                    Gunakan email domain institusi (@campus.ac.id)
                  </div>
                </div>

                <ArrowRight className="w-4 h-4 text-slate-400 group-hover:text-indigo-600 group-hover:translate-x-1 transition-all" />
              </button>

              <div className="relative flex items-center justify-center py-2">
                <div className="border-t border-slate-200 dark:border-slate-800 w-full" />
                <span className="bg-white dark:bg-slate-900 px-3 text-[11px] font-semibold text-slate-400 uppercase tracking-wider absolute">
                  atau gunakan email & kata sandi
                </span>
              </div>
            </div>

            {/* METHOD 2: EMAIL & PASSWORD FORM */}
            {activeTab === 'LOGIN' ? (
              <form onSubmit={handleLoginSubmit} className="space-y-4">
                <div className="space-y-1.5">
                  <label className="text-xs font-bold text-slate-700 dark:text-slate-300">
                    Alamat Email Institusi
                  </label>
                  <div className="relative">
                    <Mail className="w-4 h-4 text-slate-400 absolute left-3.5 top-3" />
                    <input
                      type="email"
                      required
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      placeholder="nama@roombook.ac.id"
                      className="w-full pl-10 pr-3 py-2.5 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
                    />
                  </div>
                </div>

                <div className="space-y-1.5">
                  <div className="flex items-center justify-between">
                    <label className="text-xs font-bold text-slate-700 dark:text-slate-300">
                      Kata Sandi
                    </label>
                    <button
                      type="button"
                      onClick={() => alert('Untuk prototipe ini, Anda dapat menggunakan akun demo di bawah dengan password standar (misal: admin123, mhs123).')}
                      className="text-[11px] text-indigo-600 hover:underline"
                    >
                      Lupa kata sandi?
                    </button>
                  </div>
                  <div className="relative">
                    <Lock className="w-4 h-4 text-slate-400 absolute left-3.5 top-3" />
                    <input
                      type={showPassword ? 'text' : 'password'}
                      required
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      placeholder="Masukkan kata sandi"
                      className="w-full pl-10 pr-10 py-2.5 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-indigo-500"
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute right-3.5 top-3 text-slate-400 hover:text-slate-600"
                    >
                      {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                    </button>
                  </div>
                </div>

                <button
                  type="submit"
                  disabled={isLoading}
                  className="w-full py-3 rounded-2xl bg-indigo-600 hover:bg-indigo-700 text-white font-bold text-xs shadow-lg shadow-indigo-600/25 transition-all flex items-center justify-center gap-2"
                >
                  {isLoading ? (
                    <span className="animate-spin w-4 h-4 border-2 border-white border-t-transparent rounded-full" />
                  ) : (
                    <>
                      <span>Masuk ke RoomBook</span>
                      <ArrowRight className="w-4 h-4" />
                    </>
                  )}
                </button>
              </form>
            ) : (
              /* REGISTRATION FORM */
              <form onSubmit={handleRegisterSubmit} className="space-y-3">
                <div className="grid grid-cols-2 gap-3">
                  <div className="space-y-1">
                    <label className="text-[11px] font-bold text-slate-700 dark:text-slate-300">
                      Nama Lengkap *
                    </label>
                    <input
                      type="text"
                      required
                      value={regName}
                      onChange={(e) => setRegName(e.target.value)}
                      placeholder="Nama lengkap"
                      className="w-full px-3 py-2 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700"
                    />
                  </div>

                  <div className="space-y-1">
                    <label className="text-[11px] font-bold text-slate-700 dark:text-slate-300">
                      Role Civitas *
                    </label>
                    <select
                      value={regRole}
                      onChange={(e) => setRegRole(e.target.value as UserRole)}
                      className="w-full px-3 py-2 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 font-semibold"
                    >
                      <option value="MAHASISWA">Mahasiswa</option>
                      <option value="DOSEN">Dosen</option>
                      <option value="STAF">Staf Administrasi</option>
                      <option value="ADMIN">Administrator</option>
                    </select>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div className="space-y-1">
                    <label className="text-[11px] font-bold text-slate-700 dark:text-slate-300">
                      Email Institusi *
                    </label>
                    <input
                      type="email"
                      required
                      value={regEmail}
                      onChange={(e) => setRegEmail(e.target.value)}
                      placeholder="email@kampus.ac.id"
                      className="w-full px-3 py-2 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700"
                    />
                  </div>

                  <div className="space-y-1">
                    <label className="text-[11px] font-bold text-slate-700 dark:text-slate-300">
                      Kata Sandi *
                    </label>
                    <input
                      type="password"
                      required
                      value={regPassword}
                      onChange={(e) => setRegPassword(e.target.value)}
                      placeholder="Minimal 6 karakter"
                      className="w-full px-3 py-2 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700"
                    />
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-3">
                  <div className="space-y-1">
                    <label className="text-[11px] font-bold text-slate-700 dark:text-slate-300">
                      Unit / Jurusan
                    </label>
                    <input
                      type="text"
                      value={regDepartment}
                      onChange={(e) => setRegDepartment(e.target.value)}
                      placeholder="Contoh: Teknik Informatika"
                      className="w-full px-3 py-2 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700"
                    />
                  </div>

                  <div className="space-y-1">
                    <label className="text-[11px] font-bold text-slate-700 dark:text-slate-300">
                      Nomor WhatsApp
                    </label>
                    <input
                      type="text"
                      value={regPhone}
                      onChange={(e) => setRegPhone(e.target.value)}
                      placeholder="0812-xxxx-xxxx"
                      className="w-full px-3 py-2 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700"
                    />
                  </div>
                </div>

                <button
                  type="submit"
                  disabled={isLoading}
                  className="w-full py-2.5 mt-2 rounded-2xl bg-indigo-600 hover:bg-indigo-700 text-white font-bold text-xs shadow-md transition-all"
                >
                  {isLoading ? 'Mendaftarkan...' : 'Daftar & Masuk Otomatis'}
                </button>
              </form>
            )}
          </div>

          {/* Quick-Fill Demo Accounts Box for Evaluators */}
          <div className="p-4 rounded-2xl bg-slate-50 dark:bg-slate-800/60 border border-slate-200/80 dark:border-slate-700 space-y-2">
            <div className="flex items-center justify-between">
              <span className="text-[11px] font-bold uppercase tracking-wider text-slate-500 flex items-center gap-1.5">
                <KeyRound className="w-3.5 h-3.5 text-indigo-500" />
                Akun Demo Evaluasi (1-Click Quick Fill):
              </span>
              <span className="text-[10px] text-slate-400">Klik untuk isi otomatis</span>
            </div>

            <div className="grid grid-cols-2 sm:grid-cols-4 gap-1.5 text-[10px]">
              <button
                type="button"
                onClick={() => handleQuickFill('admin@roombook.ac.id', 'admin123')}
                className="p-2 rounded-xl bg-white dark:bg-slate-700 border border-slate-200 dark:border-slate-600 text-left hover:border-rose-400 transition-colors"
              >
                <div className="font-bold text-rose-600">👑 Admin</div>
                <div className="text-slate-400 truncate">admin123</div>
              </button>

              <button
                type="button"
                onClick={() => handleQuickFill('dosen@roombook.ac.id', 'dosen123')}
                className="p-2 rounded-xl bg-white dark:bg-slate-700 border border-slate-200 dark:border-slate-600 text-left hover:border-indigo-400 transition-colors"
              >
                <div className="font-bold text-indigo-600">🎓 Dosen</div>
                <div className="text-slate-400 truncate">dosen123</div>
              </button>

              <button
                type="button"
                onClick={() => handleQuickFill('mahasiswa@roombook.ac.id', 'mhs123')}
                className="p-2 rounded-xl bg-white dark:bg-slate-700 border border-slate-200 dark:border-slate-600 text-left hover:border-emerald-400 transition-colors"
              >
                <div className="font-bold text-emerald-600">🤝 Mahasiswa</div>
                <div className="text-slate-400 truncate">mhs123</div>
              </button>

              <button
                type="button"
                onClick={() => handleQuickFill('staf@roombook.ac.id', 'staf123')}
                className="p-2 rounded-xl bg-white dark:bg-slate-700 border border-slate-200 dark:border-slate-600 text-left hover:border-amber-400 transition-colors"
              >
                <div className="font-bold text-amber-600">💼 Staf</div>
                <div className="text-slate-400 truncate">staf123</div>
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* GCP Google SSO Simulation Modal */}
      {isGcpModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/70 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="bg-white dark:bg-slate-900 rounded-3xl max-w-md w-full p-6 sm:p-7 space-y-5 border border-slate-200 dark:border-slate-800 shadow-2xl relative">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-2xl bg-blue-50 text-blue-600 flex items-center justify-center font-bold">
                <Cloud className="w-5 h-5" />
              </div>
              <div>
                <h3 className="text-base font-black text-slate-900 dark:text-white">
                  Google Cloud Platform (GCP) SSO
                </h3>
                <p className="text-xs text-slate-400">
                  Autentikasi terpadu OAuth 2.0 / Google Workspace
                </p>
              </div>
            </div>

            <p className="text-xs text-slate-600 dark:text-slate-300 leading-relaxed">
              Sistem akan memverifikasi identitas Anda melalui <strong>Google Cloud Identity / Workspace Kampus</strong>.
            </p>

            <div className="space-y-3 text-xs">
              <div className="space-y-1">
                <label className="font-bold text-slate-700 dark:text-slate-300">
                  Nama Akun Google
                </label>
                <input
                  type="text"
                  value={customGcpName}
                  onChange={(e) => setCustomGcpName(e.target.value)}
                  className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 font-semibold"
                />
              </div>

              <div className="space-y-1">
                <label className="font-bold text-slate-700 dark:text-slate-300">
                  Email Akun Google / GCP
                </label>
                <input
                  type="email"
                  value={customGcpEmail}
                  onChange={(e) => setCustomGcpEmail(e.target.value)}
                  className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 font-semibold"
                />
              </div>
            </div>

            <div className="p-3 rounded-xl bg-blue-50/60 dark:bg-blue-950/30 border border-blue-100 dark:border-blue-900/50 text-[11px] text-blue-800 dark:text-blue-300">
              💡 <strong>Catatan Teknis:</strong> Kredensial OAuth GCP dapat dikonfigurasi melalui variabel lingkungan <code>GOOGLE_CLIENT_ID</code> dan <code>GOOGLE_CLIENT_SECRET</code> di file <code>.env.local</code>.
            </div>

            <div className="flex items-center gap-3 pt-2">
              <button
                type="button"
                onClick={() => setIsGcpModalOpen(false)}
                className="flex-1 py-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-bold transition-colors"
              >
                Batal
              </button>
              <button
                type="button"
                onClick={() => {
                  loginWithGCP({
                    name: customGcpName,
                    email: customGcpEmail,
                    avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
                  });
                  setIsGcpModalOpen(false);
                }}
                className="flex-1 py-2.5 rounded-xl bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold shadow-md shadow-blue-600/20 transition-colors flex items-center justify-center gap-1.5"
              >
                <Cloud className="w-3.5 h-3.5" />
                <span>Masuk Sekarang</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
