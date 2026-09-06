-- 家长档案插入模板（parent_profile）
-- 用法（路径 A：本地算哈希 + SQL Editor 执行，无需任何密钥）
-- 1) pwd_hash 必须先在本地用 bcrypt 算好（明文密码不出本机、不入库）。
--    本机生成：bcrypt.hashpw("明文", bcrypt.gensalt(rounds=4)).decode()  → 60 字符串
--    或直接在下面用 Postgres 内置 pgcrypto（明文仅在本 SQL 会话内，不落库）：
--      pwd_hash = crypt('明文密码', gen_salt('bf', 4))
-- 2) 把 <PWD_HASH> 替换为真实哈希串，填好其余字段，在 Supabase SQL Editor 执行。
-- 说明：anon/authenticated 已被 REVOKE，本表只能经 SQL Editor 或服务端 service_role 写入。

INSERT INTO public.parent_profile (username, pwd_hash, real_name, phone, child_name, child_grade, remark)
VALUES (
  'Karl',                 -- username（唯一索引，作登录名）
  '<PWD_HASH>',           -- 预计算的 bcrypt 哈希（或 crypt('明文', gen_salt('bf',4))）
  'Karl Zhiqiang Liu',
  '+18601700327',
  'BIDI LIU',
  3,                      -- child_grade：数字
  'BOY'                   -- remark：自由备注
)
RETURNING id, username, real_name, phone, child_name, child_grade, remark, created_at;
