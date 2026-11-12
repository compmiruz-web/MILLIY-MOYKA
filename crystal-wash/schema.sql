-- CRYSTAL WASH SAM MOYKA — 1-bosqich bazasi
-- Summalar to'liq so'mda (bigint)

create table if not exists public.tushum (
  id bigint generated always as identity primary key,
  sana date not null default current_date,
  summa bigint not null check (summa >= 0),
  izoh text,
  created_at timestamptz not null default now()
);

create table if not exists public.rasxod (
  id bigint generated always as identity primary key,
  sana date not null default current_date,
  summa bigint not null check (summa >= 0),
  turi text not null default 'BOSHQA',
  kimga text,
  izoh text,
  created_at timestamptz not null default now()
);

create table if not exists public.yetkazuvchilar (
  id bigint generated always as identity primary key,
  nomi text not null unique,
  tel text,
  izoh text,
  created_at timestamptz not null default now()
);

create table if not exists public.qarz_olingan (
  id bigint generated always as identity primary key,
  yetkazuvchi_id bigint not null references public.yetkazuvchilar(id) on delete cascade,
  sana date not null default current_date,
  nima text,
  summa bigint not null check (summa >= 0),
  created_at timestamptz not null default now()
);

create table if not exists public.xodimlar (
  id bigint generated always as identity primary key,
  ism text not null unique,
  oylik bigint not null default 0,
  faol boolean not null default true,
  created_at timestamptz not null default now()
);

create table if not exists public.exson_berildi (
  id bigint generated always as identity primary key,
  sana date not null default current_date,
  summa bigint not null check (summa >= 0),
  izoh text,
  created_at timestamptz not null default now()
);

create table if not exists public.sozlamalar (
  kalit text primary key,
  qiymat text
);
insert into public.sozlamalar(kalit, qiymat) values ('exson_foiz','5') on conflict do nothing;

create index if not exists tushum_sana on public.tushum(sana);
create index if not exists rasxod_sana on public.rasxod(sana);
create index if not exists qarz_olingan_y on public.qarz_olingan(yetkazuvchi_id);

-- RLS: hammasi yoqilgan. 1-bosqichda vaqtincha ochiq (anon) siyosat;
-- 2-bosqichda (login + PIN) bu siyosatlar olib tashlanib, faqat ruxsatli
-- foydalanuvchilarga beriladi.
do $$
declare t text;
begin
  foreach t in array array['tushum','rasxod','yetkazuvchilar','qarz_olingan','xodimlar','exson_berildi','sozlamalar'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('drop policy if exists bosqich1_ochiq on public.%I', t);
    execute format('create policy bosqich1_ochiq on public.%I for all to anon, authenticated using (true) with check (true)', t);
    execute format('alter publication supabase_realtime add table public.%I', t);
  end loop;
end $$;
