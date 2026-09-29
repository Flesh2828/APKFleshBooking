'use client';

import React, { useState } from 'react';
import { useApp } from '@/context/AppContext';
import { Navbar } from '@/components/Navbar';
import { Sidebar } from '@/components/Sidebar';
import { DashboardView } from '@/components/views/DashboardView';
import { RoomsCatalogView } from '@/components/views/RoomsCatalogView';
import { AvailabilityCalendarView } from '@/components/views/AvailabilityCalendarView';
import { ReservationFormView } from '@/components/views/ReservationFormView';
import { ApprovalsView } from '@/components/views/ApprovalsView';
import { MyReservationsView } from '@/components/views/MyReservationsView';
import { RoomManagementView } from '@/components/views/RoomManagementView';
import { ReportsView } from '@/components/views/ReportsView';
import { DocsView } from '@/components/views/DocsView';
import { LoginView } from '@/components/views/LoginView';

export default function Home() {
  const { activeTab, currentUser, isAuthenticated } = useApp();
  const [isMobileSidebarOpen, setIsMobileSidebarOpen] = useState(false);

  // If not authenticated, show login page
  if (!isAuthenticated) {
    return <LoginView />;
  }

  const renderActiveView = () => {
    switch (activeTab) {
      case 'dashboard':
        return <DashboardView />;
      case 'catalog':
        return <RoomsCatalogView />;
      case 'availability':
        return <AvailabilityCalendarView />;
      case 'new_booking':
        return <ReservationFormView />;
      case 'my_bookings':
        return <MyReservationsView />;
      case 'approvals':
        return currentUser.role === 'ADMIN' ? <ApprovalsView /> : <DashboardView />;
      case 'room_management':
        return currentUser.role === 'ADMIN' ? <RoomManagementView /> : <DashboardView />;
      case 'reports':
        return currentUser.role === 'ADMIN' ? <ReportsView /> : <DashboardView />;
      case 'docs':
        return <DocsView />;
      default:
        return <DashboardView />;
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 dark:bg-slate-950 flex flex-col font-sans">
      {/* Top Navigation Bar */}
      <Navbar onToggleSidebar={() => setIsMobileSidebarOpen(!isMobileSidebarOpen)} />

      {/* Body Layout: Sidebar + Main Content */}
      <div className="flex-1 flex w-full">
        {/* Navigation Sidebar */}
        <Sidebar
          isOpenMobile={isMobileSidebarOpen}
          onCloseMobile={() => setIsMobileSidebarOpen(false)}
        />

        {/* Main Content Area */}
        <main className="flex-1 lg:pl-64 flex flex-col min-w-0">
          <div className="p-4 sm:p-6 lg:p-8 max-w-7xl w-full mx-auto flex-1">
            {renderActiveView()}
          </div>
        </main>
      </div>
    </div>
  );
}
