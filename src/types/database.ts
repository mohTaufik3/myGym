export type MuscleGroup =
  | 'dada'
  | 'punggung'
  | 'bahu_samping'
  | 'bahu_belakang'
  | 'triceps'
  | 'biceps'
  | 'quad'
  | 'hamstring'
  | 'betis'
  | 'core';

export interface Exercise {
  id: string;
  name: string;
  is_active: boolean;
  created_at?: string;
}

export interface ExerciseMuscle {
  id: string;
  exercise_id: string;
  muscle: MuscleGroup;
  weight: number; // 1.0 = direct, 0.5 = indirect
}

export interface SessionTemplate {
  id: string;
  name: string;
  est_minutes: number;
}

export interface TemplateExercise {
  id: string;
  template_id: string;
  exercise_id: string;
  position: number;
  target_sets: number;
  rep_min: number;
  rep_max: number;
  rir_min: number;
  rir_max: number;
  rest_seconds: number;
  is_optional: boolean;
  exercise?: Exercise;
}

export interface SchedulePlan {
  id: string;
  name: string;
  start_date: string;
  end_date: string | null;
  repeats: boolean;
}

export interface ScheduleDay {
  id: string;
  plan_id: string;
  day_index: number; // 1 = Senin, ..., 7 = Minggu
  template_id: string | null; // null = Rest
  template?: SessionTemplate;
}

export interface WorkoutSession {
  id: string;
  user_id: string;
  date: string; // YYYY-MM-DD
  template_id: string | null;
  notes: string | null;
  started_at: string | null;
  finished_at: string | null;
  created_at: string;
  template?: SessionTemplate;
  set_logs?: SetLog[];
}

export interface SetLog {
  id: string;
  user_id: string;
  session_id: string;
  exercise_id: string;
  set_number: number;
  weight_kg: number;
  reps: number;
  rir: number | null;
  is_warmup: boolean;
  created_at: string;
  exercise?: Exercise;
}

export interface UserSettings {
  user_id: string;
  weight_step_kg: number;
  effort_display: 'rir' | 'rpe';
  timezone: string;
  updated_at: string;
}

export interface MuscleTarget {
  id: string;
  user_id: string;
  muscle: MuscleGroup;
  min_sets: number;
  max_sets: number;
}
