-- ==============================================================================
-- GYM TRACKER (PPL + UL) - SEED DATA
-- Sesuai spesifikasi PRD Bab 5, 6, dan 7
-- ==============================================================================

-- 1. SEED GERAKAN (EXERCISES)
-- ------------------------------------------------------------------------------
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


-- 2. SEED PEMETAAN GERAKAN KE OTOT (EXERCISE MUSCLES)
-- Bobot 1.0 (Langsung / Direct), 0.5 (Tidak Langsung / Indirect)
-- ------------------------------------------------------------------------------
DELETE FROM public.exercise_muscles;

INSERT INTO public.exercise_muscles (exercise_id, muscle, weight) VALUES
  -- Dada & Dorong
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

  -- Punggung & Tarik
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

  -- Kaki & Inti
  ('squat', 'quad', 1.0),
  ('leg_press', 'quad', 1.0),
  ('leg_extension', 'quad', 1.0),
  ('seated_leg_curl', 'hamstring', 1.0),
  ('lying_leg_curl', 'hamstring', 1.0),
  ('romanian_deadlift', 'hamstring', 0.5),
  ('calf_raises', 'betis', 1.0),
  ('core', 'core', 1.0);


-- 3. SEED TEMPLATE SESI LATIHAN (SESSION TEMPLATES)
-- ------------------------------------------------------------------------------
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


-- 4. SEED GERAKAN PER TEMPLATE (TEMPLATE EXERCISES)
-- Standar Double Progression: Target 3 set, 6-8 rep, RIR 1-2, Istirahat 90-180 detik
-- ------------------------------------------------------------------------------
DELETE FROM public.template_exercises;

-- Template: PUSH
INSERT INTO public.template_exercises (template_id, exercise_id, position, target_sets, rep_min, rep_max, rir_min, rir_max, rest_seconds, is_optional) VALUES
  ('push', 'incline_chest_press', 1, 3, 6, 8, 1, 2, 150, false),
  ('push', 'chest_press',         2, 3, 6, 8, 1, 2, 150, false),
  ('push', 'shoulder_press',      3, 3, 6, 8, 1, 2, 120, false),
  ('push', 'chest_fly',           4, 3, 6, 8, 1, 2, 90,  false),
  ('push', 'side_lateral',        5, 3, 6, 8, 1, 2, 90,  false),
  ('push', 'tricep_push_down',    6, 3, 6, 8, 1, 2, 90,  false),
  ('push', 'overhead_tricep_extension', 7, 3, 6, 8, 1, 2, 90, false);

-- Template: PULL
INSERT INTO public.template_exercises (template_id, exercise_id, position, target_sets, rep_min, rep_max, rir_min, rir_max, rest_seconds, is_optional) VALUES
  ('pull', 'lat_pulldown',          1, 3, 6, 8, 1, 2, 150, false),
  ('pull', 'wide_grip_cable_row',   2, 3, 6, 8, 1, 2, 150, false),
  ('pull', 'reverse_grip_lat_pull', 3, 3, 6, 8, 1, 2, 120, true), -- Opsional di PRD
  ('pull', 'face_pull',             4, 3, 6, 8, 1, 2, 90,  false),
  ('pull', 'biceps_curl',           5, 3, 6, 8, 1, 2, 90,  false),
  ('pull', 'hammer_curl',           6, 3, 6, 8, 1, 2, 90,  false);

-- Template: LEGS
INSERT INTO public.template_exercises (template_id, exercise_id, position, target_sets, rep_min, rep_max, rir_min, rir_max, rest_seconds, is_optional) VALUES
  ('legs', 'squat',             1, 3, 6, 8, 1, 2, 180, false),
  ('legs', 'leg_press',         2, 3, 6, 8, 1, 2, 150, false),
  ('legs', 'seated_leg_curl',   3, 3, 6, 8, 1, 2, 120, false),
  ('legs', 'leg_extension',     4, 3, 6, 8, 1, 2, 90,  false),
  ('legs', 'calf_raises',       5, 3, 6, 8, 1, 2, 90,  false),
  ('legs', 'core',              6, 3, 6, 8, 1, 2, 90,  false);

-- Template: UPPER (Reguler)
INSERT INTO public.template_exercises (template_id, exercise_id, position, target_sets, rep_min, rep_max, rir_min, rir_max, rest_seconds, is_optional) VALUES
  ('upper', 'incline_chest_press', 1, 3, 6, 8, 1, 2, 150, false),
  ('upper', 'lat_pulldown',        2, 3, 6, 8, 1, 2, 150, false),
  ('upper', 'shoulder_press',      3, 3, 6, 8, 1, 2, 120, false),
  ('upper', 'cable_row',           4, 3, 6, 8, 1, 2, 120, false),
  ('upper', 'side_lateral',        5, 3, 6, 8, 1, 2, 90,  false),
  ('upper', 'biceps_curl',         6, 3, 6, 8, 1, 2, 90,  false),
  ('upper', 'tricep_push_down',    7, 3, 6, 8, 1, 2, 90,  false);

-- Template: LOWER (Reguler)
INSERT INTO public.template_exercises (template_id, exercise_id, position, target_sets, rep_min, rep_max, rir_min, rir_max, rest_seconds, is_optional) VALUES
  ('lower', 'squat',             1, 3, 6, 8, 1, 2, 180, false),
  ('lower', 'seated_leg_curl',   2, 3, 6, 8, 1, 2, 120, false),
  ('lower', 'leg_extension',     3, 3, 6, 8, 1, 2, 90,  false),
  ('lower', 'romanian_deadlift', 4, 3, 6, 8, 1, 2, 120, false),
  ('lower', 'calf_raises',       5, 3, 6, 8, 1, 2, 90,  false),
  ('lower', 'core',              6, 3, 6, 8, 1, 2, 90,  false);

-- Template: UPPER A (Khusus Minggu Ini)
INSERT INTO public.template_exercises (template_id, exercise_id, position, target_sets, rep_min, rep_max, rir_min, rir_max, rest_seconds, is_optional) VALUES
  ('upper_a', 'incline_chest_press', 1, 3, 6, 8, 1, 2, 150, false),
  ('upper_a', 'lat_pulldown',        2, 3, 6, 8, 1, 2, 150, false),
  ('upper_a', 'chest_fly',           3, 3, 6, 8, 1, 2, 90,  false),
  ('upper_a', 'wide_grip_cable_row', 4, 3, 6, 8, 1, 2, 120, false),
  ('upper_a', 'side_lateral',        5, 3, 6, 8, 1, 2, 90,  false),
  ('upper_a', 'biceps_curl',         6, 3, 6, 8, 1, 2, 90,  false),
  ('upper_a', 'tricep_push_down',    7, 3, 6, 8, 1, 2, 90,  false);

-- Template: LOWER A (Khusus Minggu Ini)
INSERT INTO public.template_exercises (template_id, exercise_id, position, target_sets, rep_min, rep_max, rir_min, rir_max, rest_seconds, is_optional) VALUES
  ('lower_a', 'squat',             1, 3, 6, 8, 1, 2, 180, false),
  ('lower_a', 'seated_leg_curl',   2, 3, 6, 8, 1, 2, 120, false),
  ('lower_a', 'leg_extension',     3, 3, 6, 8, 1, 2, 90,  false),
  ('lower_a', 'romanian_deadlift', 4, 3, 6, 8, 1, 2, 120, false),
  ('lower_a', 'calf_raises',       5, 3, 6, 8, 1, 2, 90,  false),
  ('lower_a', 'core',              6, 3, 6, 8, 1, 2, 90,  false);

-- Template: UPPER B (Khusus Minggu Ini)
INSERT INTO public.template_exercises (template_id, exercise_id, position, target_sets, rep_min, rep_max, rir_min, rir_max, rest_seconds, is_optional) VALUES
  ('upper_b', 'chest_press',               1, 3, 6, 8, 1, 2, 150, false),
  ('upper_b', 'close_grip_cable_row',      2, 3, 6, 8, 1, 2, 150, false),
  ('upper_b', 'shoulder_press',            3, 3, 6, 8, 1, 2, 120, false),
  ('upper_b', 'face_pull',                 4, 3, 6, 8, 1, 2, 90,  false),
  ('upper_b', 'side_lateral',              5, 3, 6, 8, 1, 2, 90,  false),
  ('upper_b', 'hammer_curl',               6, 3, 6, 8, 1, 2, 90,  false),
  ('upper_b', 'overhead_tricep_extension', 7, 3, 6, 8, 1, 2, 90,  false);

-- Template: LOWER B (Khusus Minggu Ini)
INSERT INTO public.template_exercises (template_id, exercise_id, position, target_sets, rep_min, rep_max, rir_min, rir_max, rest_seconds, is_optional) VALUES
  ('lower_b', 'leg_press',         1, 3, 6, 8, 1, 2, 180, false),
  ('lower_b', 'lying_leg_curl',    2, 3, 6, 8, 1, 2, 120, false),
  ('lower_b', 'leg_extension',     3, 3, 6, 8, 1, 2, 90,  false),
  ('lower_b', 'romanian_deadlift', 4, 3, 6, 8, 1, 2, 120, false),
  ('lower_b', 'calf_raises',       5, 3, 6, 8, 1, 2, 90,  false),
  ('lower_b', 'core',              6, 3, 6, 8, 1, 2, 90,  false);


-- 5. SEED RENCANA JADWAL (SCHEDULE PLANS)
-- ------------------------------------------------------------------------------
INSERT INTO public.schedule_plans (id, name, start_date, end_date, repeats) VALUES
  ('minggu_ini', 'Minggu Ini (26 Okt - 1 Nov 2026)', '2026-10-26', '2026-11-01', false),
  ('reguler',    'Reguler (PPL + UL Siklus 7 Hari)', '2026-11-02', NULL, true)
ON CONFLICT (id) DO UPDATE SET name = EXCLUDED.name, start_date = EXCLUDED.start_date, end_date = EXCLUDED.end_date, repeats = EXCLUDED.repeats;


-- 6. SEED JADWAL HARIAN (SCHEDULE DAYS)
-- Day Index: 1=Senin, 2=Selasa, 3=Rabu, 4=Kamis, 5=Jumat, 6=Sabtu, 7=Minggu
-- NULL template_id berarti hari Rest (Istirahat)
-- ------------------------------------------------------------------------------
DELETE FROM public.schedule_days;

-- Jadwal Minggu Ini: Upper A, Lower A, Rest, Rest, Upper B, Lower B, Rest
INSERT INTO public.schedule_days (plan_id, day_index, template_id) VALUES
  ('minggu_ini', 1, 'upper_a'),
  ('minggu_ini', 2, 'lower_a'),
  ('minggu_ini', 3, NULL),
  ('minggu_ini', 4, NULL),
  ('minggu_ini', 5, 'upper_b'),
  ('minggu_ini', 6, 'lower_b'),
  ('minggu_ini', 7, NULL);

-- Jadwal Reguler: Push, Pull, Legs, Rest, Upper, Lower, Rest
INSERT INTO public.schedule_days (plan_id, day_index, template_id) VALUES
  ('reguler', 1, 'push'),
  ('reguler', 2, 'pull'),
  ('reguler', 3, 'legs'),
  ('reguler', 4, NULL),
  ('reguler', 5, 'upper'),
  ('reguler', 6, 'lower'),
  ('reguler', 7, NULL);
