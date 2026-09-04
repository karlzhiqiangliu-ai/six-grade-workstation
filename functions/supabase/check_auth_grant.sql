SELECT
  grantee,
  privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'public'
  AND table_name   = 'parent_profile'
  AND grantee IN ('authenticator', 'anon', 'authenticated')
ORDER BY grantee, privilege_type;
