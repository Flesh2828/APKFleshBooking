import type { Metadata } from 'next';
import './globals.css';
import { AppProvider } from '@/context/AppContext';

export const metadata: Metadata = {
  title: 'RoomBook — Sistem Reservasi & Booking Ruangan Terpadu',
  description:
    'Prototipe aplikasi booking ruangan untuk cek ketersediaan, reservasi bebas bentrok, dan persetujuan penggunaan ruangan.',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="id">
      <body className="bg-slate-50 text-slate-900 antialiased min-h-screen selection:bg-indigo-500 selection:text-white">
        <AppProvider>{children}</AppProvider>
      </body>
    </html>
  );
}
