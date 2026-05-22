-- Table for test users without Supabase Auth email confirmation
-- WARNING: This stores passwords in plain text for testing only.
-- Do not use this schema in production.

create table if not exists public.app_users (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  email text not null unique,
  password text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create or replace function public.set_updated_at_app_users()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists app_users_set_updated_at on public.app_users;
create trigger app_users_set_updated_at
before update on public.app_users
for each row
execute function public.set_updated_at_app_users();

alter table public.app_users enable row level security;

-- Allow the app to register and log in test users from the client.
-- This is intentionally open for a test-only workflow.
drop policy if exists "Allow read app users" on public.app_users;
create policy "Allow read app users"
on public.app_users
for select
using (true);

drop policy if exists "Allow insert app users" on public.app_users;
create policy "Allow insert app users"
on public.app_users
for insert
with check (true);

drop policy if exists "Allow update app users" on public.app_users;
create policy "Allow update app users"
on public.app_users
for update
using (true)
with check (true);
