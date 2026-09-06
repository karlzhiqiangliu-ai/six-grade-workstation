不再新增测试账号。请输出最终上线安全相关说明。我手动去 Supabase SQL 编辑器执行权限 SQL：`alter table public.parent_profile add column if not exists pwd_hash text; revoke all on public.parent_profile from anon; revoke all on public.parent_profile from authenticated;`

确认架构约束：所有数据库访问全部由 WorkBuddy 使用 service_role 密钥完成，浏览器前端不直接访问 Supabase，不需要开启 RLS 行级安全策略。

输出：
1）权限加固完成后的安全核对清单
2）注册 / 登录业务流程回顾
3）关键风险提醒（service_role 密钥禁止提交 git、禁止给到前端浏览器）
4）后续测试指令样例，用来验证注册、登录、查询账号
