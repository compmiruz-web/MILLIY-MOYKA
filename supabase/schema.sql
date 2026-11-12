-- SAMMOYKA XISOB-KITOB : Supabase baza sxemasi
-- Supabase > SQL Editor ga to'liq tashlab RUN bosing (bir marta).

create table if not exists tushum (
  id bigserial primary key,
  sana date not null unique,
  summa numeric not null default 0,
  izoh text,
  created_at timestamptz default now()
);

create table if not exists rasxod (
  id bigserial primary key,
  sana date not null,
  summa numeric not null,
  turi text not null default 'BOSHQA',
  kimga text,
  izoh text,
  created_at timestamptz default now()
);
create index if not exists rasxod_sana_idx on rasxod(sana);

create table if not exists yetkazuvchilar (
  kim text primary key,
  boshlangich_qarz numeric not null default 0
);

create table if not exists qarz_olingan (
  id bigserial primary key,
  sana date not null,
  kim text not null references yetkazuvchilar(kim) on update cascade,
  nima text,
  summa numeric not null,
  created_at timestamptz default now()
);

create table if not exists xodimlar (
  ism text primary key,
  oylik numeric not null default 0,
  faol boolean not null default true
);

create table if not exists exson_berildi (
  id bigserial primary key,
  sana date not null,
  summa numeric not null,
  izoh text,
  created_at timestamptz default now()
);

create table if not exists sozlamalar (
  kalit text primary key,
  qiymat text
);

-- Xavfsizlik: faqat ruxsat_etilganlar ro'yxatidagi foydalanuvchilar ishlay oladi
create table if not exists public.ruxsat_etilganlar (user_id uuid primary key references auth.users(id) on delete cascade, izoh text);
alter table public.ruxsat_etilganlar enable row level security;
revoke all on public.ruxsat_etilganlar from anon, authenticated;
create or replace function public.ruxsat_bormi() returns boolean language sql stable security definer set search_path = public as $f$
  select exists(select 1 from public.ruxsat_etilganlar where user_id = auth.uid());
$f$;
revoke all on function public.ruxsat_bormi() from public, anon;
grant execute on function public.ruxsat_bormi() to authenticated;
do $$ declare t text; begin
  foreach t in array array['tushum','rasxod','yetkazuvchilar','qarz_olingan','xodimlar','exson_berildi','sozlamalar'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists "auth_all" on public.%I', t);
    execute format('drop policy if exists "faqat_ruxsatli" on public.%I', t);
    execute format('create policy "faqat_ruxsatli" on public.%I for all to authenticated using (public.ruxsat_bormi()) with check (public.ruxsat_bormi())', t);
    execute format('revoke all on public.%I from anon', t);
  end loop;
end $$;
-- Yangi foydalanuvchiga ruxsat berish (Authentication > Users da yaratgandan keyin):
-- insert into public.ruxsat_etilganlar(user_id, izoh) select id, 'xodim' from auth.users where email='EMAIL';

-- ===== BOSHLANG'ICH MA'LUMOTLAR (Excel fayllardan) =====
insert into sozlamalar(kalit,qiymat) values ('exson_foiz','5') on conflict do nothing;


insert into xodimlar(ism,oylik) values ('ABDULBOQIY',6000),('QORAVUL ROSHAN',1500),('QORAVUL MADAMIN',2000) on conflict do nothing;

insert into yetkazuvchilar(kim) values ('SHUKURULLOH AKA'),('RUSTAMJON'),('KAMINAT'),('BOBUR AKA'),('SADULLA'),('SALOHIDDIN'),('TUNIKA'),('MURODILJON'),('NAZZOF') on conflict do nothing;

-- (Tushum va rasxodning boshlang'ich ma'lumotlari 12.11.2026 da egasining so'rovi bilan olib tashlandi)

-- Supabase panelida yaratilgan har bir yangi foydalanuvchi avtomatik ruxsat oladi
-- (ochiq ro'yxatdan o'tish o'chirilgan: Authentication > Sign In / Providers)
create or replace function public.yangi_foydalanuvchiga_ruxsat() returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.ruxsat_etilganlar(user_id, izoh) values (new.id, new.email) on conflict do nothing;
  return new;
end $$;
drop trigger if exists ruxsat_avtomatik on auth.users;
create trigger ruxsat_avtomatik after insert on auth.users for each row execute function public.yangi_foydalanuvchiga_ruxsat();

-- ===== 2026-11-12: qarzlar so'mda va dollarda =====
alter table yetkazuvchilar add column if not exists boshlangich_usd numeric not null default 0;
alter table qarz_olingan add column if not exists valyuta text not null default 'uzs';
alter table qarz_olingan drop constraint if exists qarz_olingan_valyuta_check;
alter table qarz_olingan add constraint qarz_olingan_valyuta_check check (valyuta in ('uzs','usd'));
alter table rasxod add column if not exists summa_usd numeric;
alter table rasxod add column if not exists kurs numeric;

-- ===== 2026-11-12: sheriklar qarzi =====
create table if not exists sheriklar (ism text primary key, tartib int not null default 0);
create table if not exists sherik_qarz (
  id bigserial primary key,
  sherik text not null references sheriklar(ism) on update cascade on delete cascade,
  turi text not null default 'qarz' check (turi in ('qarz','tolov','shaxsiy','shaxsiy_qaytar')),
  xaqdor text, sana date not null default current_date,
  summa numeric not null check (summa > 0),
  valyuta text not null default 'usd' check (valyuta in ('uzs','usd')),
  kurs numeric, izoh text,
  rasxod_id bigint references rasxod(id) on delete set null,
  created_at timestamptz default now()
);
-- RLS: faqat_ruxsatli (ruxsat_bormi()) — boshqa jadvallar kabi
insert into sheriklar(ism,tartib) values ('ABDULMUHSIN',1),('MUHAMMADUMAR',2) on conflict do nothing;
