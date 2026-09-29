'use client';

import React from 'react';
import { useApp } from '@/context/AppContext';
import {
  LayoutDashboard,
  Building,
  CalendarDays,
  PlusCircle,
  Clock3,
  CheckSquare2,
  Settings2,
  BarChart3,
  BookOpen,
  RotateCcw,
  Sparkles,
} from 'lucide-react';

interface SidebarProps {
  isOpenMobile?: boolean;
  onCloseMobile?: () => void;
}

export const Sidebar = ({ isOpenMobile, onCloseMobile }: SidebarProps) => {
  const { currentUser, activeTab, setActiveTab, reservations, resetAllData } = useApp();

  const pendingApprovalsCount = reservations.filter((r) => r.status === 'PENDING').length;
  const myPendingCount = reservations.filter(
    (r) => r.userId === currentUser.id && r.status === 'PENDING'
  ).length;

  const handleNavClick = (tabKey: string) => {
    setActiveTab(tabKey);
    if (onCloseMobile) onCloseMobile();
  };

  const navItems = [
    {
      key: 'dashboard',
      label: 'Dashboard',
      icon: <LayoutDashboard className="w-4 h-4" />,
      badge: null,
      adminOnly: false,
    },
    {
      key: 'catalog',
      label: 'Katalog Ruangan',
      icon: <Building className="w-4 h-4" />,
      badge: null,
      adminOnly: false,
    },
    {
      key: 'availability',
      label: 'Cek Ketersediaan',
      icon: <CalendarDays className="w-4 h-4" />,
      badge: null,
      adminOnly: false,
    },
    {
      key: 'new_booking',
      label: 'Formulir Reservasi',
      icon: <PlusCircle className="w-4 h-4" />,
      badge: null,
      adminOnly: false,
    },
    {
      key: 'my_bookings',
      label: 'Reservasi Saya',
      icon: <Clock3 className="w-4 h-4" />,
      badge: myPendingCount > 0 ? `${myPendingCount} Pending` : null,
      badgeColor: 'bg-amber-100 text-amber-800 dark:bg-amber-950/60 dark:text-amber-300',
      adminOnly: false,
    },
    // Admin Only Items
    {
      key: 'approvals',
      label: 'Persetujuan Reservasi',
      icon: <CheckSquare2 className="w-4 h-4" />,
      badge: pendingApprovalsCount > 0 ? `${pendingApprovalsCount} Antrean` : null,
      badgeColor: 'bg-rose-500 text-white font-bold animate-pulse',
      adminOnly: true,
    },
    {
      key: 'room_management',
      label: 'Kelola Ruangan',
      icon: <Settings2 className="w-4 h-4" />,
      badge: null,
      adminOnly: true,
    },
    {
      key: 'reports',
      label: 'Laporan & Statistik',
      icon: <BarChart3 className="w-4 h-4" />,
      badge: null,
      adminOnly: true,
    },
    // General
    {
      key: 'docs',
      label: 'Dokumentasi Sistem',
      icon: <BookOpen className="w-4 h-4" />,
      badge: '14 Docs',
      badgeColor: 'bg-indigo-100 text-indigo-700 dark:bg-indigo-950/60 dark:text-indigo-300',
      adminOnly: false,
    },
  ];

  return (
    <>
      {/* Mobile backdrop */}
      {isOpenMobile && (
        <div
          onClick={onCloseMobile}
          className="fixed inset-0 bg-slate-900/50 backdrop-blur-sm z-40 lg:hidden"
        />
      )}

      <aside
        className={`fixed top-16 bottom-0 left-0 z-40 w-64 bg-white dark:bg-slate-900 border-r border-slate-200 dark:border-slate-800 flex flex-col justify-between transition-transform duration-200 lg:translate-x-0 ${
          isOpenMobile ? 'translate-x-0' : '-translate-x-full'
        }`}
      >
        <div className="p-4 space-y-6 overflow-y-auto">
          {/* Role Status Tag */}
          <div className="p-3 rounded-xl bg-gradient-to-r from-slate-50 to-indigo-50/50 dark:from-slate-800/50 dark:to-indigo-950/30 border border-slate-200/80 dark:border-slate-700/60">
            <div className="text-[11px] font-bold uppercase tracking-wider text-slate-400 mb-1">
              Mode Akses Aktif
            </div>
            <div className="flex items-center justify-between">
              <span className="text-xs font-extrabold text-slate-800 dark:text-slate-200 flex items-center gap-1.5">
                <Sparkles className="w-3.5 h-3.5 text-indigo-500" />
                {currentUser.role === 'ADMIN' ? 'Administrator' : currentUser.role}
              </span>
              <span className="text-[10px] px-2 py-0.5 rounded-full bg-indigo-600 text-white font-semibold">
                Online
              </span>
            </div>
          </div>

          {/* Navigation Links */}
          <nav className="space-y-1">
            <div className="text-[11px] font-bold uppercase tracking-wider text-slate-400 px-3 py-1">
              Menu Navigasi
            </div>
            {navItems.map((item) => {
              if (item.adminOnly && currentUser.role !== 'ADMIN') return null;

              const isActive = activeTab === item.key;
              return (
                <button
                  key={item.key}
                  onClick={() => handleNavClick(item.key)}
                  className={`w-full flex items-center justify-between px-3 py-2.5 rounded-xl text-xs font-semibold transition-all duration-150 group ${
                    isActive
                      ? 'bg-indigo-600 text-white shadow-md shadow-indigo-600/25'
                      : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white hover:bg-slate-100 dark:hover:bg-slate-800/70'
                  }`}
                >
                  <div className="flex items-center gap-2.5">
                    <span
                      className={`transition-colors ${
                        isActive
                          ? 'text-white'
                          : 'text-slate-400 group-hover:text-indigo-600 dark:group-hover:text-indigo-400'
                      }`}
                    >
                      {item.icon}
                    </span>
                    <span>{item.label}</span>
                  </div>

                  {item.badge && (
                    <span
                      className={`text-[10px] px-2 py-0.5 rounded-full font-bold ${
                        item.badgeColor || 'bg-slate-100 text-slate-600 dark:bg-slate-800 dark:text-slate-300'
                      }`}
                    >
                      {item.badge}
                    </span>
                  )}
                </button>
              );
            })}
          </nav>
        </div>

        {/* Footer with Reset Sample Data */}
        <div className="p-4 border-t border-slate-100 dark:border-slate-800">
          <button
            onClick={() => {
              if (confirm('Reset semua data reservasi dan ruangan ke contoh awal?')) {
                resetAllData();
              }
            }}
            className="w-full flex items-center justify-center gap-2 px-3 py-2 text-xs font-medium text-slate-500 hover:text-slate-800 dark:text-slate-400 dark:hover:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-xl transition-colors border border-dashed border-slate-300 dark:border-slate-700"
            title="Kembalikan data ke awal untuk pengujian ulang"
          >
            <RotateCcw className="w-3.5 h-3.5" />
            <span>Reset Data Sampel</span>
          </button>
          <div className="mt-2 text-center text-[10px] text-slate-400">
            RoomBook Prototype &copy; 2026
          </div>
        </div>
      </aside>
    </>
  );
};
