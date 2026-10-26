'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { Dumbbell, Mail, Lock, KeyRound, Sparkles, AlertCircle, CheckCircle2, Loader2, ArrowRight } from 'lucide-react';

export default function LoginPage() {
  const router = useRouter();
  const supabase = createClient();

  const [mode, setMode] = useState<'password' | 'magic_link' | 'signup'>('password');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);

  const handlePasswordLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrorMsg(null);
    setSuccessMsg(null);

    try {
      const { data, error } = await supabase.auth.signInWithPassword({
        email: email.trim(),
        password: password,
      });

      if (error) {
        setErrorMsg(error.message || 'Gagal login. Periksa email dan password.');
        return;
      }

      if (data.session) {
        router.push('/');
        router.refresh();
      }
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Terjadi kesalahan sistem';
      setErrorMsg(message);
    } finally {
      setLoading(false);
    }
  };

  const handleMagicLink = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrorMsg(null);
    setSuccessMsg(null);

    try {
      const redirectUrl = `${window.location.origin}/auth/callback`;
      const { error } = await supabase.auth.signInWithOtp({
        email: email.trim(),
        options: {
          emailRedirectTo: redirectUrl,
        },
      });

      if (error) {
        setErrorMsg(error.message || 'Gagal mengirim magic link.');
        return;
      }

      setSuccessMsg(`Tautan login telah dikirim ke ${email}. Silakan cek kotak masuk email Anda!`);
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Terjadi kesalahan sistem';
      setErrorMsg(message);
    } finally {
      setLoading(false);
    }
  };

  const handleSignUp = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setErrorMsg(null);
    setSuccessMsg(null);

    try {
      const { data, error } = await supabase.auth.signUp({
        email: email.trim(),
        password: password,
      });

      if (error) {
        setErrorMsg(error.message || 'Gagal membuat akun.');
        return;
      }

      if (data.session) {
        setSuccessMsg('Akun berhasil dibuat! Mengalihkan ke dashboard...');
        setTimeout(() => {
          router.push('/');
          router.refresh();
        }, 1000);
      } else {
        setSuccessMsg('Pendaftaran berhasil! Cek email untuk konfirmasi akun atau lakukan login.');
      }
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Terjadi kesalahan saat pendaftaran';
      setErrorMsg(message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex-1 flex flex-col justify-center px-6 py-10 bg-[#121212]">
      {/* Brand Header */}
      <div className="flex flex-col items-center text-center mb-8">
        <div className="w-16 h-16 rounded-full bg-[#1ed760] p-3 shadow-[0_8px_24px_rgba(30,215,96,0.3)] mb-4 flex items-center justify-center">
          <Dumbbell className="w-9 h-9 text-black fill-current stroke-[2.5]" />
        </div>
        <h1 className="text-2xl font-bold tracking-tight text-white font-sans">
          Gym Tracker
        </h1>
        <p className="text-[12px] text-[#b3b3b3] mt-1 uppercase tracking-[1.5px] font-bold">
          Program PPL + UL
        </p>
      </div>

      {/* Spotify-style Pill Mode Switch */}
      <div className="bg-[#181818] p-1 rounded-full border border-[#282828] flex mb-6">
        <button
          type="button"
          onClick={() => {
            setMode('password');
            setErrorMsg(null);
            setSuccessMsg(null);
          }}
          className={`flex-1 py-2 text-[11px] font-bold uppercase tracking-[1.2px] rounded-full transition-all ${
            mode === 'password'
              ? 'bg-[#ffffff] text-black shadow-sm'
              : 'text-[#b3b3b3] hover:text-white'
          }`}
        >
          Password
        </button>
        <button
          type="button"
          onClick={() => {
            setMode('magic_link');
            setErrorMsg(null);
            setSuccessMsg(null);
          }}
          className={`flex-1 py-2 text-[11px] font-bold uppercase tracking-[1.2px] rounded-full transition-all ${
            mode === 'magic_link'
              ? 'bg-[#ffffff] text-black shadow-sm'
              : 'text-[#b3b3b3] hover:text-white'
          }`}
        >
          Magic Link
        </button>
        <button
          type="button"
          onClick={() => {
            setMode('signup');
            setErrorMsg(null);
            setSuccessMsg(null);
          }}
          className={`flex-1 py-2 text-[11px] font-bold uppercase tracking-[1.2px] rounded-full transition-all ${
            mode === 'signup'
              ? 'bg-[#ffffff] text-black shadow-sm'
              : 'text-[#b3b3b3] hover:text-white'
          }`}
        >
          Daftar
        </button>
      </div>

      {/* Error & Success Feedback (Spotify semantic colors) */}
      {errorMsg && (
        <div className="mb-5 p-3.5 rounded-lg bg-[#241a1b] border border-[#f3727f]/40 text-[#f3727f] text-xs flex items-start gap-2.5">
          <AlertCircle className="w-4 h-4 text-[#f3727f] shrink-0 mt-0.5" />
          <span className="font-medium">{errorMsg}</span>
        </div>
      )}

      {successMsg && (
        <div className="mb-5 p-3.5 rounded-lg bg-[#14261a] border border-[#1ed760]/40 text-[#1ed760] text-xs flex items-start gap-2.5">
          <CheckCircle2 className="w-4 h-4 text-[#1ed760] shrink-0 mt-0.5" />
          <span className="font-medium">{successMsg}</span>
        </div>
      )}

      {/* Form Surface */}
      <div className="bg-[#181818] rounded-xl p-6 shadow-[rgba(0,0,0,0.5)_0px_8px_24px] border border-[#242424]">
        <form
          onSubmit={
            mode === 'password'
              ? handlePasswordLogin
              : mode === 'magic_link'
              ? handleMagicLink
              : handleSignUp
          }
          className="space-y-4"
        >
          <div>
            <label className="block text-[12px] font-bold text-white mb-2 uppercase tracking-[0.5px]">
              Alamat Email
            </label>
            <div className="relative">
              <Mail className="w-4 h-4 absolute left-4 top-1/2 -translate-y-1/2 text-[#b3b3b3]" />
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="nama@email.com"
                className="w-full h-12 bg-[#1f1f1f] text-white placeholder-[#757575] rounded-full pl-11 pr-4 text-sm font-medium border border-[#333333] focus:outline-none focus:border-white transition-all shadow-inner"
              />
            </div>
          </div>

          {mode !== 'magic_link' && (
            <div>
              <div className="flex items-center justify-between mb-2">
                <label className="text-[12px] font-bold text-white uppercase tracking-[0.5px]">
                  Kata Sandi
                </label>
                {mode === 'password' && (
                  <button
                    type="button"
                    onClick={() => {
                      setMode('magic_link');
                      setErrorMsg(null);
                    }}
                    className="text-[11px] font-bold text-[#b3b3b3] hover:text-[#1ed760] transition-colors"
                  >
                    Lupa sandi?
                  </button>
                )}
              </div>
              <div className="relative">
                <Lock className="w-4 h-4 absolute left-4 top-1/2 -translate-y-1/2 text-[#b3b3b3]" />
                <input
                  type="password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Minimal 6 karakter"
                  minLength={6}
                  className="w-full h-12 bg-[#1f1f1f] text-white placeholder-[#757575] rounded-full pl-11 pr-4 text-sm font-medium border border-[#333333] focus:outline-none focus:border-white transition-all shadow-inner"
                />
              </div>
            </div>
          )}

          {/* Spotify Green Full Pill Button */}
          <div className="pt-2">
            <button
              type="submit"
              disabled={loading}
              className="w-full h-12 bg-[#1ed760] hover:bg-[#1fdf64] text-black font-bold uppercase tracking-[1.5px] rounded-full text-[13px] transition-all flex items-center justify-center gap-2 active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed shadow-[0_4px_16px_rgba(30,215,96,0.3)] hover:scale-[1.02]"
            >
              {loading ? (
                <Loader2 className="w-5 h-5 animate-spin text-black" />
              ) : mode === 'password' ? (
                <>
                  <span>Masuk</span>
                  <ArrowRight className="w-4 h-4 stroke-[2.5]" />
                </>
              ) : mode === 'magic_link' ? (
                <>
                  <Sparkles className="w-4 h-4 stroke-[2.5]" />
                  <span>Kirim Tautan Login</span>
                </>
              ) : (
                <>
                  <KeyRound className="w-4 h-4 stroke-[2.5]" />
                  <span>Buat Akun Pribadi</span>
                </>
              )}
            </button>
          </div>
        </form>
      </div>

      <div className="mt-8 text-center">
        <p className="text-[11px] text-[#b3b3b3] leading-relaxed">
          Dirancang untuk satu pengguna. Data diamankan dengan Supabase Row Level Security (RLS).
        </p>
      </div>
    </div>
  );
}
