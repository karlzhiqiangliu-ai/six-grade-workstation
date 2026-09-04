-- 1. `service_role key`（http header）→ Supabase 网关，数据库侧切换为 `authenticator` 角色执行 SQL。
-- 2. 你执行 `revoke all ... from public`，把表对 authenticator 权限也收回 → 42501 permission denied。
-- 3. 上面 grant 语句恢复**仅 authenticator 角色权限**，外部用户`anon/authenticated`依旧零权限，安全架构不变。

-- 给 authenticator 角色授予 parent_profile 全部增删改查权限（service‑role http API底层使用这个db角色）
grant select,insert,update,delete on public.parent_profile to authenticator;

-- 如果有自增id序列，序列权限也要给，否则插入报序列权限错误
grant usage,select on sequence public.parent_profile_id_seq to authenticator;
