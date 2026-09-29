'use client';

import React, { useState, useMemo } from 'react';
import { useApp } from '@/context/AppContext';
import { Room } from '@/types';
import {
  Search,
  Users,
  MapPin,
  Clock,
  CheckCircle2,
  Calendar,
  Layers,
  ChevronRight,
  SlidersHorizontal,
  X,
} from 'lucide-react';

export const RoomsCatalogView = () => {
  const { rooms, setActiveTab, setSelectedRoomForBooking } = useApp();
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedBuilding, setSelectedBuilding] = useState('ALL');
  const [minCapacity, setMinCapacity] = useState<number>(0);
  const [selectedFacility, setSelectedFacility] = useState<string>('ALL');
  const [previewRoom, setPreviewRoom] = useState<Room | null>(null);

  // Extract unique buildings
  const buildings = useMemo(() => {
    const list = Array.from(new Set(rooms.map((r) => r.building.split(' Lt.')[0])));
    return ['ALL', ...list];
  }, [rooms]);

  // Extract unique facilities
  const allFacilities = useMemo(() => {
    const set = new Set<string>();
    rooms.forEach((r) => r.facilities.forEach((f) => set.add(f.split(' ')[0])));
    return ['ALL', ...Array.from(set)];
  }, [rooms]);

  // Filtered rooms
  const filteredRooms = useMemo(() => {
    return rooms.filter((room) => {
      const matchesSearch =
        room.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
        room.building.toLowerCase().includes(searchQuery.toLowerCase()) ||
        room.description.toLowerCase().includes(searchQuery.toLowerCase());

      const matchesBuilding =
        selectedBuilding === 'ALL' || room.building.includes(selectedBuilding);

      const matchesCapacity = room.capacity >= minCapacity;

      const matchesFacility =
        selectedFacility === 'ALL' ||
        room.facilities.some((f) => f.toLowerCase().includes(selectedFacility.toLowerCase()));

      return matchesSearch && matchesBuilding && matchesCapacity && matchesFacility;
    });
  }, [rooms, searchQuery, selectedBuilding, minCapacity, selectedFacility]);

  return (
    <div className="space-y-6 animate-in fade-in duration-300">
      {/* Header Title */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-xl sm:text-2xl font-black text-slate-900 dark:text-white tracking-tight">
            Katalog & Fasilitas Ruangan
          </h1>
          <p className="text-xs sm:text-sm text-slate-500 mt-1">
            Jelajahi dan pilih ruangan yang sesuai dengan spesifikasi dan kapasitas kegiatan Anda.
          </p>
        </div>
        <div className="text-xs font-semibold px-3 py-1.5 rounded-xl bg-indigo-50 dark:bg-indigo-950/50 text-indigo-700 dark:text-indigo-300 border border-indigo-200/50 self-start sm:self-auto">
          {filteredRooms.length} Ruangan Ditemukan
        </div>
      </div>

      {/* Search & Filter Toolbar */}
      <div className="p-4 sm:p-5 rounded-2xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 shadow-sm space-y-4">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-3">
          {/* Text Search */}
          <div className="relative">
            <Search className="w-4 h-4 text-slate-400 absolute left-3 top-3" />
            <input
              type="text"
              placeholder="Cari nama ruangan, gedung..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-9 pr-3 py-2 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-500"
            />
          </div>

          {/* Building Filter */}
          <div className="flex items-center gap-2">
            <select
              value={selectedBuilding}
              onChange={(e) => setSelectedBuilding(e.target.value)}
              className="w-full px-3 py-2 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 text-slate-700 dark:text-slate-200"
            >
              <option value="ALL">Semua Gedung</option>
              {buildings
                .filter((b) => b !== 'ALL')
                .map((b) => (
                  <option key={b} value={b}>
                    {b}
                  </option>
                ))}
            </select>
          </div>

          {/* Capacity Filter */}
          <div>
            <select
              value={minCapacity}
              onChange={(e) => setMinCapacity(Number(e.target.value))}
              className="w-full px-3 py-2 text-xs rounded-xl bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 text-slate-700 dark:text-slate-200"
            >
              <option value={0}>Semua Kapasitas</option>
              <option value={20}>Minimal 20 Orang</option>
              <option value={50}>Minimal 50 Orang</option>
              <option value={100}>Minimal 100 Orang</option>
              <option value={200}>Minimal 200+ Orang</option>
            </select>
          </div>

          {/* Reset Filters */}
          <div className="flex items-center gap-2">
            {(searchQuery || selectedBuilding !== 'ALL' || minCapacity > 0 || selectedFacility !== 'ALL') && (
              <button
                onClick={() => {
                  setSearchQuery('');
                  setSelectedBuilding('ALL');
                  setMinCapacity(0);
                  setSelectedFacility('ALL');
                }}
                className="w-full py-2 px-3 text-xs font-semibold rounded-xl bg-rose-50 text-rose-600 hover:bg-rose-100 transition-colors flex items-center justify-center gap-1.5"
              >
                <X className="w-3.5 h-3.5" />
                Reset Filter
              </button>
            )}
          </div>
        </div>
      </div>

      {/* Rooms Grid */}
      {filteredRooms.length === 0 ? (
        <div className="p-12 text-center bg-white dark:bg-slate-900 rounded-3xl border border-slate-200 dark:border-slate-800 space-y-3">
          <Layers className="w-10 h-10 text-slate-300 mx-auto" />
          <h3 className="text-base font-bold text-slate-800 dark:text-slate-200">
            Tidak ada ruangan yang cocok
          </h3>
          <p className="text-xs text-slate-400 max-w-sm mx-auto">
            Coba sesuaikan kata kunci pencarian atau ubah kriteria filter kapasitas dan gedung.
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {filteredRooms.map((room) => {
            const isAvailable = room.status === 'ACTIVE';

            return (
              <div
                key={room.id}
                className="group rounded-3xl bg-white dark:bg-slate-900 border border-slate-200/80 dark:border-slate-800 overflow-hidden shadow-sm hover:shadow-xl hover:border-indigo-300 dark:hover:border-indigo-700 transition-all duration-300 flex flex-col justify-between"
              >
                <div>
                  {/* Photo & Badges */}
                  <div className="relative h-48 w-full overflow-hidden bg-slate-100">
                    <img
                      src={room.imageUrl}
                      alt={room.name}
                      className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                    />
                    <div className="absolute inset-0 bg-gradient-to-t from-slate-950/70 via-transparent to-transparent opacity-60" />

                    {/* Capacity Badge */}
                    <span className="absolute top-3 left-3 px-3 py-1 text-xs font-black rounded-full bg-slate-900/80 backdrop-blur-md text-white flex items-center gap-1.5 shadow-sm">
                      <Users className="w-3.5 h-3.5 text-indigo-400" />
                      {room.capacity} Peserta
                    </span>

                    {/* Operational Status Badge */}
                    <span
                      className={`absolute top-3 right-3 px-2.5 py-1 text-[10px] font-bold rounded-full shadow-sm backdrop-blur-md ${
                        room.status === 'ACTIVE'
                          ? 'bg-emerald-500/90 text-white'
                          : room.status === 'MAINTENANCE'
                          ? 'bg-amber-500/90 text-white'
                          : 'bg-rose-500/90 text-white'
                      }`}
                    >
                      {room.status === 'ACTIVE'
                        ? 'Siap Dipesan'
                        : room.status === 'MAINTENANCE'
                        ? 'Perawatan'
                        : 'Non-aktif'}
                    </span>

                    {/* Building Info overlay */}
                    <div className="absolute bottom-3 left-3 right-3 text-white">
                      <p className="text-[11px] font-medium text-slate-200 flex items-center gap-1">
                        <MapPin className="w-3 h-3 text-sky-400" />
                        {room.building} (Lt. {room.floor})
                      </p>
                    </div>
                  </div>

                  {/* Room Details Body */}
                  <div className="p-5 space-y-3">
                    <h3 className="text-base font-extrabold text-slate-900 dark:text-white line-clamp-1 group-hover:text-indigo-600 transition-colors">
                      {room.name}
                    </h3>
                    <p className="text-xs text-slate-500 line-clamp-2 leading-relaxed">
                      {room.description}
                    </p>

                    <div className="flex items-center gap-2 text-xs font-medium text-slate-600 dark:text-slate-400 pt-1">
                      <Clock className="w-3.5 h-3.5 text-indigo-500" />
                      <span>Jam Operasional: {room.openingHour} - {room.closingHour} WIB</span>
                    </div>

                    {/* Facility Chips */}
                    <div className="space-y-1 pt-1">
                      <span className="text-[10px] font-bold uppercase tracking-wider text-slate-400">
                        Fasilitas Ruangan:
                      </span>
                      <div className="flex flex-wrap gap-1.5 pt-0.5">
                        {room.facilities.slice(0, 3).map((facility) => (
                          <span
                            key={facility}
                            className="px-2 py-0.5 text-[10px] font-semibold rounded-lg bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300"
                          >
                            {facility}
                          </span>
                        ))}
                        {room.facilities.length > 3 && (
                          <span className="px-2 py-0.5 text-[10px] font-semibold rounded-lg bg-indigo-50 dark:bg-indigo-950/50 text-indigo-600 dark:text-indigo-400">
                            +{room.facilities.length - 3} lainnya
                          </span>
                        )}
                      </div>
                    </div>
                  </div>
                </div>

                {/* Card Action Buttons */}
                <div className="p-5 pt-0 space-y-2">
                  <div className="grid grid-cols-2 gap-2">
                    <button
                      onClick={() => {
                        setSelectedRoomForBooking(room);
                        setActiveTab('availability');
                      }}
                      className="py-2.5 px-3 rounded-xl bg-slate-100 hover:bg-slate-200 dark:bg-slate-800 dark:hover:bg-slate-700 text-slate-700 dark:text-slate-200 font-bold text-xs transition-colors flex items-center justify-center gap-1.5"
                    >
                      <Calendar className="w-3.5 h-3.5 text-indigo-600" />
                      <span>Cek Jadwal</span>
                    </button>

                    <button
                      onClick={() => {
                        setSelectedRoomForBooking(room);
                        setActiveTab('new_booking');
                      }}
                      disabled={!isAvailable}
                      className={`py-2.5 px-3 rounded-xl font-bold text-xs transition-all flex items-center justify-center gap-1.5 ${
                        isAvailable
                          ? 'bg-indigo-600 hover:bg-indigo-700 text-white shadow-md shadow-indigo-600/20'
                          : 'bg-slate-200 text-slate-400 cursor-not-allowed'
                      }`}
                    >
                      <span>Booking</span>
                      <ChevronRight className="w-3.5 h-3.5" />
                    </button>
                  </div>

                  <button
                    onClick={() => setPreviewRoom(room)}
                    className="w-full text-center text-[11px] font-semibold text-slate-400 hover:text-indigo-600 transition-colors py-1"
                  >
                    Lihat Spesifikasi Lengkap &rarr;
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* Room Detail Modal Preview */}
      {previewRoom && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm animate-in fade-in duration-200">
          <div className="bg-white dark:bg-slate-900 rounded-3xl max-w-xl w-full p-6 space-y-5 border border-slate-200 dark:border-slate-800 shadow-2xl relative max-h-[90vh] overflow-y-auto">
            <button
              onClick={() => setPreviewRoom(null)}
              className="absolute top-4 right-4 p-2 rounded-full bg-slate-100 dark:bg-slate-800 text-slate-500 hover:text-slate-900"
            >
              <X className="w-4 h-4" />
            </button>

            <img
              src={previewRoom.imageUrl}
              alt={previewRoom.name}
              className="w-full h-48 object-cover rounded-2xl shadow-sm"
            />

            <div>
              <div className="flex items-center gap-2">
                <span className="px-2.5 py-0.5 text-xs font-bold rounded-full bg-indigo-100 text-indigo-700 dark:bg-indigo-950/60 dark:text-indigo-300">
                  Kapasitas {previewRoom.capacity} Orang
                </span>
                <span className="text-xs text-slate-500">
                  {previewRoom.building} (Lantai {previewRoom.floor})
                </span>
              </div>
              <h2 className="text-xl font-black text-slate-900 dark:text-white mt-1">
                {previewRoom.name}
              </h2>
            </div>

            <p className="text-xs text-slate-600 dark:text-slate-300 leading-relaxed">
              {previewRoom.description}
            </p>

            <div className="p-4 rounded-2xl bg-slate-50 dark:bg-slate-800/50 space-y-2">
              <h4 className="text-xs font-bold text-slate-900 dark:text-white">
                Daftar Fasilitas Lengkap:
              </h4>
              <div className="grid grid-cols-2 gap-2 text-xs text-slate-700 dark:text-slate-300">
                {previewRoom.facilities.map((fac) => (
                  <div key={fac} className="flex items-center gap-2">
                    <CheckCircle2 className="w-3.5 h-3.5 text-emerald-500 flex-shrink-0" />
                    <span>{fac}</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="flex items-center gap-3 pt-2">
              <button
                onClick={() => {
                  setSelectedRoomForBooking(previewRoom);
                  setActiveTab('availability');
                  setPreviewRoom(null);
                }}
                className="flex-1 py-3 rounded-2xl bg-slate-100 hover:bg-slate-200 text-slate-800 font-bold text-xs transition-colors"
              >
                Cek Ketersediaan Jam
              </button>
              <button
                onClick={() => {
                  setSelectedRoomForBooking(previewRoom);
                  setActiveTab('new_booking');
                  setPreviewRoom(null);
                }}
                className="flex-1 py-3 rounded-2xl bg-indigo-600 hover:bg-indigo-700 text-white font-bold text-xs shadow-md shadow-indigo-600/20 transition-colors"
              >
                Lanjutkan Pemesanan
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
