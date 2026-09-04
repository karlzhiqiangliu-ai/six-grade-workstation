# curl -X GET "https://klopmmqxxzlzrsjvwtrc.supabase.co/rest/v1/parent_profile?username=eq.test_user_01" \
-H "apikey: sb_publishable_IjJaZfFJwZLu8UNWhSZM1w_kpw0Ysom"

# 这个 `42501 permission denied` **是预期的正常结果，不是故障**，恰恰说明我们之前做的权限隔离生效了
### 报错原因

# 你这条 curl 用的是 `sb_publishable_` 开头的 **anon 公钥**，对应数据库角色是 `anon`。
而我们之前已经执行了：
# REVOKE ALL ON public.parent_profile FROM anon;

# 正确的查询方式（三选一）
# 方式 1：SQL 编辑器直接查（最推荐，验证数据用）
# 在 Supabase 网页 SQL 编辑器执行，走的是 `postgres` 超级用户，不受权限限制：
# SELECT * FROM parent_profile WHERE username = 'test_user_01';



### 方式 3：封装成 Edge Function 给前端调用

和注册接口同理，再写一个查询用的 Edge Function，服务端内部用 service_role 权限查完再返回，前端依然只传参数、不碰密钥。

# 绝对不要执行 `GRANT SELECT ON parent_profile TO anon;`

# 方式 2：用 service_role 密钥调用 REST API（后端用，绝对不能放前端）
#curl -X GET "https://klopmmqxxzlzrsjvwtrc.supabase.co/rest/v1/parent_profile?username=eq.test_user_01" \
-H "apikey: 你的service_role密钥" \
-H "Authorization: Bearer 你的service_role密钥"


curl -X GET "https://klopmmqxxzlzrsjvwtrc.supabase.co/rest/v1/parent_profile?username=eq.test_user_01" \
-H "apikey: 你的service_role密钥" \
-H "Authorization: Bearer 你的service_role密钥"

