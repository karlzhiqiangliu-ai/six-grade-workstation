select column_name, is_nullable
from information_schema.columns
where table_name = 'parent_profile';
