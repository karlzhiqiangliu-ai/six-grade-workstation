-- prompt/grant_service_role_parent_profile.sql
-- 目的：在「anon/authenticated 已被 REVOKE」的基础上，仅向 service_role http通路授权。
--      安全终态：公开REST(anon/authenticated)无法读写；只有持有service_role密钥的服务端（WorkBuddy Webhook）可以读写。
--      重要：service_role是API密钥，数据库底层角色为 authenticator，必须授权给 authenticator；service_role数据库角色不存在。
--      service_role密钥自带bypassrls，不受RLS策略约束，但仍然需要显授予表、序列权限。
--
-- 在 Supabase SQL Editor 全选执行。

-- 剥夺普通外部账号全部权限
REVOKE ALL ON public.parent_profile FROM anon;
REVOKE ALL ON public.parent_profile FROM authenticated;

-- 给REST网关底层 authenticator 授权（service_role http接口走这个角色）
GRANT SELECT, INSERT, UPDATE, DELETE ON public.parent_profile TO authenticator;



-- 校验授权结果
SELECT
  grantee,
  privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND table_name   = 'parent_profile'
  AND grantee IN ('authenticator', 'anon', 'authenticated')
ORDER BY grantee, privilege_type;
