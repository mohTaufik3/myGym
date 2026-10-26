import { createClient } from '@/lib/supabase/server';
import { Dumbbell, Play, LogOut, ArrowRight, ShieldCheck, Database, Sparkles, Check, Flame } from 'lucide-react';
import Link from 'next/link';

export const dynamic = 'force-dynamic';

const HARI_INDONESIA = ['', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

export default async function HomePage() {
  const isEnvSet =
    !!process.env.NEXT_PUBLIC_SUPABASE_URL &&
    !!process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY &&
    !process.env.NEXT_PUBLIC_SUPABASE_URL.includes('your-project-id');

  let user = null;
  let exercisesCount = 0;
  let templatesCount = 0;
  let todayTemplateName: string | null = null;
  let todayTemplateMinutes = 60;
  let isRestDay = false;
  let activePlanName = '';
  let scheduleWeek: Array<{ dayIndex: number; dayName: string; templateName: string; isToday: boolean; isRest: boolean }> = [];
  let errorMsg = '';

  // Hitung hari ini dalam format WIB (UTC+7)
  const now = new Date();
  const utc = now.getTime() + now.getTimezoneOffset() * 60000;
  const wibDate = new Date(utc + 3600000 * 7);

  const dayOfWeek = wibDate.getDay() === 0 ? 7 : wibDate.getDay();
  const dayName = HARI_INDONESIA[dayOfWeek];
  const dateFormatted = `${String(wibDate.getDate()).padStart(2, '0')}/${String(
    wibDate.getMonth() + 1
  ).padStart(2, '0')}/${wibDate.getFullYear()}`;
  const isoDateString = wibDate.toISOString().split('T')[0];

  if (isEnvSet) {
    try {
      const supabase = await createClient();
      const { data: authData } = await supabase.auth.getUser();
      user = authData?.user;

      const { count: exCount } = await supabase
        .from('exercises')
        .select('*', { count: 'exact', head: true });
      exercisesCount = exCount || 0;

      const { count: tmplCount } = await supabase
        .from('session_templates')
        .select('*', { count: 'exact', head: true });
      templatesCount = tmplCount || 0;

      const { data: plans } = await supabase
        .from('schedule_plans')
        .select('*')
        .order('start_date', { ascending: false });

      if (plans && plans.length > 0) {
        const activePlan =
          plans.find(
            (p) =>
              p.start_date <= isoDateString &&
              (p.end_date === null || p.end_date >= isoDateString)
          ) || plans[0];

        if (activePlan) {
          activePlanName = activePlan.name;

          const { data: allDays } = await supabase
            .from('schedule_days')
            .select('day_index, template_id, session_templates(name, est_minutes)')
            .eq('plan_id', activePlan.id)
            .order('day_index', { ascending: true });

          if (allDays && allDays.length > 0) {
            scheduleWeek = allDays.map((d) => {
              // @ts-expect-error join type
              const tName = d.session_templates?.name || (d.template_id ? d.template_id : 'Rest Day');
              const isRest = !d.template_id;
              const isToday = d.day_index === dayOfWeek;
              if (isToday) {
                todayTemplateName = tName;
                isRestDay = isRest;
                // @ts-expect-error join type
                todayTemplateMinutes = d.session_templates?.est_minutes || 60;
              }
              return {
                dayIndex: d.day_index,
                dayName: HARI_INDONESIA[d.day_index],
                templateName: tName,
                isToday,
                isRest,
              };
            });
          }
        }
      }
    } catch (e: unknown) {
      errorMsg = e instanceof Error ? e.message : 'Koneksi database bermasalah';
    }
  }

  return (
    <div className="flex-1 px-4 pt-6 pb-28 flex flex-col bg-[#121212] text-white">
      {/* Top Bar / Header */}
      <header className="flex items-center justify-between pb-4 mb-4">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-[#181818] border border-[#282828] flex items-center justify-center text-[#1ed760] shadow-md">
            <Dumbbell className="w-5 h-5 fill-current" />
          </div>
          <div>
            <h1 className="text-lg font-bold text-white tracking-tight">Gym Tracker</h1>
            <p className="text-[11px] text-[#b3b3b3] font-medium uppercase tracking-[1px]">PPL + UL</p>
          </div>
        </div>

        {user ? (
          <form action="/auth/signout" method="POST">
            <button
              type="submit"
              className="h-8 px-3.5 rounded-full bg-[#181818] border border-[#7c7c7c] hover:border-white text-[11px] font-bold text-white uppercase tracking-[1px] flex items-center gap-1.5 transition-all"
            >
              <LogOut className="w-3.5 h-3.5 text-[#b3b3b3]" />
              <span>Keluar</span>
            </button>
          </form>
        ) : (
          <Link
            href="/login"
            className="h-8 px-4 rounded-full bg-white hover:bg-[#eeeeee] text-black font-bold text-[11px] uppercase tracking-[1.4px] flex items-center transition-transform hover:scale-105 shadow-md"
          >
            <span>Masuk</span>
          </Link>
        )}
      </header>

      {/* Featured Workout Card (Spotify "Now Playing / Featured Playlist" Aesthetic) */}
      <section className="bg-[#181818] rounded-xl p-5 mb-6 shadow-[rgba(0,0,0,0.5)_0px_8px_24px] relative overflow-hidden group">
        <div className="flex items-center justify-between text-[11px] font-bold uppercase tracking-[1.5px] text-[#b3b3b3] mb-3">
          <span className="flex items-center gap-1.5 text-[#1ed760]">
            <Flame className="w-4 h-4 fill-current" />
            <span>Sesi Hari Ini • {dayName}</span>
          </span>
          <span className="text-[#a7a7a7]">{dateFormatted}</span>
        </div>

        <div className="flex items-center justify-between mt-1">
          <div className="space-y-1 pr-3">
            <h2 className="text-2xl font-bold tracking-tight text-white">
              {todayTemplateName || (isRestDay ? 'Rest (Pemulihan)' : 'Memuat Sesi...')}
            </h2>
            <p className="text-xs text-[#b3b3b3]">
              {isRestDay
                ? 'Istirahat & pemulihan otot terencana'
                : `${activePlanName || 'PPL + UL'} • ~${todayTemplateMinutes} Menit`}
            </p>
          </div>

          {/* Spotify Circular Play Button */}
          <button
            type="button"
            title="Mulai Sesi Latihan"
            className="w-14 h-14 rounded-full bg-[#1ed760] hover:bg-[#1fdf64] hover:scale-105 active:scale-95 text-black flex items-center justify-center shrink-0 shadow-[0_8px_20px_rgba(30,215,96,0.35)] transition-all cursor-pointer"
          >
            <Play className="w-6 h-6 fill-black ml-0.5" />
          </button>
        </div>

        {/* Primary CTA Full Pill Button */}
        <div className="mt-5 pt-4 border-t border-[#282828] flex items-center justify-between">
          <span className="text-[11px] font-medium text-[#b3b3b3]">
            {isRestDay ? 'Pilih sesi lain secara manual' : 'Target: Double progression 6-8 rep'}
          </span>
          <button
            type="button"
            className="h-9 px-4 rounded-full bg-[#1ed760] hover:bg-[#1fdf64] text-black font-bold text-[11px] uppercase tracking-[1.4px] flex items-center gap-1.5 transition-all shadow-md active:scale-95"
          >
            <span>Mulai</span>
            <ArrowRight className="w-3.5 h-3.5 stroke-[3]" />
          </button>
        </div>
      </section>

      {/* Spotify Track-List Style: Jadwal Mingguan */}
      <section className="mb-6">
        <div className="flex items-center justify-between mb-3 px-1">
          <h3 className="text-sm font-bold tracking-tight text-white uppercase tracking-[1px]">
            Jadwal Siklus Minggu Ini
          </h3>
          <span className="text-[11px] text-[#b3b3b3] font-medium">7 Hari</span>
        </div>

        <div className="bg-[#181818] rounded-xl overflow-hidden divide-y divide-[#222222]">
          {scheduleWeek.length > 0 ? (
            scheduleWeek.map((item) => (
              <div
                key={item.dayIndex}
                className={`flex items-center justify-between px-4 py-3 transition-colors ${
                  item.isToday ? 'bg-[#242424]' : 'hover:bg-[#1f1f1f]'
                }`}
              >
                <div className="flex items-center gap-3">
                  <span
                    className={`text-xs font-bold w-4 text-center ${
                      item.isToday ? 'text-[#1ed760]' : 'text-[#757575]'
                    }`}
                  >
                    {item.dayIndex}
                  </span>
                  <div>
                    <div className="flex items-center gap-2">
                      <p
                        className={`text-sm font-bold ${
                          item.isToday ? 'text-[#1ed760]' : 'text-white'
                        }`}
                      >
                        {item.templateName}
                      </p>
                      {item.isToday && (
                        <span className="text-[9px] font-bold uppercase tracking-wider px-1.5 py-0.5 rounded-full bg-[#1ed760]/20 text-[#1ed760]">
                          Hari Ini
                        </span>
                      )}
                    </div>
                    <p className="text-[11px] text-[#b3b3b3]">{item.dayName}</p>
                  </div>
                </div>

                <span
                  className={`text-[11px] font-bold ${
                    item.isRest ? 'text-[#757575]' : 'text-[#b3b3b3]'
                  }`}
                >
                  {item.isRest ? 'Rest' : 'Workout'}
                </span>
              </div>
            ))
          ) : (
            <div className="p-4 text-xs text-[#b3b3b3] text-center">
              Jadwal akan muncul setelah Supabase terhubung.
            </div>
          )}
        </div>
      </section>

      {/* Status Fondasi Sistem Fase 0 & 1 */}
      <section className="bg-[#181818] rounded-xl p-5 mb-5 shadow-lg border border-[#242424]">
        <div className="flex items-center justify-between mb-4">
          <div className="flex items-center gap-2">
            <Database className="w-4 h-4 text-[#1ed760]" />
            <h3 className="text-xs font-bold text-white uppercase tracking-[1.2px]">
              Status Sistem (Fase 0 & 1)
            </h3>
          </div>
          <span className="text-[10px] font-bold uppercase tracking-wider px-2.5 py-1 rounded-full bg-[#1ed760] text-black">
            Ready
          </span>
        </div>

        <div className="space-y-2.5">
          <div className="flex items-center justify-between p-3 rounded-lg bg-[#1f1f1f]">
            <div className="flex items-center gap-2.5">
              <div className="w-5 h-5 rounded-full bg-[#1ed760]/10 flex items-center justify-center text-[#1ed760]">
                <Check className="w-3.5 h-3.5 stroke-[3]" />
              </div>
              <span className="text-xs font-bold text-white">Next.js + Spotify Design</span>
            </div>
            <span className="text-[10px] text-[#b3b3b3] font-mono">Port 1000</span>
          </div>

          <div className="flex items-center justify-between p-3 rounded-lg bg-[#1f1f1f]">
            <div className="flex items-center gap-2.5">
              <div
                className={`w-5 h-5 rounded-full flex items-center justify-center ${
                  isEnvSet && exercisesCount > 0
                    ? 'bg-[#1ed760]/10 text-[#1ed760]'
                    : 'bg-[#ffa42b]/10 text-[#ffa42b]'
                }`}
              >
                <Check className="w-3.5 h-3.5 stroke-[3]" />
              </div>
              <span className="text-xs font-bold text-white">Supabase Master & Seed</span>
            </div>
            <span className="text-[10px] text-[#b3b3b3] font-mono">
              {exercisesCount} gerakan / {templatesCount} template
            </span>
          </div>

          <div className="flex items-center justify-between p-3 rounded-lg bg-[#1f1f1f]">
            <div className="flex items-center gap-2.5">
              <div className="w-5 h-5 rounded-full bg-[#1ed760]/10 flex items-center justify-center text-[#1ed760]">
                <ShieldCheck className="w-3.5 h-3.5 text-[#1ed760]" />
              </div>
              <span className="text-xs font-bold text-white">Row Level Security (RLS)</span>
            </div>
            <span className="text-[10px] text-[#1ed760] font-bold uppercase tracking-wider">Aktif</span>
          </div>
        </div>
      </section>

      {/* Langkah Koneksi Supabase Jika Belum Terisi */}
      {(!isEnvSet || exercisesCount === 0) && (
        <section className="bg-[#181818] border border-[#ffa42b]/40 rounded-xl p-4 text-xs">
          <div className="flex items-center gap-2 text-[#ffa42b] font-bold uppercase tracking-[1px] text-[11px] mb-2">
            <Sparkles className="w-4 h-4" />
            <span>Cara Hubungkan Database Supabase:</span>
          </div>
          <ol className="list-decimal list-inside space-y-1.5 text-[#b3b3b3] text-[11px] leading-relaxed">
            <li>Buka dashboard proyek Anda di Supabase.</li>
            <li>
              Buka menu <strong>SQL Editor</strong>, tempel isi file{' '}
              <span className="text-[#1ed760] font-mono">supabase/init.sql</span>, lalu klik <strong>Run</strong>.
            </li>
            <li>
              Salin <strong>Project URL</strong> dan <strong>anon key</strong> ke file{' '}
              <span className="text-[#1ed760] font-mono">.env.local</span>.
            </li>
          </ol>
        </section>
      )}

      {errorMsg && (
        <div className="mt-3 p-3 rounded-lg bg-[#241a1b] border border-[#f3727f]/40 text-[#f3727f] text-xs font-medium">
          {errorMsg}
        </div>
      )}
    </div>
  );
}
