# 家长账号注册流程（自定义业务表方案 · 2026-09-03 定稿）

> 决策：不使用 Supabase Auth，完全用自定义表 `parent_profile` 自行维护 `username`+`pwd_hash`，跳过 auth 用户创建。

## 前置：改表结构（一次性，需先在 Supabase SQL Editor 执行）
见同目录 `fix_parent_profile_custom.sql`：
- 去掉 `id` 对 `auth.users` 的外键约束；
- `id` 改为 `gen_random_uuid()` 自生成；
- 新增 `username`（唯一索引）与 `pwd_hash` 两列；
- 给 anon 放行读写（仅测试期，正式上线改 service_role/RLS）。

执行后再跑下面两步。

## 第一步：本地 bcrypt 哈希（明文密码不出本机）
- 原文档指定的 `https://api.hashify.net/hash/bcrypt/4` 已失效（hashify 不再支持 bcrypt）。
- 改用本地 `bcrypt`（managed Python venv 已装）：`bcrypt.hashpw(plain_password, bcrypt.gensalt(rounds=4))` → `pwd_hash`（60 字符）。
- 明文密码只在本机参与哈希，**绝不写入数据库**。

## 第二步：写入 parent_profile（直接操作业务表）
```
POST ${SUPABASE_URL}/rest/v1/parent_profile
Headers: apikey:${SUPABASE_ANON_KEY}, Authorization: Bearer ${SUPABASE_ANON_KEY},
         Content-Type:application/json, Prefer:return=representation
Body: {
  "username": "<登录名>",
  "pwd_hash": "<第一步 bcrypt 哈希>",
  "real_name": "<真实姓名>",
  "phone": "<手机号>",
  "child_name": "<孩子名>",
  "child_grade": <年级数字>,
  "remark": "<备注>"
}
```
- `id` 由表自生成，无需传。
- 返回最终插入行即成功。

## 实测得到的原始结构（探测记录，仅供对照）
- 原 `parent_profile` 列：`id`(PK, 外键→auth.users.id)、`phone`、`real_name`、`child_name`、`child_grade`、`remark`、`created_at`。
- 原无 `username`、无密码列；Auth 电话注册被禁用（`phone_provider_disabled`）。
- 探明过程：带 pwd_hash→PGRST204(无列)；纯资料→报 username 缺失；5 有效列→23502(id NOT NULL)；自造 uuid→23503(外键约束)。故改为自定义表方案。
