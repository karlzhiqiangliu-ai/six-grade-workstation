-- 1.列不存在才新增，避免重复报错
alter table public.parent_profile
add column if not exists pwd_hash text;

-- 2.收回匿名、登录用户全部权限
revoke all on public.parent_profile from anon;
revoke all on public.parent_profile from authenticated;
