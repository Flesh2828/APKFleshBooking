'use client';

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { User, Room, Reservation, ReservationLog, InAppNotification } from '@/types';
import { StorageService } from '@/lib/storage';
import { INITIAL_USERS } from '@/lib/data';

interface Toast {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info';
  message: string;
}

interface AppContextType {
  currentUser: User;
  allUsers: User[];
  isAuthenticated: boolean;
  loginWithEmail: (email: string, password: string) => { success: boolean; error?: string };
  loginWithGCP: (gcpProfile?: { name: string; email: string; avatarUrl?: string }) => void;
  registerUser: (data: Omit<User, 'id'>) => { success: boolean; error?: string };
  logout: () => void;
  setCurrentUser: (user: User) => void;
  switchRole: (role: User['role']) => void;
  rooms: Room[];
  reservations: Reservation[];
  logs: ReservationLog[];
  notifications: InAppNotification[];
  unreadNotifCount: number;
  activeTab: string;
  setActiveTab: (tab: string) => void;
  selectedRoomForBooking: Room | null;
  setSelectedRoomForBooking: (room: Room | null) => void;
  createReservation: (data: Omit<Reservation, 'id' | 'status' | 'createdAt' | 'updatedAt'>) => { success: boolean; error?: string; reservation?: Reservation };
  approveReservation: (id: string, reason?: string) => { success: boolean; error?: string };
  rejectReservation: (id: string, reason: string) => { success: boolean; error?: string };
  cancelReservation: (id: string, reason?: string) => { success: boolean; error?: string };
  saveRoom: (room: Room) => void;
  toggleRoomStatus: (roomId: string, status: Room['status']) => void;
  markNotificationAsRead: (id: string) => void;
  markAllNotificationsAsRead: () => void;
  toasts: Toast[];
  addToast: (message: string, type?: Toast['type']) => void;
  removeToast: (id: string) => void;
  resetAllData: () => void;
}

const AppContext = createContext<AppContextType | undefined>(undefined);

export const AppProvider = ({ children }: { children: ReactNode }) => {
  const [currentUser, setCurrentUserState] = useState<User>(INITIAL_USERS[0]);
  const [allUsers, setAllUsers] = useState<User[]>(INITIAL_USERS);
  const [isAuthenticated, setIsAuthenticated] = useState<boolean>(true);
  const [rooms, setRooms] = useState<Room[]>([]);
  const [reservations, setReservations] = useState<Reservation[]>([]);
  const [logs, setLogs] = useState<ReservationLog[]>([]);
  const [notifications, setNotifications] = useState<InAppNotification[]>([]);
  const [activeTab, setActiveTab] = useState<string>('dashboard');
  const [selectedRoomForBooking, setSelectedRoomForBooking] = useState<Room | null>(null);
  const [toasts, setToasts] = useState<Toast[]>([]);

  // Load from local storage upon mount
  const refreshData = () => {
    const loadedUsers = StorageService.getUsers();
    const loadedCurrentUser = StorageService.getCurrentUser();
    const loadedAuth = StorageService.isAuthenticated();
    const loadedRooms = StorageService.getRooms();
    const loadedReservations = StorageService.getReservations();
    const loadedLogs = StorageService.getLogs();
    const loadedNotifications = StorageService.getNotifications(loadedCurrentUser.id);

    setAllUsers(loadedUsers);
    setCurrentUserState(loadedCurrentUser);
    setIsAuthenticated(loadedAuth);
    setRooms(loadedRooms);
    setReservations(loadedReservations);
    setLogs(loadedLogs);
    setNotifications(loadedNotifications);
  };

  useEffect(() => {
    refreshData();
  }, []);

  const addToast = (message: string, type: Toast['type'] = 'info') => {
    const id = `toast-${Date.now()}-${Math.random()}`;
    setToasts((prev) => [...prev, { id, message, type }]);
    setTimeout(() => {
      removeToast(id);
    }, 4500);
  };

  const removeToast = (id: string) => {
    setToasts((prev) => prev.filter((t) => t.id !== id));
  };

  const loginWithEmail = (email: string, password: string) => {
    const res = StorageService.loginWithEmail(email, password);
    if (res.success && res.user) {
      setCurrentUserState(res.user);
      setIsAuthenticated(true);
      refreshData();
      addToast(`Selamat datang kembali, ${res.user.name}!`, 'success');
    } else if (res.error) {
      addToast(res.error, 'error');
    }
    return res;
  };

  const loginWithGCP = (gcpProfile?: { name: string; email: string; avatarUrl?: string }) => {
    const res = StorageService.loginWithGCP(gcpProfile);
    setCurrentUserState(res.user);
    setIsAuthenticated(true);
    refreshData();
    addToast(`Berhasil masuk via Google Cloud Platform SSO (${res.user.email})`, 'success');
  };

  const registerUser = (data: Omit<User, 'id'>) => {
    const res = StorageService.registerUser(data);
    if (res.success && res.user) {
      setCurrentUserState(res.user);
      setIsAuthenticated(true);
      refreshData();
      addToast(`Pendaftaran berhasil! Selamat datang, ${res.user.name}`, 'success');
    } else if (res.error) {
      addToast(res.error, 'error');
    }
    return res;
  };

  const logout = () => {
    StorageService.logout();
    setIsAuthenticated(false);
    addToast('Anda telah berhasil keluar (Logout).', 'info');
  };

  const setCurrentUser = (user: User) => {
    StorageService.setCurrentUser(user);
    setCurrentUserState(user);
    setNotifications(StorageService.getNotifications(user.id));
    addToast(`Beralih akun ke: ${user.name} (${user.role})`, 'info');
  };

  const switchRole = (role: User['role']) => {
    const targetUser = allUsers.find((u) => u.role === role) || allUsers[0];
    setCurrentUser(targetUser);
  };

  const createReservation = (data: Omit<Reservation, 'id' | 'status' | 'createdAt' | 'updatedAt'>) => {
    const res = StorageService.createReservation(data);
    if (res.success && res.reservation) {
      refreshData();
      addToast(`Pengajuan berhasil terkirim! No. ID: ${res.reservation.id}`, 'success');
    } else if (res.error) {
      addToast(res.error, 'error');
    }
    return res;
  };

  const approveReservation = (id: string, reason?: string) => {
    const res = StorageService.updateReservationStatus(id, 'APPROVED', currentUser, reason);
    if (res.success) {
      refreshData();
      addToast('Reservasi telah disetujui.', 'success');
    } else if (res.error) {
      addToast(res.error, 'error');
    }
    return res;
  };

  const rejectReservation = (id: string, reason: string) => {
    const res = StorageService.updateReservationStatus(id, 'REJECTED', currentUser, reason);
    if (res.success) {
      refreshData();
      addToast('Pengajuan reservasi telah ditolak.', 'warning');
    } else if (res.error) {
      addToast(res.error, 'error');
    }
    return res;
  };

  const cancelReservation = (id: string, reason?: string) => {
    const res = StorageService.updateReservationStatus(id, 'CANCELLED', currentUser, reason || 'Dibatalkan oleh pemesan.');
    if (res.success) {
      refreshData();
      addToast('Reservasi berhasil dibatalkan.', 'info');
    } else if (res.error) {
      addToast(res.error, 'error');
    }
    return res;
  };

  const saveRoom = (room: Room) => {
    StorageService.saveRoom(room);
    refreshData();
    addToast(`Data ruangan "${room.name}" berhasil disimpan.`, 'success');
  };

  const toggleRoomStatus = (roomId: string, status: Room['status']) => {
    StorageService.toggleRoomStatus(roomId, status);
    refreshData();
    addToast(`Status ruangan diubah menjadi: ${status}`, 'info');
  };

  const markNotificationAsRead = (id: string) => {
    StorageService.markNotificationRead(id);
    setNotifications((prev) => prev.map((n) => (n.id === id ? { ...n, isRead: true } : n)));
  };

  const markAllNotificationsAsRead = () => {
    StorageService.markAllNotificationsRead(currentUser.id);
    setNotifications((prev) => prev.map((n) => ({ ...n, isRead: true })));
    addToast('Semua notifikasi telah ditandai dibaca.', 'info');
  };

  const resetAllData = () => {
    StorageService.resetAll();
    refreshData();
    addToast('Semua data berhasil direset ke nilai awal sampel.', 'info');
  };

  const unreadNotifCount = notifications.filter((n) => !n.isRead).length;

  return (
    <AppContext.Provider
      value={{
        currentUser,
        allUsers,
        isAuthenticated,
        loginWithEmail,
        loginWithGCP,
        registerUser,
        logout,
        setCurrentUser,
        switchRole,
        rooms,
        reservations,
        logs,
        notifications,
        unreadNotifCount,
        activeTab,
        setActiveTab,
        selectedRoomForBooking,
        setSelectedRoomForBooking,
        createReservation,
        approveReservation,
        rejectReservation,
        cancelReservation,
        saveRoom,
        toggleRoomStatus,
        markNotificationAsRead,
        markAllNotificationsAsRead,
        toasts,
        addToast,
        removeToast,
        resetAllData,
      }}
    >
      {children}

      {/* Modern Floating Toast Container */}
      <div className="fixed bottom-6 right-6 z-50 flex flex-col gap-2 max-w-md w-full pointer-events-none">
        {toasts.map((toast) => (
          <div
            key={toast.id}
            className={`pointer-events-auto flex items-start justify-between p-4 rounded-xl shadow-xl border text-sm transition-all duration-300 transform translate-y-0 backdrop-blur-md ${
              toast.type === 'success'
                ? 'bg-emerald-950/90 text-emerald-100 border-emerald-500/50'
                : toast.type === 'error'
                ? 'bg-rose-950/90 text-rose-100 border-rose-500/50'
                : toast.type === 'warning'
                ? 'bg-amber-950/90 text-amber-100 border-amber-500/50'
                : 'bg-slate-900/90 text-slate-100 border-slate-700'
            }`}
          >
            <div className="flex items-center gap-3">
              <span className="text-lg">
                {toast.type === 'success' && '✅'}
                {toast.type === 'error' && '⚠️'}
                {toast.type === 'warning' && '⚡'}
                {toast.type === 'info' && 'ℹ️'}
              </span>
              <p className="font-medium leading-relaxed">{toast.message}</p>
            </div>
            <button
              onClick={() => removeToast(toast.id)}
              className="text-slate-400 hover:text-white ml-3 transition-colors text-xs font-bold"
            >
              ✕
            </button>
          </div>
        ))}
      </div>
    </AppContext.Provider>
  );
};

export const useApp = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useApp must be used within an AppProvider');
  }
  return context;
};
