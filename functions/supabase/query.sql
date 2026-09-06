-- 查看表权限
select grantee, privilege_type 
from information_schema.table_privileges 
where table_name='parent_profile';
