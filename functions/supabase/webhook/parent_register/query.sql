-- 直接查询 parent_profile 表（查看刚刚插入的这条测试数据）
SELECT * FROM parent_profile WHERE username = 'test_user_01';

-- 按 id 查询（用返回的 uuid）
SELECT * 
FROM parent_profile 
WHERE id = '0c4a879f-df63-4c2c-ac07-f082b5691b7a';

-- 查看全部注册记录（分页，最新的在最上面）

SELECT * 
FROM parent_profile 
ORDER BY created_at DESC 
LIMIT 50;

-- 删除测试记录
-- delete from parent_profile where username = 'test_user_01';
