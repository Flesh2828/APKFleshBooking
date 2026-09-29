import { User, Room, Reservation, ReservationLog, InAppNotification, ReservationStatus } from '@/types';
import { INITIAL_USERS, INITIAL_ROOMS, INITIAL_RESERVATIONS, INITIAL_LOGS, INITIAL_NOTIFICATIONS } from './data';

const STORAGE_KEYS = {
  USERS: 'roombook_users_v1',
  ROOMS: 'roombook_rooms_v1',
  RESERVATIONS: 'roombook_reservations_v1',
  LOGS: 'roombook_logs_v1',
  NOTIFICATIONS: 'roombook_notifications_v1',
  CURRENT_USER: 'roombook_current_user_v1',
  AUTH_SESSION: 'roombook_auth_session_v1',
};

function safeGet<T>(key: string, fallback: T): T {
  if (typeof window === 'undefined') return fallback;
  try {
    const item = localStorage.getItem(key);
    if (!item) {
      localStorage.setItem(key, JSON.stringify(fallback));
      return fallback;
    }
    return JSON.parse(item);
  } catch (err) {
    console.error(`Error reading ${key} from localStorage:`, err);
    return fallback;
  }
}

function safeSet<T>(key: string, value: T): void {
  if (typeof window === 'undefined') return;
  try {
    localStorage.setItem(key, JSON.stringify(value));
  } catch (err) {
    console.error(`Error writing ${key} to localStorage:`, err);
  }
}

// Conflict checking algorithm
export function checkIntervalOverlap(
  start1: Date | string,
  end1: Date | string,
  start2: Date | string,
  end2: Date | string
): boolean {
  const s1 = new Date(start1).getTime();
  const e1 = new Date(end1).getTime();
  const s2 = new Date(start2).getTime();
  const e2 = new Date(end2).getTime();

  return s1 < e2 && e1 > s2;
}

export const StorageService = {
  // Reset to default sample data
  resetAll: () => {
    if (typeof window === 'undefined') return;
    localStorage.setItem(STORAGE_KEYS.USERS, JSON.stringify(INITIAL_USERS));
    localStorage.setItem(STORAGE_KEYS.ROOMS, JSON.stringify(INITIAL_ROOMS));
    localStorage.setItem(STORAGE_KEYS.RESERVATIONS, JSON.stringify(INITIAL_RESERVATIONS));
    localStorage.setItem(STORAGE_KEYS.LOGS, JSON.stringify(INITIAL_LOGS));
    localStorage.setItem(STORAGE_KEYS.NOTIFICATIONS, JSON.stringify(INITIAL_NOTIFICATIONS));
    localStorage.setItem(STORAGE_KEYS.CURRENT_USER, JSON.stringify(INITIAL_USERS[0]));
  },

  // USERS & AUTH
  getUsers: (): User[] => safeGet(STORAGE_KEYS.USERS, INITIAL_USERS),
  getCurrentUser: (): User => safeGet(STORAGE_KEYS.CURRENT_USER, INITIAL_USERS[0]),
  setCurrentUser: (user: User) => safeSet(STORAGE_KEYS.CURRENT_USER, user),

  // SESSION
  isAuthenticated: (): boolean => {
    if (typeof window === 'undefined') return true;
    return safeGet<boolean>(STORAGE_KEYS.AUTH_SESSION, true);
  },
  setAuthenticated: (status: boolean) => safeSet(STORAGE_KEYS.AUTH_SESSION, status),

  loginWithEmail: (email: string, password: string): { success: boolean; user?: User; error?: string } => {
    const users = safeGet<User[]>(STORAGE_KEYS.USERS, INITIAL_USERS);
    const user = users.find((u) => u.email.toLowerCase() === email.trim().toLowerCase());

    if (!user) {
      return { success: false, error: 'Email tidak terdaftar dalam sistem.' };
    }

    if (user.password && user.password !== password) {
      return { success: false, error: 'Kata sandi tidak sesuai. Silakan periksa kembali.' };
    }

    safeSet(STORAGE_KEYS.CURRENT_USER, user);
    safeSet(STORAGE_KEYS.AUTH_SESSION, true);
    return { success: true, user };
  },

  loginWithGCP: (gcpProfile?: { name: string; email: string; avatarUrl?: string }): { success: boolean; user: User } => {
    const users = safeGet<User[]>(STORAGE_KEYS.USERS, INITIAL_USERS);
    const email = gcpProfile?.email || 'sarah.wijaya@campus.ac.id';
    let user = users.find((u) => u.email.toLowerCase() === email.toLowerCase());

    if (!user) {
      // Auto-provision user through GCP Workspace / Google Cloud SSO
      user = {
        id: `usr-gcp-${Date.now()}`,
        name: gcpProfile?.name || 'Pengguna GCP Google',
        email: email,
        role: email.includes('admin') ? 'ADMIN' : email.includes('dosen') ? 'DOSEN' : 'MAHASISWA',
        department: 'Fakultas / Unit Terintegrasi Google Cloud',
        avatarUrl: gcpProfile?.avatarUrl || 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
        authProvider: 'GCP_GOOGLE',
      };
      users.push(user);
      safeSet(STORAGE_KEYS.USERS, users);
    }

    safeSet(STORAGE_KEYS.CURRENT_USER, user);
    safeSet(STORAGE_KEYS.AUTH_SESSION, true);
    return { success: true, user };
  },

  registerUser: (newUser: Omit<User, 'id'>): { success: boolean; user?: User; error?: string } => {
    const users = safeGet<User[]>(STORAGE_KEYS.USERS, INITIAL_USERS);
    const existing = users.find((u) => u.email.toLowerCase() === newUser.email.trim().toLowerCase());

    if (existing) {
      return { success: false, error: 'Email tersebut sudah terdaftar. Silakan login.' };
    }

    const created: User = {
      ...newUser,
      id: `usr-${Date.now()}`,
      authProvider: 'EMAIL',
    };
    users.push(created);
    safeSet(STORAGE_KEYS.USERS, users);
    safeSet(STORAGE_KEYS.CURRENT_USER, created);
    safeSet(STORAGE_KEYS.AUTH_SESSION, true);

    return { success: true, user: created };
  },

  logout: () => {
    safeSet(STORAGE_KEYS.AUTH_SESSION, false);
  },

  // ROOMS
  getRooms: (): Room[] => safeGet(STORAGE_KEYS.ROOMS, INITIAL_ROOMS),
  saveRoom: (room: Room): void => {
    const rooms = safeGet(STORAGE_KEYS.ROOMS, INITIAL_ROOMS);
    const index = rooms.findIndex((r) => r.id === room.id);
    if (index >= 0) {
      rooms[index] = room;
    } else {
      rooms.unshift(room);
    }
    safeSet(STORAGE_KEYS.ROOMS, rooms);
  },
  toggleRoomStatus: (roomId: string, newStatus: Room['status']): void => {
    const rooms = safeGet(STORAGE_KEYS.ROOMS, INITIAL_ROOMS);
    const room = rooms.find((r) => r.id === roomId);
    if (room) {
      room.status = newStatus;
      safeSet(STORAGE_KEYS.ROOMS, rooms);
    }
  },

  // RESERVATIONS
  getReservations: (): Reservation[] => safeGet(STORAGE_KEYS.RESERVATIONS, INITIAL_RESERVATIONS),
  
  findConflicts: (
    roomId: string,
    startTime: string,
    endTime: string,
    excludeReservationId?: string
  ): { hasConflict: boolean; conflictingBooking?: Reservation } => {
    const reservations = safeGet(STORAGE_KEYS.RESERVATIONS, INITIAL_RESERVATIONS);
    
    // Look for overlapping APPROVED reservations
    const conflict = reservations.find((r) => {
      if (r.roomId !== roomId) return false;
      if (excludeReservationId && r.id === excludeReservationId) return false;
      if (r.status !== 'APPROVED') return false;
      return checkIntervalOverlap(startTime, endTime, r.startTime, r.endTime);
    });

    return {
      hasConflict: !!conflict,
      conflictingBooking: conflict,
    };
  },

  createReservation: (data: Omit<Reservation, 'id' | 'status' | 'createdAt' | 'updatedAt'>): { success: boolean; reservation?: Reservation; error?: string } => {
    const reservations = safeGet(STORAGE_KEYS.RESERVATIONS, INITIAL_RESERVATIONS);
    const rooms = safeGet(STORAGE_KEYS.ROOMS, INITIAL_ROOMS);
    const room = rooms.find((r) => r.id === data.roomId);

    if (!room) {
      return { success: false, error: 'Ruangan tidak ditemukan.' };
    }

    if (room.status !== 'ACTIVE') {
      return { success: false, error: `Ruangan sedang berstatus ${room.status} dan tidak dapat dipesan.` };
    }

    // Capacity validation
    if (data.participantCount > room.capacity) {
      return {
        success: false,
        error: `Jumlah peserta (${data.participantCount} orang) melebihi kapasitas maksimal ruangan (${room.capacity} orang).`,
      };
    }

    // End time must be after start time
    const start = new Date(data.startTime);
    const end = new Date(data.endTime);
    if (end.getTime() <= start.getTime()) {
      return { success: false, error: 'Waktu selesai harus lebih besar dari waktu mulai.' };
    }

    // Check conflict with APPROVED bookings
    const conflictCheck = StorageService.findConflicts(data.roomId, data.startTime, data.endTime);
    if (conflictCheck.hasConflict) {
      return {
        success: false,
        error: `Jadwal bentrok dengan reservasi yang telah disetujui sebelumnya: "${conflictCheck.conflictingBooking?.purpose}". Silakan pilih waktu lain.`,
      };
    }

    // Generate unique ID: RB-YYYYMM-XXX
    const now = new Date();
    const yearMonth = `${now.getFullYear()}${String(now.getMonth() + 1).padStart(2, '0')}`;
    const randomSuffix = String(Math.floor(Math.random() * 900) + 100);
    const newId = `RB-${yearMonth}-${randomSuffix}`;

    const newReservation: Reservation = {
      ...data,
      id: newId,
      status: 'PENDING',
      createdAt: now.toISOString(),
      updatedAt: now.toISOString(),
    };

    reservations.unshift(newReservation);
    safeSet(STORAGE_KEYS.RESERVATIONS, reservations);

    // Notify Admins
    const notifications = safeGet(STORAGE_KEYS.NOTIFICATIONS, INITIAL_NOTIFICATIONS);
    notifications.unshift({
      id: `notif-${Date.now()}`,
      userId: 'usr-admin',
      reservationId: newReservation.id,
      title: 'Pengajuan Reservasi Baru',
      message: `${newReservation.userName} (${newReservation.organization}) mengajukan peminjaman ${room.name}.`,
      type: 'INFO',
      isRead: false,
      createdAt: now.toISOString(),
    });
    safeSet(STORAGE_KEYS.NOTIFICATIONS, notifications);

    return { success: true, reservation: newReservation };
  },

  updateReservationStatus: (
    reservationId: string,
    newStatus: ReservationStatus,
    adminUser: User,
    reason?: string
  ): { success: boolean; error?: string } => {
    const reservations = safeGet(STORAGE_KEYS.RESERVATIONS, INITIAL_RESERVATIONS);
    const resIndex = reservations.findIndex((r) => r.id === reservationId);

    if (resIndex === -1) {
      return { success: false, error: 'Reservasi tidak ditemukan.' };
    }

    const currentReservation = reservations[resIndex];

    // If approving, re-validate to ensure no race-condition collision
    if (newStatus === 'APPROVED') {
      const conflictCheck = StorageService.findConflicts(
        currentReservation.roomId,
        currentReservation.startTime,
        currentReservation.endTime,
        currentReservation.id
      );

      if (conflictCheck.hasConflict) {
        return {
          success: false,
          error: `Gagal menyetujui: Terjadi bentrok jadwal dengan reservasi lain yang baru saja disetujui ("${conflictCheck.conflictingBooking?.purpose}").`,
        };
      }
    }

    // If rejecting, reason is mandatory (PRD section 8.5)
    if (newStatus === 'REJECTED' && (!reason || reason.trim() === '')) {
      return { success: false, error: 'Penolakan reservasi wajib menyertakan alasan.' };
    }

    const prevStatus = currentReservation.status;
    currentReservation.status = newStatus;
    currentReservation.updatedAt = new Date().toISOString();
    reservations[resIndex] = currentReservation;
    safeSet(STORAGE_KEYS.RESERVATIONS, reservations);

    // Add Audit Log
    const logs = safeGet(STORAGE_KEYS.LOGS, INITIAL_LOGS);
    logs.unshift({
      id: `log-${Date.now()}`,
      reservationId: currentReservation.id,
      adminId: adminUser.id,
      adminName: adminUser.name,
      previousStatus: prevStatus,
      newStatus: newStatus,
      reason: reason || undefined,
      createdAt: new Date().toISOString(),
    });
    safeSet(STORAGE_KEYS.LOGS, logs);

    // Notify Requester
    const rooms = safeGet(STORAGE_KEYS.ROOMS, INITIAL_ROOMS);
    const room = rooms.find((r) => r.id === currentReservation.roomId);
    const notifications = safeGet(STORAGE_KEYS.NOTIFICATIONS, INITIAL_NOTIFICATIONS);

    let notifTitle = '';
    let notifType: InAppNotification['type'] = 'INFO';
    let notifMessage = '';

    if (newStatus === 'APPROVED') {
      notifTitle = 'Reservasi Disetujui! ✅';
      notifType = 'SUCCESS';
      notifMessage = `Pengajuan ruangan ${room?.name || ''} untuk "${currentReservation.purpose}" telah disetujui.`;
    } else if (newStatus === 'REJECTED') {
      notifTitle = 'Pengajuan Ditolak ❌';
      notifType = 'DANGER';
      notifMessage = `Pengajuan ${room?.name || ''} ditolak oleh Admin. Alasan: ${reason}`;
    } else if (newStatus === 'CANCELLED') {
      notifTitle = 'Reservasi Dibatalkan';
      notifType = 'WARNING';
      notifMessage = `Reservasi ${room?.name || ''} berhasil dibatalkan.`;
    }

    notifications.unshift({
      id: `notif-${Date.now()}`,
      userId: currentReservation.userId,
      reservationId: currentReservation.id,
      title: notifTitle,
      message: notifMessage,
      type: notifType,
      isRead: false,
      createdAt: new Date().toISOString(),
    });
    safeSet(STORAGE_KEYS.NOTIFICATIONS, notifications);

    return { success: true };
  },

  // NOTIFICATIONS
  getNotifications: (userId?: string): InAppNotification[] => {
    const all = safeGet(STORAGE_KEYS.NOTIFICATIONS, INITIAL_NOTIFICATIONS);
    if (!userId) return all;
    return all.filter((n) => n.userId === userId || n.userId === 'all');
  },

  markNotificationRead: (id: string): void => {
    const notifs = safeGet(STORAGE_KEYS.NOTIFICATIONS, INITIAL_NOTIFICATIONS);
    const target = notifs.find((n) => n.id === id);
    if (target) {
      target.isRead = true;
      safeSet(STORAGE_KEYS.NOTIFICATIONS, notifs);
    }
  },

  markAllNotificationsRead: (userId: string): void => {
    const notifs = safeGet(STORAGE_KEYS.NOTIFICATIONS, INITIAL_NOTIFICATIONS);
    notifs.forEach((n) => {
      if (n.userId === userId || n.userId === 'all') {
        n.isRead = true;
      }
    });
    safeSet(STORAGE_KEYS.NOTIFICATIONS, notifs);
  },

  // LOGS
  getLogs: (reservationId?: string): ReservationLog[] => {
    const all = safeGet(STORAGE_KEYS.LOGS, INITIAL_LOGS);
    if (!reservationId) return all;
    return all.filter((l) => l.reservationId === reservationId);
  },
};
