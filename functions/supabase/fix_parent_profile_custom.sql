-- ============================================================
-- 把 parent_profile 改成「自定义业务表」（不依赖 Supabase Auth）
-- 在 Supabase SQL Editor 全选执行；幂等，可重复跑。
-- ============================================================

-- 1) 去掉 id 对 auth.users 的外键约束（改为独立业务表）
ALTER TABLE public.parent_profile
  DROP CONSTRAINT IF EXISTS parent_profile_id_fkey;

-- 2) id 改为自动生成 UUID，插入时无需提供
ALTER TABLE public.parent_profile
  ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- 3) 加登录标识列 username（登录名），并建唯一索引防重复
ALTER TABLE public.parent_profile
  ADD COLUMN IF NOT EXISTS username text;
DROP INDEX IF EXISTS parent_profile_username_idx;
CREATE UNIQUE INDEX parent_profile_username_idx
  ON public.parent_profile (username);

-- 4) 加密码哈希列（存 bcrypt 哈希，明文密码永不进库）
ALTER TABLE public.parent_profile
  ADD COLUMN IF NOT EXISTS pwd_hash text;

-- 5) （可选）RLS 仍开启时，给 anon 放行读写以便注册/登录查询
--    仅开发测试期使用；正式上线请改用 service_role 或带登录态的 RLS 策略。
GRANT SELECT, INSERT, UPDATE, DELETE ON public.parent_profile TO anon;
DROP POLICY IF EXISTS "anon_all_parent_profile" ON public.parent_profile;
CREATE POLICY "anon_all_parent_profile"
  ON public.parent_profile FOR ALL TO anon USING (true) WITH CHECK (true);

-- 验证：看一眼现在有哪些列
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'parent_profile'
ORDER BY ordinal_position;
