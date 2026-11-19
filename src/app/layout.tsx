import type { Metadata } from 'next';
import './globals.css';
import { AppProvider } from '@/context/AppContext';

export const metadata: Metadata = {
  title: 'GuildSpace — Smart Room Booking & Guild Hub Workspace',
  description:
    'Sistem reservasi ruangan pintar terintegrasi dengan Anti Ghost-Booking QR Check-In dan GuildSpace Multi-Model AI Engine.',
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
