-- ==============================================================================
-- GYM TRACKER (PPL + UL) - ALL-IN-ONE INITIALIZATION (SCHEMA + RLS + SEED)
-- Jalankan file ini langsung di Supabase SQL Editor untuk setup instan!
-- ==============================================================================

-- ==============================================================================
-- 1. STRUKTUR TABEL
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.exercises (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

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

CREATE TABLE IF NOT EXISTS public.session_templates (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  est_minutes INTEGER NOT NULL DEFAULT 60
);

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

CREATE TABLE IF NOT EXISTS public.schedule_plans (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE,
  repeats BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS public.schedule_days (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id TEXT NOT NULL REFERENCES public.schedule_plans(id) ON DELETE CASCADE,
  day_index INTEGER NOT NULL CHECK (day_index BETWEEN 1 AND 7),
  template_id TEXT REFERENCES public.session_templates(id) ON DELETE SET NULL,
  CONSTRAINT uq_plan_day UNIQUE (plan_id, day_index)
);

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

CREATE TABLE IF NOT EXISTS public.user_settings (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  weight_step_kg NUMERIC(4, 2) NOT NULL DEFAULT 2.5,
  effort_display TEXT NOT NULL DEFAULT 'rir' CHECK (effort_display IN ('rir', 'rpe')),
  timezone TEXT NOT NULL DEFAULT 'Asia/Jakarta',
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

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

-- ==============================================================================
-- 2. INDEXES
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_workout_sessions_user_date ON public.workout_sessions(user_id, date);
CREATE INDEX IF NOT EXISTS idx_set_logs_user_session ON public.set_logs(user_id, session_id);
CREATE INDEX IF NOT EXISTS idx_set_logs_user_exercise ON public.set_logs(user_id, exercise_id, created_at);
CREATE INDEX IF NOT EXISTS idx_exercise_muscles_exercise ON public.exercise_muscles(exercise_id);
CREATE INDEX IF NOT EXISTS idx_template_exercises_template ON public.template_exercises(template_id, position);

-- ==============================================================================
-- 3. ROW LEVEL SECURITY (RLS)
-- ==============================================================================
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

-- Master data policies
DROP POLICY IF EXISTS "Public read exercises" ON public.exercises;
CREATE POLICY "Public read exercises" ON public.exercises FOR SELECT TO authenticated, anon USING (true);

DROP POLICY IF EXISTS "Public read exercise_muscles" ON public.exercise_muscles;
CREATE POLICY "Public read exercise_muscles" ON public.exercise_muscles FOR SELECT TO authenticated, anon USING (true);

DROP POLICY IF EXISTS "Public read session_templates" ON public.session_templates;
CREATE POLICY "Public read session_templates" ON public.session_templates FOR SELECT TO authenticated, anon USING (true);

DROP POLICY IF EXISTS "Public read template_exercises" ON public.template_exercises;
CREATE POLICY "Public read template_exercises" ON public.template_exercises FOR SELECT TO authenticated, anon USING (true);

DROP POLICY IF EXISTS "Public read schedule_plans" ON public.schedule_plans;
CREATE POLICY "Public read schedule_plans" ON public.schedule_plans FOR SELECT TO authenticated, anon USING (true);

DROP POLICY IF EXISTS "Public read schedule_days" ON public.schedule_days;
CREATE POLICY "Public read schedule_days" ON public.schedule_days FOR SELECT TO authenticated, anon USING (true);

-- User data policies
DROP POLICY IF EXISTS "Users can manage own workout_sessions" ON public.workout_sessions;
CREATE POLICY "Users can manage own workout_sessions" ON public.workout_sessions
  FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can manage own set_logs" ON public.set_logs;
CREATE POLICY "Users can manage own set_logs" ON public.set_logs
  FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can manage own user_settings" ON public.user_settings;
CREATE POLICY "Users can manage own user_settings" ON public.user_settings
  FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can manage own muscle_targets" ON public.muscle_targets;
CREATE POLICY "Users can manage own muscle_targets" ON public.muscle_targets
  FOR ALL TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ==============================================================================
-- 4. TRIGGER SETUP OTOMATIS USER BARU
-- ==============================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_settings (user_id, weight_step_kg, effort_display, timezone)
  VALUES (NEW.id, 2.5, 'rir', 'Asia/Jakarta')
  ON CONFLICT (user_id) DO NOTHING;

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

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ==============================================================================
-- 5. SEED DATA DARI PRD
-- ==============================================================================

-- Gerakan
INSERT INTO public.exercises (id, name, is_active) VALUES
  ('incline_chest_press', 'Incline Chest Press', true),
  ('chest_press', 'Chest Press', true),
  ('chest_fly', 'Chest Fly', true),
  ('shoulder_press', 'Shoulder Press', true),
  ('side_lateral', 'Side Lateral', true),
  ('tricep_push_down', 'Tricep Push Down', true),
  ('overhead_tricep_extension', 'Overhead Tricep Extension', true),
  ('lat_pulldown', 'Lat Pulldown', true),
  ('reverse_grip_lat_pull', 'Reverse Grip Lat Pull', true),
  ('wide_grip_cable_row', 'Wide Grip Cable Row', true),
  ('close_grip_cable_row', 'Close Grip Cable Row', true),
  ('cable_row', 'Cable Row', true),
  ('face_pull', 'Face Pull', true),
  ('biceps_curl', 'Biceps Curl', true),
  ('hammer_curl', 'Hammer Curl', true),
  ('squat', 'Squat', true),
  ('leg_press', 'Leg Press', true),
  ('leg_extension', 'Leg Extension', true),
  ('seated_leg_curl', 'Seated Leg Curl', true),
  ('lying_leg_curl', 'Lying Leg Curl', true),
  ('romanian_deadlift', 'Back Extension / Romanian Deadlift', true),
  ('calf_raises', 'Calf Raises', true),
  ('core', 'Core', true)
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, is_active = EXCLUDED.is_active;

-- Pemetaan Otot
DELETE FROM public.exercise_muscles;
INSERT INTO public.exercise_muscles (exercise_id, muscle, weight) VALUES
  ('incline_chest_press', 'dada', 1.0),
  ('incline_chest_press', 'triceps', 0.5),
  ('chest_press', 'dada', 1.0),
  ('chest_press', 'triceps', 0.5),
  ('chest_fly', 'dada', 1.0),
  ('shoulder_press', 'bahu_samping', 0.5),
  ('shoulder_press', 'triceps', 0.5),
  ('side_lateral', 'bahu_samping', 1.0),
  ('tricep_push_down', 'triceps', 1.0),
  ('overhead_tricep_extension', 'triceps', 1.0),
  ('lat_pulldown', 'punggung', 1.0),
  ('lat_pulldown', 'biceps', 0.5),
  ('reverse_grip_lat_pull', 'punggung', 1.0),
  ('reverse_grip_lat_pull', 'biceps', 0.5),
  ('wide_grip_cable_row', 'punggung', 1.0),
  ('wide_grip_cable_row', 'biceps', 0.5),
  ('wide_grip_cable_row', 'bahu_belakang', 0.5),
  ('close_grip_cable_row', 'punggung', 1.0),
  ('close_grip_cable_row', 'biceps', 0.5),
  ('close_grip_cable_row', 'bahu_belakang', 0.5),
  ('cable_row', 'punggung', 1.0),
  ('cable_row', 'biceps', 0.5),
  ('cable_row', 'bahu_belakang', 0.5),
  ('face_pull', 'bahu_belakang', 1.0),
  ('biceps_curl', 'biceps', 1.0),
  ('hammer_curl', 'biceps', 1.0),
  ('squat', 'quad', 1.0),
  ('leg_press', 'quad', 1.0),
  ('leg_extension', 'quad', 1.0),
  ('seated_leg_curl', 'hamstring', 1.0),
  ('lying_leg_curl', 'hamstring', 1.0),
  ('romanian_deadlift', 'hamstring', 0.5),
  ('calf_raises', 'betis', 1.0),
  ('core', 'core', 1.0);

-- Template Sesi
INSERT INTO public.session_templates (id, name, est_minutes) VALUES
  ('push', 'Push', 65),
  ('pull', 'Pull', 60),
  ('legs', 'Legs', 65),
  ('upper', 'Upper', 70),
  ('lower', 'Lower', 65),
  ('upper_a', 'Upper A', 70),
  ('lower_a', 'Lower A', 65),
  ('upper_b', 'Upper B', 70),
  ('lower_b', 'Lower B', 65)
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, est_minutes = EXCLUDED.est_minutes;

-- Template Exercises
DELETE FROM public.template_exercises;
INSERT INTO public.template_exercises (template_id, exercise_id, position, target_sets, rep_min, rep_max, rir_min, rir_max, rest_seconds, is_optional) VALUES
  -- Push
  ('push', 'incline_chest_press', 1, 3, 6, 8, 1, 2, 150, false),
  ('push', 'chest_press',         2, 3, 6, 8, 1, 2, 150, false),
  ('push', 'shoulder_press',      3, 3, 6, 8, 1, 2, 120, false),
  ('push', 'chest_fly',           4, 3, 6, 8, 1, 2, 90,  false),
  ('push', 'side_lateral',        5, 3, 6, 8, 1, 2, 90,  false),
  ('push', 'tricep_push_down',    6, 3, 6, 8, 1, 2, 90,  false),
  ('push', 'overhead_tricep_extension', 7, 3, 6, 8, 1, 2, 90, false),
  -- Pull
  ('pull', 'lat_pulldown',          1, 3, 6, 8, 1, 2, 150, false),
  ('pull', 'wide_grip_cable_row',   2, 3, 6, 8, 1, 2, 150, false),
  ('pull', 'reverse_grip_lat_pull', 3, 3, 6, 8, 1, 2, 120, true),
  ('pull', 'face_pull',             4, 3, 6, 8, 1, 2, 90,  false),
  ('pull', 'biceps_curl',           5, 3, 6, 8, 1, 2, 90,  false),
  ('pull', 'hammer_curl',           6, 3, 6, 8, 1, 2, 90,  false),
  -- Legs
  ('legs', 'squat',             1, 3, 6, 8, 1, 2, 180, false),
  ('legs', 'leg_press',         2, 3, 6, 8, 1, 2, 150, false),
  ('legs', 'seated_leg_curl',   3, 3, 6, 8, 1, 2, 120, false),
  ('legs', 'leg_extension',     4, 3, 6, 8, 1, 2, 90,  false),
  ('legs', 'calf_raises',       5, 3, 6, 8, 1, 2, 90,  false),
  ('legs', 'core',              6, 3, 6, 8, 1, 2, 90,  false),
  -- Upper
  ('upper', 'incline_chest_press', 1, 3, 6, 8, 1, 2, 150, false),
  ('upper', 'lat_pulldown',        2, 3, 6, 8, 1, 2, 150, false),
  ('upper', 'shoulder_press',      3, 3, 6, 8, 1, 2, 120, false),
  ('upper', 'cable_row',           4, 3, 6, 8, 1, 2, 120, false),
  ('upper', 'side_lateral',        5, 3, 6, 8, 1, 2, 90,  false),
  ('upper', 'biceps_curl',         6, 3, 6, 8, 1, 2, 90,  false),
  ('upper', 'tricep_push_down',    7, 3, 6, 8, 1, 2, 90,  false),
  -- Lower
  ('lower', 'squat',             1, 3, 6, 8, 1, 2, 180, false),
  ('lower', 'seated_leg_curl',   2, 3, 6, 8, 1, 2, 120, false),
  ('lower', 'leg_extension',     3, 3, 6, 8, 1, 2, 90,  false),
  ('lower', 'romanian_deadlift', 4, 3, 6, 8, 1, 2, 120, false),
  ('lower', 'calf_raises',       5, 3, 6, 8, 1, 2, 90,  false),
  ('lower', 'core',              6, 3, 6, 8, 1, 2, 90,  false),
  -- Upper A
  ('upper_a', 'incline_chest_press', 1, 3, 6, 8, 1, 2, 150, false),
  ('upper_a', 'lat_pulldown',        2, 3, 6, 8, 1, 2, 150, false),
  ('upper_a', 'chest_fly',           3, 3, 6, 8, 1, 2, 90,  false),
  ('upper_a', 'wide_grip_cable_row', 4, 3, 6, 8, 1, 2, 120, false),
  ('upper_a', 'side_lateral',        5, 3, 6, 8, 1, 2, 90,  false),
  ('upper_a', 'biceps_curl',         6, 3, 6, 8, 1, 2, 90,  false),
  ('upper_a', 'tricep_push_down',    7, 3, 6, 8, 1, 2, 90,  false),
  -- Lower A
  ('lower_a', 'squat',             1, 3, 6, 8, 1, 2, 180, false),
  ('lower_a', 'seated_leg_curl',   2, 3, 6, 8, 1, 2, 120, false),
  ('lower_a', 'leg_extension',     3, 3, 6, 8, 1, 2, 90,  false),
  ('lower_a', 'romanian_deadlift', 4, 3, 6, 8, 1, 2, 120, false),
  ('lower_a', 'calf_raises',       5, 3, 6, 8, 1, 2, 90,  false),
  ('lower_a', 'core',              6, 3, 6, 8, 1, 2, 90,  false),
  -- Upper B
  ('upper_b', 'chest_press',               1, 3, 6, 8, 1, 2, 150, false),
  ('upper_b', 'close_grip_cable_row',      2, 3, 6, 8, 1, 2, 150, false),
  ('upper_b', 'shoulder_press',            3, 3, 6, 8, 1, 2, 120, false),
  ('upper_b', 'face_pull',                 4, 3, 6, 8, 1, 2, 90,  false),
  ('upper_b', 'side_lateral',              5, 3, 6, 8, 1, 2, 90,  false),
  ('upper_b', 'hammer_curl',               6, 3, 6, 8, 1, 2, 90,  false),
  ('upper_b', 'overhead_tricep_extension', 7, 3, 6, 8, 1, 2, 90,  false),
  -- Lower B
  ('lower_b', 'leg_press',         1, 3, 6, 8, 1, 2, 180, false),
  ('lower_b', 'lying_leg_curl',    2, 3, 6, 8, 1, 2, 120, false),
  ('lower_b', 'leg_extension',     3, 3, 6, 8, 1, 2, 90,  false),
  ('lower_b', 'romanian_deadlift', 4, 3, 6, 8, 1, 2, 120, false),
  ('lower_b', 'calf_raises',       5, 3, 6, 8, 1, 2, 90,  false),
  ('lower_b', 'core',              6, 3, 6, 8, 1, 2, 90,  false);

-- Rencana Jadwal
INSERT INTO public.schedule_plans (id, name, start_date, end_date, repeats) VALUES
  ('minggu_ini', 'Minggu Ini (26 Okt - 1 Nov 2026)', '2026-10-26', '2026-11-01', false),
  ('reguler',    'Reguler (PPL + UL Siklus 7 Hari)', '2026-11-02', NULL, true)
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, start_date = EXCLUDED.start_date, end_date = EXCLUDED.end_date, repeats = EXCLUDED.repeats;

-- Jadwal Hari
DELETE FROM public.schedule_days;
INSERT INTO public.schedule_days (plan_id, day_index, template_id) VALUES
  -- Minggu ini
  ('minggu_ini', 1, 'upper_a'),
  ('minggu_ini', 2, 'lower_a'),
  ('minggu_ini', 3, NULL),
  ('minggu_ini', 4, NULL),
  ('minggu_ini', 5, 'upper_b'),
  ('minggu_ini', 6, 'lower_b'),
  ('minggu_ini', 7, NULL),
  -- Reguler
  ('reguler', 1, 'push'),
  ('reguler', 2, 'pull'),
  ('reguler', 3, 'legs'),
  ('reguler', 4, NULL),
  ('reguler', 5, 'upper'),
  ('reguler', 6, 'lower'),
  ('reguler', 7, NULL);
