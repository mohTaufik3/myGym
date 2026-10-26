'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { Dumbbell, Table2, TrendingUp, Info } from 'lucide-react';

export default function BottomNav() {
  const pathname = usePathname();

  const navItems = [
    {
      label: 'Latih',
      href: '/',
      icon: Dumbbell,
      active: pathname === '/',
    },
    {
      label: 'Data',
      href: '/data',
      icon: Table2,
      active: pathname.startsWith('/data'),
    },
    {
      label: 'Analisis',
      href: '/analisis',
      icon: TrendingUp,
      active: pathname.startsWith('/analisis'),
    },
    {
      label: 'Info',
      href: '/info',
      icon: Info,
      active: pathname.startsWith('/info'),
    },
  ];

  // Sembunyikan BottomNav di halaman login
  if (pathname === '/login') {
    return null;
  }

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-50 bg-[#121212]/95 backdrop-blur-lg border-t border-[#282828]">
      <div className="max-w-md mx-auto grid grid-cols-4 h-16 px-1">
        {navItems.map((item) => {
          const Icon = item.icon;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex flex-col items-center justify-center gap-1 min-h-[44px] transition-colors ${
                item.active
                  ? 'text-white'
                  : 'text-[#b3b3b3] hover:text-white'
              }`}
            >
              <div className="relative">
                <Icon
                  className={`w-5 h-5 transition-transform ${
                    item.active ? 'text-[#1ed760] scale-110' : ''
                  }`}
                />
              </div>
              <span
                className={`text-[11px] ${
                  item.active ? 'font-bold text-white' : 'font-medium text-[#b3b3b3]'
                }`}
              >
                {item.label}
              </span>
            </Link>
          );
        })}
      </div>
    </nav>
  );
}
