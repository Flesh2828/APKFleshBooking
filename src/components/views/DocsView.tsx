'use client';

import React, { useState } from 'react';
import {
  BookOpen,
  FileText,
  Code2,
  Database,
  Layers,
  Shield,
  CheckSquare,
  Compass,
  GitBranch,
  Rocket,
  Server,
  Users,
  ChevronRight,
  ExternalLink,
} from 'lucide-react';

interface DocItem {
  id: string;
  name: string;
  category: 'Disarankan' | 'Opsional';
  icon: React.ReactNode;
  summary: string;
  path: string;
}

export const DocsView = () => {
  const docsList: DocItem[] = [
    {
      id: 'README',
      name: 'README.md',
      category: 'Disarankan',
      icon: <BookOpen className="w-4 h-4 text-indigo-500" />,
      summary: 'Penjelasan utama proyek, tujuan pembuatan, dan petunjuk cara menjalankannya secara lokal.',
      path: 'docs/README.md',
    },
    {
      id: 'PRD',
      name: 'PRD.md',
      category: 'Disarankan',
      icon: <FileText className="w-4 h-4 text-sky-500" />,
      summary: 'Product Requirements Document lengkap: latar belakang, persona pengguna, ruang lingkup MVP, dan KPI.',
      path: 'docs/PRD.md',
    },
    {
      id: 'TECH_STACK',
      name: 'TECH_STACK.md',
      category: 'Disarankan',
      icon: <Code2 className="w-4 h-4 text-emerald-500" />,
      summary: 'Teknologi yang digunakan (TypeScript, Next.js, React, Tailwind, Prisma) serta alasan pemilihannya.',
      path: 'docs/TECH_STACK.md',
    },
    {
      id: 'ARCHITECTURE',
      name: 'ARCHITECTURE.md',
      category: 'Disarankan',
      icon: <Layers className="w-4 h-4 text-violet-500" />,
      summary: 'Arsitektur sistem, pembagian lapisan Presentation, Business Logic, Persistence, dan data flow diagram.',
      path: 'docs/ARCHITECTURE.md',
    },
    {
      id: 'DATABASE',
      name: 'DATABASE.md',
      category: 'Disarankan',
      icon: <Database className="w-4 h-4 text-amber-500" />,
      summary: 'Struktur database, kamus data tabel (users, rooms, reservations, logs, notif), relasi, dan ERD.',
      path: 'docs/DATABASE.md',
    },
    {
      id: 'UI_UX_GUIDELINES',
      name: 'UI_UX_GUIDELINES.md',
      category: 'Disarankan',
      icon: <Layers className="w-4 h-4 text-pink-500" />,
      summary: 'Panduan desain visual, palet warna, tipografi Inter, komponen status badge, dan aturan responsivitas.',
      path: 'docs/UI_UX_GUIDELINES.md',
    },
    {
      id: 'USER_FLOW',
      name: 'USER_FLOW.md',
      category: 'Disarankan',
      icon: <Users className="w-4 h-4 text-teal-500" />,
      summary: 'Alur perjalanan pengguna (Mahasiswa/Dosen/Staf) dan Administrator dalam mengajukan dan memproses pemesanan.',
      path: 'docs/USER_FLOW.md',
    },
    {
      id: 'API_DOCUMENTATION',
      name: 'API_DOCUMENTATION.md',
      category: 'Disarankan',
      icon: <Server className="w-4 h-4 text-blue-500" />,
      summary: 'Spesifikasi endpoint REST API: Rooms, Availability, Reservations, Approvals, dan Notifications.',
      path: 'docs/API_DOCUMENTATION.md',
    },
    {
      id: 'FUNCTIONAL_REQUIREMENTS',
      name: 'FUNCTIONAL_REQUIREMENTS.md',
      category: 'Opsional',
      icon: <CheckSquare className="w-4 h-4 text-indigo-500" />,
      summary: 'Rincian spesifikasi kebutuhan fungsional (FR-01 s.d FR-07) untuk seluruh modul aplikasi.',
      path: 'docs/FUNCTIONAL_REQUIREMENTS.md',
    },
    {
      id: 'SECURITY',
      name: 'SECURITY.md',
      category: 'Opsional',
      icon: <Shield className="w-4 h-4 text-red-500" />,
      summary: 'Standar autentikasi, kontrol akses berbasis role (RBAC), pencegahan race condition, dan mitigasi OWASP.',
      path: 'docs/SECURITY.md',
    },
    {
      id: 'TESTING',
      name: 'TESTING.md',
      category: 'Opsional',
      icon: <CheckSquare className="w-4 h-4 text-emerald-500" />,
      summary: 'Strategi pengujian, acceptance criteria, checklist responsivitas, dan skenario validasi bentrok jadwal.',
      path: 'docs/TESTING.md',
    },
    {
      id: 'ROADMAP',
      name: 'ROADMAP.md',
      category: 'Opsional',
      icon: <Compass className="w-4 h-4 text-orange-500" />,
      summary: 'Tahapan pengembangan 6 minggu menuju MVP serta rencana rilis masa depan (QR check-in, WA gateway).',
      path: 'docs/ROADMAP.md',
    },
    {
      id: 'CHANGELOG',
      name: 'CHANGELOG.md',
      category: 'Opsional',
      icon: <GitBranch className="w-4 h-4 text-yellow-500" />,
      summary: 'Catatan perubahan dan rilis versi aplikasi v1.0.0 (Keep a Changelog format).',
      path: 'docs/CHANGELOG.md',
    },
    {
      id: 'CONTRIBUTING',
      name: 'CONTRIBUTING.md',
      category: 'Opsional',
      icon: <Users className="w-4 h-4 text-cyan-500" />,
      summary: 'Panduan kontribusi open source, alur Git commit message, dan standar penulisan kode tim.',
      path: 'docs/CONTRIBUTING.md',
    },
    {
      id: 'DEPLOYMENT',
      name: 'DEPLOYMENT.md',
      category: 'Opsional',
      icon: <Rocket className="w-4 h-4 text-purple-500" />,
      summary: 'Panduan build, environment variables (.env), deployment ke Vercel dan VPS Linux dengan Nginx & PM2.',
      path: 'docs/DEPLOYMENT.md',
    },
  ];

  const [activeDoc, setActiveDoc] = useState<DocItem>(docsList[0]);

  return (
    <div className="space-y-6 animate-in fade-in duration-300">
      {/* Title */}
      <div>
        <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tight">
          Pusat Dokumentasi Sistem (Docs Hub)
        </h1>
        <p className="text-xs sm:text-sm text-slate-500 mt-1">
          Seluruh 15 file dokumentasi spesifikasi teknis dan produk tersimpan rapi di direktori{' '}
          <code className="px-1.5 py-0.5 rounded bg-slate-100 dark:bg-slate-800 font-mono text-indigo-600">
            roombook/docs/
          </code>
        </p>
      </div>

      {/* 2-Column Docs Browser */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Left Column: Document List Navigation */}
        <div className="p-4 rounded-3xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm space-y-3">
          <div className="flex items-center justify-between px-2 pb-2 border-b border-slate-100 dark:border-slate-800">
            <span className="text-xs font-bold uppercase tracking-wider text-slate-400">
              Daftar Dokumen
            </span>
            <span className="text-[11px] px-2 py-0.5 rounded-full bg-indigo-50 text-indigo-700 font-bold">
              15 Berkas
            </span>
          </div>

          <div className="space-y-1 max-h-[600px] overflow-y-auto pr-1">
            {docsList.map((doc) => {
              const isSelected = activeDoc.id === doc.id;

              return (
                <button
                  key={doc.id}
                  onClick={() => setActiveDoc(doc)}
                  className={`w-full text-left p-3 rounded-2xl text-xs transition-all flex items-start gap-3 ${
                    isSelected
                      ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/25'
                      : 'hover:bg-slate-50 dark:hover:bg-slate-800/60 text-slate-700 dark:text-slate-300'
                  }`}
                >
                  <div className="mt-0.5 flex-shrink-0">{doc.icon}</div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between gap-1">
                      <span className="font-bold truncate">{doc.name}</span>
                      <span
                        className={`text-[9px] px-1.5 py-0.2 rounded font-semibold ${
                          isSelected
                            ? 'bg-white/20 text-white'
                            : doc.category === 'Disarankan'
                            ? 'bg-indigo-50 text-indigo-600 dark:bg-indigo-950/40 dark:text-indigo-400'
                            : 'bg-slate-100 text-slate-500 dark:bg-slate-800'
                        }`}
                      >
                        {doc.category}
                      </span>
                    </div>
                    <p
                      className={`text-[10px] mt-0.5 line-clamp-1 ${
                        isSelected ? 'text-indigo-100' : 'text-slate-400'
                      }`}
                    >
                      {doc.summary}
                    </p>
                  </div>
                </button>
              );
            })}
          </div>
        </div>

        {/* Right Column: Document Details Card */}
        <div className="lg:col-span-2 p-6 sm:p-8 rounded-3xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm space-y-6 flex flex-col justify-between">
          <div className="space-y-4">
            <div className="flex items-center gap-3">
              <div className="p-3 rounded-2xl bg-indigo-50 dark:bg-indigo-950/50 text-indigo-600">
                {activeDoc.icon}
              </div>
              <div>
                <span className="text-[10px] uppercase font-bold tracking-wider text-indigo-500">
                  {activeDoc.category}
                </span>
                <h2 className="text-xl font-black text-slate-900 dark:text-white">
                  {activeDoc.name}
                </h2>
              </div>
            </div>

            <div className="p-4 rounded-2xl bg-slate-50 dark:bg-slate-800/50 border border-slate-100 dark:border-slate-700/60 text-xs text-slate-600 dark:text-slate-300 space-y-2">
              <span className="font-bold text-slate-800 dark:text-slate-200 block">
                Ringkasan Isi Dokumen:
              </span>
              <p className="leading-relaxed">{activeDoc.summary}</p>
            </div>

            <div className="space-y-2 text-xs">
              <span className="font-bold text-slate-700 dark:text-slate-300 block">
                Lokasi File Fisik di Repositori:
              </span>
              <div className="p-3 rounded-xl bg-slate-900 text-slate-100 font-mono text-xs flex items-center justify-between">
                <span>{activeDoc.path}</span>
                <span className="text-emerald-400 text-[10px]">Tersedia (Ready)</span>
              </div>
            </div>

            <div className="p-4 rounded-2xl bg-indigo-50/50 dark:bg-indigo-950/20 border border-indigo-100 dark:border-indigo-900/40 text-xs text-slate-600 dark:text-slate-400 space-y-2">
              <h4 className="font-bold text-indigo-950 dark:text-indigo-200 flex items-center gap-1.5">
                <CheckSquare className="w-4 h-4 text-indigo-600" />
                Kesesuaian dengan Dokumen Panduan & PRD:
              </h4>
              <p className="leading-relaxed text-[11px]">
                Dokumen ini disusun mengikuti kaidah teknis yang tertuang dalam dokumen resmi <strong>RoomBook Product Requirements Document (PRD v1.0)</strong> dan panduan <strong>Technology & Programming Languages</strong>.
              </p>
            </div>
          </div>

          <div className="pt-4 border-t border-slate-100 dark:border-slate-800 flex items-center justify-between text-xs text-slate-400">
            <span>Dibuat dalam format GitHub Markdown standar</span>
            <span className="font-semibold text-slate-600 dark:text-slate-300">RoomBook Docs v1.0</span>
          </div>
        </div>
      </div>
    </div>
  );
};
