import type { Metadata, Viewport } from 'next';
import './globals.css';
import BottomNav from '@/components/BottomNav';

export const metadata: Metadata = {
  title: 'Gym Tracker | PPL + UL',
  description: 'Web app mobile-first pencatat latihan gym dengan Spotify-inspired design',
  applicationName: 'Gym Tracker',
  appleWebApp: {
    capable: true,
    title: 'Gym Tracker',
    statusBarStyle: 'black-translucent',
  },
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  themeColor: '#121212',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="id" className="h-full bg-[#121212] text-white antialiased">
      <body className="min-h-full bg-[#121212] text-white flex flex-col font-sans selection:bg-[#1ed760] selection:text-black">
        <main className="flex-1 w-full max-w-md mx-auto relative flex flex-col bg-[#121212]">
          {children}
        </main>
        <BottomNav />
      </body>
    </html>
  );
}
