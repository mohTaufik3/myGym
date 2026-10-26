-- ==============================================================================
-- GYM TRACKER (PPL + UL) - DATABASE SCHEMA & RLS
-- Mobile-First Gym Tracking Application
-- ==============================================================================

-- 1. TABEL UTAMA PROGRAM & MASTER DATA
-- ------------------------------------------------------------------------------

-- Gerakan (Exercises)
CREATE TABLE IF NOT EXISTS public.exercises (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Pemetaan Gerakan ke Otot (Exercise Muscles)
-- Weight: 1.0 (otot langsung / direct), 0.5 (otot tidak langsung / indirect)
CREATE TABLE IF NOT EXISTS public.exercise_muscles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id TEXT NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
  muscle TEXT NOT NULL CHECK (muscle IN (
    'dada', 'punggung', 'bahu_samping', 'bahu_belakang',
    'triceps', 'biceps', 'quad', 'hamstring', 'betis', 'core'
  )),
  weight NUMERIC(3, 1) NOT NULL CHECK (weight IN (1.0, 0.5)),
  CONSTRAINT uq_exercise_muscle UNIQUE (exercise_id, muscle)
);

-- Template Sesi Latihan (Session Templates)
CREATE TABLE IF NOT EXISTS public.session_templates (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  est_minutes INTEGER NOT NULL DEFAULT 60
);

-- Gerakan per Template (Template Exercises)
CREATE TABLE IF NOT EXISTS public.template_exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  template_id TEXT NOT NULL REFERENCES public.session_templates(id) ON DELETE CASCADE,
  exercise_id TEXT NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
  position INTEGER NOT NULL,
  target_sets INTEGER NOT NULL DEFAULT 3,
  rep_min INTEGER NOT NULL DEFAULT 6,
  rep_max INTEGER NOT NULL DEFAULT 8,
  rir_min INTEGER NOT NULL DEFAULT 1,
  rir_max INTEGER NOT NULL DEFAULT 2,
  rest_seconds INTEGER NOT NULL DEFAULT 120,
  is_optional BOOLEAN NOT NULL DEFAULT false,
  CONSTRAINT uq_template_exercise_pos UNIQUE (template_id, position)
);

-- Rencana Jadwal (Schedule Plans)
CREATE TABLE IF NOT EXISTS public.schedule_plans (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE,
  repeats BOOLEAN NOT NULL DEFAULT true
);

-- Jadwal Hari per Plan (Schedule Days: 1=Senin ... 7=Minggu)
CREATE TABLE IF NOT EXISTS public.schedule_days (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id TEXT NOT NULL REFERENCES public.schedule_plans(id) ON DELETE CASCADE,
  day_index INTEGER NOT NULL CHECK (day_index BETWEEN 1 AND 7),
  template_id TEXT REFERENCES public.session_templates(id) ON DELETE SET NULL,
  CONSTRAINT uq_plan_day UNIQUE (plan_id, day_index)
);


-- 2. TABEL DATA PENGGUNA (USER DATA)
-- ------------------------------------------------------------------------------

-- Sesi Latihan Pengguna (Workout Sessions)
CREATE TABLE IF NOT EXISTS public.workout_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  template_id TEXT REFERENCES public.session_templates(id) ON DELETE SET NULL,
  notes TEXT,
  started_at TIMESTAMPTZ,
  finished_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Catatan Tiap Set (Set Logs)
-- RPE tidak disimpan di DB, dihitung di aplikasi: RPE = 10 - RIR
CREATE TABLE IF NOT EXISTS public.set_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  session_id UUID NOT NULL REFERENCES public.workout_sessions(id) ON DELETE CASCADE,
  exercise_id TEXT NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
  set_number INTEGER NOT NULL,
  weight_kg NUMERIC(6, 2) NOT NULL,
  reps INTEGER NOT NULL,
  rir NUMERIC(3, 1),
  is_warmup BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Pengaturan Pengguna (User Settings)
CREATE TABLE IF NOT EXISTS public.user_settings (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  weight_step_kg NUMERIC(4, 2) NOT NULL DEFAULT 2.5,
  effort_display TEXT NOT NULL DEFAULT 'rir' CHECK (effort_display IN ('rir', 'rpe')),
  timezone TEXT NOT NULL DEFAULT 'Asia/Jakarta',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Target Volume Mingguan per Otot (Muscle Targets)
CREATE TABLE IF NOT EXISTS public.muscle_targets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  muscle TEXT NOT NULL CHECK (muscle IN (
    'dada', 'punggung', 'bahu_samping', 'bahu_belakang',
    'triceps', 'biceps', 'quad', 'hamstring', 'betis', 'core'
  )),
  min_sets INTEGER NOT NULL DEFAULT 10,
  max_sets INTEGER NOT NULL DEFAULT 20,
  CONSTRAINT uq_user_muscle UNIQUE (user_id, muscle)
);


-- 3. INDEXES UNTUK KINERJA TINGGI
-- ------------------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_date ON public.workout_sessions(user_id, date);
CREATE INDEX IF NOT EXISTS idx_set_logs_user_session ON public.set_logs(user_id, session_id);
CREATE INDEX IF NOT EXISTS idx_set_logs_user_exercise ON public.set_logs(user_id, exercise_id, created_at);
CREATE INDEX IF NOT EXISTS idx_exercise_muscles_exercise ON public.exercise_muscles(exercise_id);
CREATE INDEX IF NOT EXISTS idx_template_exercises_template ON public.template_exercises(template_id, position);


-- 4. ROW LEVEL SECURITY (RLS)
-- ------------------------------------------------------------------------------

-- Aktifkan RLS di semua tabel
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exercise_muscles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.session_templates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.template_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedule_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedule_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.set_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.muscle_targets ENABLE ROW LEVEL SECURITY;

-- Policy Tabel Program & Master (Semua user terotentikasi dapat membaca)
CREATE POLICY "Public read exercises" ON public.exercises
  FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Public read exercise_muscles" ON public.exercise_muscles
  FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Public read session_templates" ON public.session_templates
  FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Public read template_exercises" ON public.template_exercises
  FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Public read schedule_plans" ON public.schedule_plans
  FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Public read schedule_days" ON public.schedule_days
  FOR SELECT TO authenticated, anon USING (true);

-- Policy Tabel Pengguna (Hanya pemilik data yang bisa baca & ubah: user_id = auth.uid())
CREATE POLICY "Users can manage own workout_sessions" ON public.workout_sessions
  FOR ALL TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can manage own set_logs" ON public.set_logs
  FOR ALL TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can manage own user_settings" ON public.user_settings
  FOR ALL TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can manage own muscle_targets" ON public.muscle_targets
  FOR ALL TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);


-- 5. TRIGGER OTOMATIS SAAT USER BARU DIBUAT
-- ------------------------------------------------------------------------------
-- Saat user login pertama kali atau akun dibuat di Supabase Auth,
-- otomatis buat baris pengaturan dan target default 10-20 set untuk 10 otot.
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  -- Insert default user settings
  INSERT INTO public.user_settings (user_id, weight_step_kg, effort_display, timezone)
  VALUES (NEW.id, 2.5, 'rir', 'Asia/Jakarta')
  ON CONFLICT (user_id) DO NOTHING;

  -- Insert default muscle targets (10-20 set keras mingguan)
  INSERT INTO public.muscle_targets (user_id, muscle, min_sets, max_sets)
  VALUES
    (NEW.id, 'dada', 10, 20),
    (NEW.id, 'punggung', 10, 20),
    (NEW.id, 'bahu_samping', 10, 20),
    (NEW.id, 'bahu_belakang', 10, 20),
    (NEW.id, 'triceps', 10, 20),
    (NEW.id, 'biceps', 10, 20),
    (NEW.id, 'quad', 10, 20),
    (NEW.id, 'hamstring', 10, 20),
    (NEW.id, 'betis', 10, 20),
    (NEW.id, 'core', 10, 20)
  ON CONFLICT (user_id, muscle) DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Pasang trigger ke auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
