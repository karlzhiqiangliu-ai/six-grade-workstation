
alter table public.parent_profile 
alter column real_name drop not null,
alter column phone drop not null,
alter column child_name drop not null,
alter column child_grade drop not null,
alter column remark drop not null;
