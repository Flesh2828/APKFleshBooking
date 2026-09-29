'use client';

import React, { useState } from 'react';
import { useApp } from '@/context/AppContext';
import { Room, RoomStatus } from '@/types';
import {
  Building2,
  Plus,
  Edit,
  Power,
  Wrench,
  Users,
  MapPin,
  Clock,
  CheckCircle2,
  X,
  Search,
} from 'lucide-react';

export const RoomManagementView = () => {
  const { rooms, saveRoom, toggleRoomStatus } = useApp();

  const [searchQuery, setSearchQuery] = useState('');
  const [editingRoom, setEditingRoom] = useState<Room | null>(null);
  const [isAddModalOpen, setIsAddModalOpen] = useState(false);

  // Form state
  const [formName, setFormName] = useState('');
  const [formBuilding, setFormBuilding] = useState('');
  const [formFloor, setFormFloor] = useState<number>(1);
  const [formCapacity, setFormCapacity] = useState<number>(30);
  const [formFacilities, setFormFacilities] = useState('');
  const [formStatus, setFormStatus] = useState<RoomStatus>('ACTIVE');
  const [formOpen, setFormOpen] = useState('08:00');
  const [formClose, setFormClose] = useState('17:00');
  const [formImageUrl, setFormImageUrl] = useState('');
  const [formDesc, setFormDesc] = useState('');

  const openAddModal = () => {
    setFormName('');
    setFormBuilding('Gedung Perkuliahan Bersama Lt. 2');
    setFormFloor(2);
    setFormCapacity(40);
    setFormFacilities('Proyektor HD, AC Split, Whiteboard, Sound Standar');
    setFormStatus('ACTIVE');
    setFormOpen('08:00');
    setFormClose('17:00');
    setFormImageUrl('https://images.unsplash.com/photo-1577495508048-b635879837f1?auto=format&fit=crop&w=800&q=80');
    setFormDesc('Ruangan kelas dan presentasi yang nyaman dan siap pakai.');
    setIsAddModalOpen(true);
  };

  const openEditModal = (room: Room) => {
    setEditingRoom(room);
    setFormName(room.name);
    setFormBuilding(room.building);
    setFormFloor(room.floor);
    setFormCapacity(room.capacity);
    setFormFacilities(room.facilities.join(', '));
    setFormStatus(room.status);
    setFormOpen(room.openingHour);
    setFormClose(room.closingHour);
    setFormImageUrl(room.imageUrl);
    setFormDesc(room.description);
  };

  const handleSave = (e: React.FormEvent) => {
    e.preventDefault();

    const facilitiesArray = formFacilities
      .split(',')
      .map((f) => f.trim())
      .filter((f) => f.length > 0);

    const roomData: Room = {
      id: editingRoom ? editingRoom.id : `room-${Date.now()}`,
      name: formName,
      building: formBuilding,
      floor: formFloor,
      capacity: formCapacity,
      facilities: facilitiesArray.length > 0 ? facilitiesArray : ['AC', 'Proyektor'],
      status: formStatus,
      openingHour: formOpen,
      closingHour: formClose,
      imageUrl: formImageUrl || 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=800&q=80',
      description: formDesc,
    };

    saveRoom(roomData);
    setEditingRoom(null);
    setIsAddModalOpen(false);
  };

  const filteredRooms = rooms.filter(
    (r) =>
      r.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
      r.building.toLowerCase().includes(searchQuery.toLowerCase())
  );

  return (
    <div className="space-y-6 animate-in fade-in duration-300">
      {/* Title */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tight">
            Manajemen Master Ruangan
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Kelola data master fasilitas, kapasitas, jam operasional, serta jadwal pemeliharaan ruangan.
          </p>
        </div>

        <button
          onClick={openAddModal}
          className="px-4 py-2.5 rounded-2xl bg-indigo-600 hover:bg-indigo-700 text-white font-bold text-xs shadow-md shadow-indigo-600/20 transition-all flex items-center gap-2 self-start sm:self-auto"
        >
          <Plus className="w-4 h-4" />
          <span>Tambah Ruangan Baru</span>
        </button>
      </div>

      {/* Search */}
      <div className="p-4 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm flex items-center gap-3">
        <Search className="w-4 h-4 text-slate-400" />
        <input
          type="text"
          placeholder="Cari ruangan berdasarkan nama, gedung..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
          className="flex-1 text-xs bg-transparent focus:outline-none text-slate-900 dark:text-white"
        />
      </div>

      {/* Rooms Table / Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredRooms.map((room) => (
          <div
            key={room.id}
            className="rounded-3xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 overflow-hidden shadow-sm flex flex-col justify-between"
          >
            <div>
              <div className="relative h-40 w-full overflow-hidden bg-slate-100">
                <img
                  src={room.imageUrl}
                  alt={room.name}
                  className="w-full h-full object-cover"
                />
                <span
                  className={`absolute top-3 right-3 px-2.5 py-0.5 text-[10px] font-extrabold rounded-full ${
                    room.status === 'ACTIVE'
                      ? 'bg-emerald-500 text-white'
                      : room.status === 'MAINTENANCE'
                      ? 'bg-amber-500 text-white'
                      : 'bg-rose-500 text-white'
                  }`}
                >
                  {room.status}
                </span>

                <span className="absolute bottom-3 left-3 px-2.5 py-1 text-xs font-bold rounded-full bg-slate-900/80 backdrop-blur-md text-white flex items-center gap-1.5">
                  <Users className="w-3.5 h-3.5 text-indigo-400" />
                  Maks {room.capacity} Orang
                </span>
              </div>

              <div className="p-5 space-y-2">
                <h3 className="text-base font-bold text-slate-900 dark:text-white">
                  {room.name}
                </h3>
                <p className="text-xs text-slate-500 flex items-center gap-1">
                  <MapPin className="w-3 h-3 text-indigo-600" />
                  {room.building} (Lantai {room.floor})
                </p>
                <p className="text-[11px] text-slate-400 flex items-center gap-1">
                  <Clock className="w-3 h-3" />
                  Jam Buka: {room.openingHour} - {room.closingHour} WIB
                </p>
                <div className="pt-2 flex flex-wrap gap-1">
                  {room.facilities.map((fac) => (
                    <span
                      key={fac}
                      className="px-2 py-0.5 rounded text-[10px] font-medium bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-300"
                    >
                      {fac}
                    </span>
                  ))}
                </div>
              </div>
            </div>

            {/* Admin Action Controls */}
            <div className="p-5 pt-0 space-y-2 border-t border-slate-100 dark:border-slate-800 mt-2">
              <div className="flex items-center justify-between text-xs pt-3">
                <span className="text-[11px] text-slate-400 font-semibold">Ubah Status:</span>
                <div className="flex items-center gap-1">
                  <button
                    onClick={() => toggleRoomStatus(room.id, 'ACTIVE')}
                    className={`px-2 py-1 text-[10px] font-bold rounded-lg ${
                      room.status === 'ACTIVE'
                        ? 'bg-emerald-600 text-white'
                        : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                    }`}
                  >
                    Aktif
                  </button>
                  <button
                    onClick={() => toggleRoomStatus(room.id, 'MAINTENANCE')}
                    className={`px-2 py-1 text-[10px] font-bold rounded-lg ${
                      room.status === 'MAINTENANCE'
                        ? 'bg-amber-500 text-white'
                        : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                    }`}
                  >
                    Perawatan
                  </button>
                  <button
                    onClick={() => toggleRoomStatus(room.id, 'INACTIVE')}
                    className={`px-2 py-1 text-[10px] font-bold rounded-lg ${
                      room.status === 'INACTIVE'
                        ? 'bg-rose-600 text-white'
                        : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                    }`}
                  >
                    Nonaktif
                  </button>
                </div>
              </div>

              <button
                onClick={() => openEditModal(room)}
                className="w-full py-2 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-800 text-xs font-bold transition-colors flex items-center justify-center gap-1.5"
              >
                <Edit className="w-3.5 h-3.5 text-indigo-600" />
                <span>Edit Spesifikasi Ruangan</span>
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Add / Edit Modal */}
      {(isAddModalOpen || editingRoom) && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="bg-white dark:bg-slate-900 rounded-3xl max-w-xl w-full p-6 sm:p-8 space-y-5 border border-slate-200 dark:border-slate-800 shadow-2xl relative max-h-[90vh] overflow-y-auto">
            <button
              onClick={() => {
                setIsAddModalOpen(false);
                setEditingRoom(null);
              }}
              className="absolute top-4 right-4 p-2 rounded-full hover:bg-slate-100 text-slate-400"
            >
              <X className="w-4 h-4" />
            </button>

            <h3 className="text-lg font-black text-slate-900 dark:text-white flex items-center gap-2">
              <Building2 className="w-5 h-5 text-indigo-600" />
              {editingRoom ? 'Sunting Data Ruangan' : 'Tambah Ruangan Baru'}
            </h3>

            <form onSubmit={handleSave} className="space-y-4 text-xs">
              <div className="space-y-1">
                <label className="font-bold text-slate-700 dark:text-slate-300">
                  Nama Ruangan *
                </label>
                <input
                  type="text"
                  required
                  value={formName}
                  onChange={(e) => setFormName(e.target.value)}
                  placeholder="Contoh: Auditorium Graha Wiyata"
                  className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700"
                />
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div className="space-y-1">
                  <label className="font-bold text-slate-700 dark:text-slate-300">
                    Gedung / Lokasi *
                  </label>
                  <input
                    type="text"
                    required
                    value={formBuilding}
                    onChange={(e) => setFormBuilding(e.target.value)}
                    placeholder="Contoh: Gedung Rektorat"
                    className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700"
                  />
                </div>

                <div className="space-y-1">
                  <label className="font-bold text-slate-700 dark:text-slate-300">
                    Lantai
                  </label>
                  <input
                    type="number"
                    min={1}
                    value={formFloor}
                    onChange={(e) => setFormFloor(parseInt(e.target.value, 10) || 1)}
                    className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700"
                  />
                </div>
              </div>

              <div className="grid grid-cols-3 gap-3">
                <div className="space-y-1">
                  <label className="font-bold text-slate-700 dark:text-slate-300">
                    Kapasitas Maks
                  </label>
                  <input
                    type="number"
                    min={1}
                    value={formCapacity}
                    onChange={(e) => setFormCapacity(parseInt(e.target.value, 10) || 1)}
                    className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700"
                  />
                </div>

                <div className="space-y-1">
                  <label className="font-bold text-slate-700 dark:text-slate-300">
                    Jam Buka
                  </label>
                  <input
                    type="text"
                    value={formOpen}
                    onChange={(e) => setFormOpen(e.target.value)}
                    placeholder="08:00"
                    className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700"
                  />
                </div>

                <div className="space-y-1">
                  <label className="font-bold text-slate-700 dark:text-slate-300">
                    Jam Tutup
                  </label>
                  <input
                    type="text"
                    value={formClose}
                    onChange={(e) => setFormClose(e.target.value)}
                    placeholder="17:00"
                    className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700"
                  />
                </div>
              </div>

              <div className="space-y-1">
                <label className="font-bold text-slate-700 dark:text-slate-300">
                  Daftar Fasilitas (Pisahkan dengan koma)
                </label>
                <input
                  type="text"
                  value={formFacilities}
                  onChange={(e) => setFormFacilities(e.target.value)}
                  placeholder="Proyektor 4K, Sound System, AC Central, Smart Board"
                  className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700"
                />
              </div>

              <div className="space-y-1">
                <label className="font-bold text-slate-700 dark:text-slate-300">
                  URL Foto Ruangan
                </label>
                <input
                  type="text"
                  value={formImageUrl}
                  onChange={(e) => setFormImageUrl(e.target.value)}
                  placeholder="https://..."
                  className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700"
                />
              </div>

              <div className="space-y-1">
                <label className="font-bold text-slate-700 dark:text-slate-300">
                  Deskripsi Ruangan
                </label>
                <textarea
                  rows={2}
                  value={formDesc}
                  onChange={(e) => setFormDesc(e.target.value)}
                  placeholder="Keterangan peruntukan ruangan..."
                  className="w-full px-3 py-2 rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700"
                />
              </div>

              <div className="flex items-center gap-3 pt-3">
                <button
                  type="button"
                  onClick={() => {
                    setIsAddModalOpen(false);
                    setEditingRoom(null);
                  }}
                  className="flex-1 py-2.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold transition-colors"
                >
                  Batal
                </button>
                <button
                  type="submit"
                  className="flex-1 py-2.5 rounded-xl bg-indigo-600 hover:bg-indigo-700 text-white font-bold transition-colors shadow-md shadow-indigo-600/20"
                >
                  Simpan Ruangan
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
