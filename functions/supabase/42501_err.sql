-- `42501` Postgres 错误码：权限拒绝；提示需要 `GRANT ... TO service_role`

revoke all on public.parent_profile from anon;
revoke all on public.parent_profile from authenticated;
