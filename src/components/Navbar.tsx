'use client';

import React, { useState } from 'react';
import { useApp } from '@/context/AppContext';
import { UserRole } from '@/types';
import { NotificationDropdown } from './NotificationDropdown';
import {
  Bell,
  Building2,
  ShieldCheck,
  GraduationCap,
  Briefcase,
  UserCheck,
  ChevronDown,
  Menu,
  LogOut,
  Cloud,
} from 'lucide-react';

interface NavbarProps {
  onToggleSidebar?: () => void;
}

export const Navbar = ({ onToggleSidebar }: NavbarProps) => {
  const { currentUser, switchRole, unreadNotifCount, logout } = useApp();
  const [isNotifOpen, setIsNotifOpen] = useState(false);
  const [isRoleDropdownOpen, setIsRoleDropdownOpen] = useState(false);

  const roles: { role: UserRole; label: string; desc: string; icon: React.ReactNode }[] = [
    {
      role: 'ADMIN',
      label: 'Administrator',
      desc: 'Kelola ruangan & persetujuan',
      icon: <ShieldCheck className="w-4 h-4 text-rose-500" />,
    },
    {
      role: 'DOSEN',
      label: 'Dosen',
      desc: 'Reservasi perkuliahan & riset',
      icon: <GraduationCap className="w-4 h-4 text-indigo-500" />,
    },
    {
      role: 'MAHASISWA',
      label: 'Mahasiswa (BEM)',
      desc: 'Reservasi ormawa & kegiatan',
      icon: <UserCheck className="w-4 h-4 text-emerald-500" />,
    },
    {
      role: 'STAF',
      label: 'Staf / BAAK',
      desc: 'Reservasi rapat departemen',
      icon: <Briefcase className="w-4 h-4 text-amber-500" />,
    },
  ];

  const getRoleBadge = (role: UserRole) => {
    switch (role) {
      case 'ADMIN':
        return 'bg-rose-100 text-rose-700 dark:bg-rose-950/60 dark:text-rose-300 border-rose-200';
      case 'DOSEN':
        return 'bg-indigo-100 text-indigo-700 dark:bg-indigo-950/60 dark:text-indigo-300 border-indigo-200';
      case 'MAHASISWA':
        return 'bg-emerald-100 text-emerald-700 dark:bg-emerald-950/60 dark:text-emerald-300 border-emerald-200';
      case 'STAF':
        return 'bg-amber-100 text-amber-700 dark:bg-amber-950/60 dark:text-amber-300 border-amber-200';
    }
  };

  return (
    <header className="sticky top-0 z-30 w-full bg-white/80 dark:bg-slate-900/80 backdrop-blur-md border-b border-slate-200 dark:border-slate-800 transition-all">
      <div className="px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between gap-4">
        {/* Left Side: Brand Logo and Mobile Menu */}
        <div className="flex items-center gap-3">
          <button
            onClick={onToggleSidebar}
            className="lg:hidden p-2 rounded-xl text-slate-500 hover:text-slate-800 hover:bg-slate-100 dark:text-slate-400 dark:hover:bg-slate-800 transition-colors"
            title="Buka Navigasi"
          >
            <Menu className="w-5 h-5" />
          </button>

          <div className="flex items-center gap-2.5">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-tr from-indigo-600 via-indigo-500 to-sky-400 flex items-center justify-center shadow-lg shadow-indigo-500/25 text-white">
              <Building2 className="w-5 h-5" />
            </div>
            <div>
              <div className="flex items-center gap-2">
                <span className="font-extrabold text-lg tracking-tight bg-gradient-to-r from-slate-900 to-indigo-900 dark:from-white dark:to-indigo-200 bg-clip-text text-transparent">
                  RoomBook
                </span>
                <span className="px-1.5 py-0.5 text-[10px] font-bold rounded-md bg-indigo-50 text-indigo-600 dark:bg-indigo-950/50 dark:text-indigo-400 border border-indigo-200/50 dark:border-indigo-800/50">
                  MVP v1.0
                </span>
              </div>
              <p className="text-[11px] text-slate-500 dark:text-slate-400 hidden sm:block">
                Sistem Booking & Manajemen Ruangan Terpadu
              </p>
            </div>
          </div>
        </div>

        {/* Center / Right: Quick Role Switcher & Notifications & Profile */}
        <div className="flex items-center gap-2 sm:gap-4">
          {/* Quick Role Switcher Pill */}
          <div className="relative">
            <div className="hidden sm:flex items-center p-1 rounded-xl bg-slate-100 dark:bg-slate-800 border border-slate-200 dark:border-slate-700/60">
              <span className="text-[11px] font-semibold text-slate-500 px-2 flex items-center gap-1">
                Role:
              </span>
              {roles.map((r) => {
                const isActive = currentUser.role === r.role;
                return (
                  <button
                    key={r.role}
                    onClick={() => switchRole(r.role)}
                    className={`px-2.5 py-1 text-xs font-semibold rounded-lg transition-all duration-150 flex items-center gap-1.5 ${
                      isActive
                        ? 'bg-white dark:bg-slate-700 text-slate-900 dark:text-white shadow-sm ring-1 ring-slate-200 dark:ring-slate-600'
                        : 'text-slate-600 dark:text-slate-300 hover:text-slate-900 hover:bg-white/50 dark:hover:bg-slate-700/40'
                    }`}
                  >
                    {r.icon}
                    <span>{r.label.split(' ')[0]}</span>
                  </button>
                );
              })}
            </div>

            {/* Mobile Role Switcher Dropdown */}
            <div className="sm:hidden relative">
              <button
                onClick={() => setIsRoleDropdownOpen(!isRoleDropdownOpen)}
                className={`px-3 py-1.5 text-xs font-semibold rounded-lg border flex items-center gap-1.5 ${getRoleBadge(
                  currentUser.role
                )}`}
              >
                <span>{currentUser.role}</span>
                <ChevronDown className="w-3.5 h-3.5" />
              </button>

              {isRoleDropdownOpen && (
                <div className="absolute right-0 top-10 w-56 bg-white dark:bg-slate-900 rounded-xl shadow-xl border border-slate-200 dark:border-slate-800 p-1 z-50">
                  <div className="px-3 py-1.5 text-[11px] font-bold text-slate-400">
                    Beralih Peran (Role Switcher)
                  </div>
                  {roles.map((r) => (
                    <button
                      key={r.role}
                      onClick={() => {
                        switchRole(r.role);
                        setIsRoleDropdownOpen(false);
                      }}
                      className="w-full text-left px-3 py-2 text-xs rounded-lg hover:bg-slate-50 dark:hover:bg-slate-800 flex items-center gap-2"
                    >
                      {r.icon}
                      <div>
                        <div className="font-semibold text-slate-800 dark:text-slate-200">{r.label}</div>
                        <div className="text-[10px] text-slate-400">{r.desc}</div>
                      </div>
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* In-app Notification Bell */}
          <div className="relative">
            <button
              onClick={() => setIsNotifOpen(!isNotifOpen)}
              className="relative p-2.5 rounded-xl text-slate-600 hover:text-slate-900 hover:bg-slate-100 dark:text-slate-300 dark:hover:text-white dark:hover:bg-slate-800 transition-colors"
              title="Notifikasi"
            >
              <Bell className="w-5 h-5" />
              {unreadNotifCount > 0 && (
                <span className="absolute top-1.5 right-1.5 min-w-[18px] h-[18px] px-1 bg-rose-500 text-white text-[10px] font-extrabold rounded-full flex items-center justify-center ring-2 ring-white dark:ring-slate-900 animate-pulse">
                  {unreadNotifCount}
                </span>
              )}
            </button>
            <NotificationDropdown isOpen={isNotifOpen} onClose={() => setIsNotifOpen(false)} />
          </div>

          {/* User Profile Summary & Logout */}
          <div className="flex items-center gap-3 pl-2 sm:pl-3 border-l border-slate-200 dark:border-slate-800">
            <div className="relative">
              <img
                src={currentUser.avatarUrl || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80'}
                alt={currentUser.name}
                className="w-9 h-9 rounded-full object-cover ring-2 ring-indigo-500/30"
              />
              {currentUser.authProvider === 'GCP_GOOGLE' && (
                <span
                  title="Masuk via GCP Google SSO"
                  className="absolute -bottom-1 -right-1 w-4 h-4 rounded-full bg-blue-600 text-white flex items-center justify-center text-[9px] shadow"
                >
                  <Cloud className="w-2.5 h-2.5" />
                </span>
              )}
            </div>

            <div className="hidden md:block text-left">
              <div className="text-xs font-bold text-slate-800 dark:text-slate-100 leading-tight flex items-center gap-1.5">
                <span>{currentUser.name}</span>
                {currentUser.authProvider === 'GCP_GOOGLE' && (
                  <span className="px-1.5 py-0.2 rounded text-[9px] font-bold bg-blue-100 text-blue-700">
                    GCP
                  </span>
                )}
              </div>
              <div className="flex items-center gap-1.5 mt-0.5">
                <span
                  className={`px-1.5 py-0.2 text-[10px] font-bold rounded border ${getRoleBadge(
                    currentUser.role
                  )}`}
                >
                  {currentUser.role}
                </span>
                <span className="text-[10px] text-slate-400 truncate max-w-[120px]">
                  {currentUser.department}
                </span>
              </div>
            </div>

            {/* Logout Button */}
            <button
              onClick={() => {
                if (confirm('Apakah Anda yakin ingin keluar (Logout)?')) {
                  logout();
                }
              }}
              className="p-2 rounded-xl text-slate-400 hover:text-rose-600 hover:bg-rose-50 dark:hover:bg-rose-950/30 transition-colors"
              title="Keluar (Logout)"
            >
              <LogOut className="w-4 h-4" />
            </button>
          </div>
        </div>
      </div>
    </header>
  );
};
