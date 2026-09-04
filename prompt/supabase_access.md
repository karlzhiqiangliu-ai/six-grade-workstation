你现在执行家长账号注册流程。
输入变量：username、plain_password、real_name、phone、child_name、child_grade、remark。
第一步：调用 https://api.hashify.net/hash/bcrypt/4，POST，把plain_password转为bcrypt哈希，得到pwd_hash。
第二步：调用Supabase REST API，POST {{SUPABASE_URL}}/rest/v1/parent_user
请求头：
apikey:{{SUPABASE_ANON_KEY}}
Content-Type:application/json
Prefer:return=representation
body里面传入username、pwd_hash，其余业务字段。
禁止把明文密码存入数据库。
返回最终插入结果。
