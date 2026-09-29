export type UserRole = 'ADMIN' | 'MAHASISWA' | 'DOSEN' | 'STAF';

export interface User {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  department: string;
  phone?: string;
  avatarUrl?: string;
  password?: string;
  authProvider?: 'EMAIL' | 'GCP_GOOGLE';
}

export type RoomStatus = 'ACTIVE' | 'INACTIVE' | 'MAINTENANCE';

export interface Room {
  id: string;
  name: string;
  building: string;
  floor: number;
  capacity: number;
  facilities: string[];
  status: RoomStatus;
  openingHour: string; // e.g. "08:00"
  closingHour: string; // e.g. "17:00"
  imageUrl: string;
  description: string;
}

export type ReservationStatus = 'PENDING' | 'APPROVED' | 'REJECTED' | 'CANCELLED' | 'COMPLETED';

export interface Reservation {
  id: string;
  userId: string;
  roomId: string;
  userName: string;
  organization: string;
  startTime: string; // ISO 8601 string
  endTime: string;   // ISO 8601 string
  purpose: string;
  participantCount: number;
  additionalFacilities?: string;
  notes?: string;
  status: ReservationStatus;
  createdAt: string;
  updatedAt: string;
}

export interface ReservationLog {
  id: string;
  reservationId: string;
  adminId: string;
  adminName: string;
  previousStatus: ReservationStatus;
  newStatus: ReservationStatus;
  reason?: string;
  createdAt: string;
}

export interface RoomUnavailability {
  id: string;
  roomId: string;
  startTime: string;
  endTime: string;
  reason: string;
  createdAt: string;
}

export interface InAppNotification {
  id: string;
  userId: string;
  reservationId?: string;
  title: string;
  message: string;
  type: 'INFO' | 'SUCCESS' | 'WARNING' | 'DANGER';
  isRead: boolean;
  createdAt: string;
}
