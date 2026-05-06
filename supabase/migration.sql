-- ============================================
-- 빚프리 (debt-free) Supabase 테이블 생성
-- Supabase SQL Editor에서 실행하세요
-- ============================================

-- 1. profiles 테이블 (Supabase Auth와 연동)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  display_name TEXT NOT NULL,
  profile_image_url TEXT,
  auth_provider TEXT NOT NULL DEFAULT 'email',
  total_days_active INT NOT NULL DEFAULT 1,
  streak_count INT NOT NULL DEFAULT 0,
  longest_streak INT NOT NULL DEFAULT 0,
  strategy TEXT NOT NULL DEFAULT 'snowball',
  monthly_budget INT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_login_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. debts 테이블
CREATE TABLE public.debts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'other',
  initial_amount INT,
  current_balance INT NOT NULL,
  interest_rate DOUBLE PRECISION NOT NULL DEFAULT 0,
  minimum_payment INT,
  target_payment INT,
  payment_day INT,
  notification_timing TEXT NOT NULL DEFAULT 'threeDaysBefore',
  is_paid_off BOOLEAN NOT NULL DEFAULT FALSE,
  paid_off_at TIMESTAMPTZ,
  priority INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. payments 테이블
CREATE TABLE public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  debt_id UUID NOT NULL REFERENCES public.debts(id) ON DELETE CASCADE,
  amount INT NOT NULL,
  paid_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  note TEXT,
  is_extra BOOLEAN NOT NULL DEFAULT FALSE,
  balance_before INT NOT NULL,
  balance_after INT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. badges 테이블
CREATE TABLE public.badges (
  id TEXT NOT NULL,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  earned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, id)
);

-- ============================================
-- 인덱스
-- ============================================
CREATE INDEX idx_debts_user_id ON public.debts(user_id);
CREATE INDEX idx_debts_is_paid_off ON public.debts(user_id, is_paid_off);
CREATE INDEX idx_payments_user_id ON public.payments(user_id);
CREATE INDEX idx_payments_debt_id ON public.payments(debt_id);
CREATE INDEX idx_payments_paid_at ON public.payments(user_id, paid_at);
CREATE INDEX idx_badges_user_id ON public.badges(user_id);

-- ============================================
-- RLS (Row Level Security) 정책
-- ============================================

-- profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "본인 프로필만 조회" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "본인 프로필만 수정" ON public.profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "가입 시 프로필 생성" ON public.profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- debts
ALTER TABLE public.debts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "본인 빚만 조회" ON public.debts
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "본인 빚만 추가" ON public.debts
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "본인 빚만 수정" ON public.debts
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "본인 빚만 삭제" ON public.debts
  FOR DELETE USING (auth.uid() = user_id);

-- payments
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "본인 상환기록만 조회" ON public.payments
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "본인 상환기록만 추가" ON public.payments
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "본인 상환기록만 수정" ON public.payments
  FOR UPDATE USING (auth.uid() = user_id);

-- badges
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "본인 배지만 조회" ON public.badges
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "본인 배지만 추가" ON public.badges
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- 회원가입 시 자동 프로필 생성 함수
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name, auth_provider)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'display_name', '새로운여행자'),
    COALESCE(NEW.raw_app_meta_data->>'provider', 'email')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- 마이그레이션: payments 테이블에 원금/이자 분리 컬럼 추가
-- 기존 테이블이 있는 경우 아래 ALTER만 실행하세요
-- ============================================
ALTER TABLE public.payments
  ADD COLUMN IF NOT EXISTS principal_amount INT,
  ADD COLUMN IF NOT EXISTS interest_amount INT;

-- 마이그레이션: debts 테이블에 대출 기간 컬럼 추가
ALTER TABLE public.debts ADD COLUMN IF NOT EXISTS loan_term_months INT;
