REVOKE ALL ON public.customer_org, public.parent_profile FROM anon;
DROP POLICY IF EXISTS "anon_all_customer_org" ON public.customer_org;
DROP POLICY IF EXISTS "anon_all_parent_profile" ON public.parent_profile;
