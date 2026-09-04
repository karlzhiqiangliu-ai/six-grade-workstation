-- ============================================================
-- Supabase 权限修复 SQL
-- 作用：消除 anon 角色读写 customer_org / parent_profile 时的
--       42501 permission denied（HTTP 401）
-- 适用：Supabase SQL Editor 全选执行
-- 说明：anon key 是公开 key，以下策略等于「全网可匿名读写这两张表」，
--       仅适合开发/测试期；正式上线请改用 service_role 或带登录态的 RLS。
-- ============================================================

-- ---------- 1) customer_org ----------
GRANT SELECT, INSERT, UPDATE, DELETE ON public.customer_org TO anon;
DROP POLICY IF EXISTS "anon_all_customer_org" ON public.customer_org;
CREATE POLICY "anon_all_customer_org"
  ON public.customer_org
  FOR ALL TO anon
  USING (true) WITH CHECK (true);

-- ---------- 2) parent_profile（家长注册流程需要 anon 写入）----------
GRANT SELECT, INSERT, UPDATE, DELETE ON public.parent_profile TO anon;
DROP POLICY IF EXISTS "anon_all_parent_profile" ON public.parent_profile;
CREATE POLICY "anon_all_parent_profile"
  ON public.parent_profile
  FOR ALL TO anon
  USING (true) WITH CHECK (true);

-- ============================================================
-- 若你只想「快速验证连通性」而不在乎 RLS，可改用更粗暴的一行
-- （直接关掉这两张表的行级安全，配合上面的 GRANT 即可）：
--   ALTER TABLE public.customer_org DISABLE ROW LEVEL SECURITY;
--   ALTER TABLE public.parent_profile   DISABLE ROW LEVEL SECURITY;
-- ============================================================
