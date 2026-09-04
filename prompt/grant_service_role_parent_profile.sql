-- prompt/grant_service_role_parent_profile.sql
-- 目的：在「anon/authenticated 已被 REVOKE」的基础上，仅向 service_role 授权。
--       这是安全的终态：公开 REST 无法读写；只有持 service_role 密钥的服务端（WorkBuddy Webhook）能写。
--       注意 service_role 自带 bypassrls，不受 RLS 限制，但仍需显式表权限。
--
-- 在 Supabase SQL Editor 全选执行。

GRANT SELECT, INSERT, UPDATE, DELETE ON public.parent_profile TO service_role;

-- 确认授权已生效（返回应包含 service_role 一行）
SELECT
  grantee,
  privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND table_name   = 'parent_profile'
  AND grantee IN ('service_role', 'anon', 'authenticated')
ORDER BY grantee, privilege_type;
