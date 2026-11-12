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

insert into tushum(sana,summa) values
('2026-06-14',919),
('2026-06-15',2439),
('2026-06-16',2555),
('2026-06-17',0),
('2026-06-18',2489),
('2026-06-19',2506),
('2026-06-20',2418),
('2026-06-21',3195),
('2026-06-22',2556),
('2026-06-23',1980),
('2026-06-24',1360),
('2026-06-25',3097),
('2026-06-26',2860),
('2026-06-27',1802),
('2026-06-28',2421),
('2026-06-29',2568),
('2026-06-30',2153),
('2026-07-01',2410),
('2026-07-02',1680),
('2026-07-03',3165),
('2026-07-04',1588),
('2026-07-05',3320),
('2026-07-06',1953),
('2026-07-07',1820),
('2026-07-08',1780),
('2026-07-09',2245),
('2026-07-10',2386),
('2026-07-11',1860),
('2026-07-12',2320),
('2026-07-13',2923),
('2026-07-14',2182),
('2026-07-15',2180),
('2026-07-16',2220),
('2026-07-17',2774),
('2026-07-18',2593),
('2026-07-19',2420),
('2026-07-20',2200),
('2026-07-21',1625),
('2026-07-22',1609),
('2026-07-23',3915),
('2026-07-24',3677),
('2026-07-25',3600),
('2026-07-26',2792),
('2026-07-27',2713),
('2026-07-28',1922),
('2026-07-29',2363),
('2026-07-30',1914),
('2026-07-31',2100),
('2026-08-01',2362),
('2026-08-02',2725),
('2026-08-03',2344),
('2026-08-04',1972),
('2026-08-05',2127),
('2026-08-06',2400),
('2026-08-07',2552),
('2026-08-08',2458),
('2026-08-09',2993),
('2026-08-10',2596),
('2026-08-11',2365),
('2026-08-12',2596),
('2026-08-13',1937),
('2026-08-14',1075),
('2026-08-15',0),
('2026-08-16',0),
('2026-08-17',0),
('2026-08-18',0),
('2026-08-19',2855),
('2026-08-20',2300),
('2026-08-21',2548),
('2026-08-22',1625),
('2026-08-23',3306),
('2026-08-24',3080),
('2026-08-25',2155),
('2026-08-26',2087),
('2026-08-27',2176),
('2026-08-28',1639),
('2026-08-29',2003),
('2026-08-30',2600),
('2026-08-31',1889),
('2026-09-01',2912),
('2026-09-02',2032),
('2026-09-03',1885),
('2026-09-04',1315),
('2026-09-05',4148),
('2026-09-06',3961),
('2026-09-07',3100),
('2026-09-08',2153),
('2026-09-09',2060),
('2026-09-10',2304),
('2026-09-11',2041),
('2026-09-12',2150),
('2026-09-13',2456),
('2026-09-14',2702),
('2026-09-15',2140),
('2026-09-16',1962),
('2026-09-17',2506),
('2026-09-18',2400),
('2026-09-19',2330),
('2026-09-20',2635),
('2026-09-21',3065),
('2026-09-22',2040),
('2026-09-23',2085),
('2026-09-24',0),
('2026-09-25',5216),
('2026-09-26',4089),
('2026-09-27',3419),
('2026-09-28',2535),
('2026-09-29',1250),
('2026-09-30',1805),
('2026-10-01',0),
('2026-10-02',4250),
('2026-10-03',3190),
('2026-10-04',1676),
('2026-10-05',0),
('2026-10-06',4065),
('2026-10-07',4944),
('2026-10-08',3763),
('2026-10-09',2635),
('2026-10-10',2486),
('2026-10-11',2506),
('2026-10-12',0),
('2026-10-13',3900),
('2026-10-14',3831),
('2026-10-15',3150),
('2026-10-16',2300),
('2026-10-17',2779),
('2026-10-18',1819),
('2026-10-19',2779),
('2026-10-20',1932),
('2026-10-21',2325),
('2026-10-22',2173),
('2026-10-23',230),
('2026-10-24',2434),
('2026-10-25',2824),
('2026-10-26',2120),
('2026-10-27',2036),
('2026-10-28',923),
('2026-10-29',2321)
on conflict (sana) do nothing;

insert into rasxod(sana,summa,turi,kimga,izoh)
select * from (values
('2026-06-16'::date,34673::numeric,'BOLINMAGAN',null,'IYUN OYI JAMI RASXOD (kunlarga bolinmagan)'),
('2026-07-01'::date,64403::numeric,'BOLINMAGAN',null,'IYUL OYI JAMI RASXOD (kunlarga bolinmagan)'),
('2026-08-01'::date,66024::numeric,'BOLINMAGAN',null,'AVGUST OYI JAMI RASXOD (kunlarga bolinmagan)'),
('2026-09-03'::date,50::numeric,'BOSHQA','MIJOZ','MIJOZGA TALOFAT'),
('2026-09-04'::date,1000::numeric,'OYLIK','ABDULBOQIY','OYLIK'),
('2026-09-04'::date,350::numeric,'REMONT / EHTIYOT QISM',null,'KALODIS'),
('2026-09-05'::date,2500::numeric,'SVET',null,'SVETGA TOLOV'),
('2026-09-06'::date,240::numeric,'XIMIYA',null,'BALON QORAYTIRGICH'),
('2026-09-06'::date,5460::numeric,'REMONT / EHTIYOT QISM','ABDURAHIM AKA','ASFALT'),
('2026-09-06'::date,1000::numeric,'BOSHQA','MUHAMMADUMAR',null),
('2026-09-06'::date,162::numeric,'OBED',null,'OBED 4 KUNLIK'),
('2026-09-07'::date,40::numeric,'REMONT / EHTIYOT QISM',null,'SHTUTSER'),
('2026-09-07'::date,90::numeric,'OYLIK','ABDULBOQIY',null),
('2026-09-08'::date,380::numeric,'OYLIK','ABDULBOQIY',null),
('2026-09-09'::date,1000::numeric,'BOSHQA','ABDULMUHSIN',null),
('2026-09-09'::date,55::numeric,'REMONT / EHTIYOT QISM',null,'MOTOR YOG'),
('2026-09-09'::date,20::numeric,'BOSHQA','SHOPIR','ANDIJON SHOPIR'),
('2026-09-10'::date,24::numeric,'REMONT / EHTIYOT QISM',null,'FILTR'),
('2026-09-10'::date,30::numeric,'XIMIYA',null,'LIMON KISLOTA'),
('2026-09-11'::date,530::numeric,'BOSHQA','SANNIY ANDIJON',null),
('2026-09-11'::date,380::numeric,'XIMIYA',null,'GROSS NANO 5KG'),
('2026-09-11'::date,380::numeric,'XIMIYA',null,'GROSS VOSK 5KG'),
('2026-09-11'::date,500::numeric,'OYLIK','ABDULBOQIY',null),
('2026-09-11'::date,820::numeric,'XIMIYA','KAMINAT','PENA'),
('2026-09-11'::date,1250::numeric,'QARZ TOLOV','KAMINAT','PENA QARZI'),
('2026-09-13'::date,8680::numeric,'QARZ TOLOV','SHUKURULLOH AKA','7500 + 100$'),
('2026-09-14'::date,1730::numeric,'XIMIYA','BOBUR AKA','PENA'),
('2026-09-16'::date,110::numeric,'REMONT / EHTIYOT QISM',null,'GUPKA'),
('2026-09-17'::date,380::numeric,'XIMIYA','SADULLA','VOSK'),
('2026-09-17'::date,190::numeric,'XIMIYA','SADULLA','BALON QORAYTIRGICH'),
('2026-09-19'::date,850::numeric,'OYLIK','ABDULBOQIY',null),
('2026-09-19'::date,30::numeric,'OBED',null,null),
('2026-09-21'::date,50::numeric,'OYLIK','ABDULBOQIY',null),
('2026-09-21'::date,42::numeric,'OBED',null,null),
('2026-09-22'::date,15::numeric,'XIMIYA',null,'BALON Q COLA'),
('2026-09-22'::date,40::numeric,'BOSHQA','SHOPIR',null),
('2026-09-23'::date,22000::numeric,'QARZ TOLOV','RUSTAMJON',null),
('2026-09-23'::date,3000::numeric,'OYLIK','ABDULBOQIY',null),
('2026-09-23'::date,800::numeric,'XIMIYA','BOBUR AKA','AKTIV XIMIYA 2 TA'),
('2026-09-23'::date,450::numeric,'XIMIYA','BOBUR AKA','PENA'),
('2026-09-23'::date,380::numeric,'XIMIYA','SADULLA','VOSK'),
('2026-09-23'::date,190::numeric,'XIMIYA','SADULLA','BALON QORAYTIRGICH'),
('2026-09-25'::date,25::numeric,'XIMIYA',null,'BALON Q COLA'),
('2026-09-25'::date,250::numeric,'BOSHQA','ABDULMUHSIN',null),
('2026-09-25'::date,120::numeric,'BOSHQA','SANNIY ANDIJON',null),
('2026-09-25'::date,800::numeric,'XIMIYA','BOBUR AKA','AKTIV XIMIYA 2 TA'),
('2026-09-25'::date,450::numeric,'XIMIYA','BOBUR AKA','PENA'),
('2026-09-25'::date,50::numeric,'XIMIYA','BOBUR AKA','BALON QORAYTIRGICH'),
('2026-09-26'::date,50::numeric,'OBED',null,null),
('2026-09-26'::date,100::numeric,'REMONT / EHTIYOT QISM',null,'FILTR'),
('2026-09-26'::date,10::numeric,'REMONT / EHTIYOT QISM',null,'VILKA'),
('2026-09-26'::date,20::numeric,'XIMIYA',null,'LIMON KISLOTA'),
('2026-09-27'::date,800::numeric,'XIMIYA','BOBUR AKA','AKTIV XIMIYA 2 TA'),
('2026-09-27'::date,450::numeric,'XIMIYA','BOBUR AKA','PENA'),
('2026-09-28'::date,50::numeric,'OYLIK','ABDULBOQIY',null),
('2026-09-28'::date,380::numeric,'XIMIYA','SADULLA','VOSK'),
('2026-09-28'::date,190::numeric,'XIMIYA','SADULLA','BALON QORAYTIRGICH'),
('2026-09-29'::date,200::numeric,'OYLIK','ABDULBOQIY',null),
('2026-09-29'::date,100::numeric,'REMONT / EHTIYOT QISM','USTA','NERJAVEYKA'),
('2026-09-29'::date,230::numeric,'REMONT / EHTIYOT QISM',null,'SANGEN'),
('2026-09-29'::date,40::numeric,'XIMIYA',null,'PENA 1L'),
('2026-09-30'::date,9980::numeric,'ARENDA',null,'ARENDA'),
('2026-10-01'::date,550::numeric,'OYLIK','ABDULBOQIY',null),
('2026-10-02'::date,5574::numeric,'SVET',null,'SVET SENTYABR'),
('2026-10-02'::date,180::numeric,'REMONT / EHTIYOT QISM',null,'BLOK PITANIYA'),
('2026-10-05'::date,70::numeric,'BOSHQA',null,'MOYKA LOYI'),
('2026-10-05'::date,600::numeric,'OYLIK','ABDULBOQIY',null),
('2026-10-07'::date,15::numeric,'XIMIYA',null,'KOLA BALON Q'),
('2026-10-07'::date,20::numeric,'REMONT / EHTIYOT QISM',null,'SHLANKA'),
('2026-10-08'::date,750::numeric,'BOSHQA','ABDULMUHSIN',null),
('2026-10-08'::date,1000::numeric,'BOSHQA','MUHAMMADUMAR',null),
('2026-10-09'::date,650::numeric,'OYLIK','ABDULBOQIY',null),
('2026-10-09'::date,250::numeric,'REMONT / EHTIYOT QISM',null,'SUV NASOS REMONT'),
('2026-10-09'::date,40::numeric,'OBED',null,null),
('2026-10-09'::date,530::numeric,'XIMIYA','NAZZOF','XIMIYA'),
('2026-10-10'::date,11930::numeric,'APARAT TOLOV',null,'APARAT 2 OYLIK 1000$'),
('2026-10-10'::date,300::numeric,'BOSHQA','ABDULMUHSIN',null),
('2026-10-10'::date,2530::numeric,'REMONT / EHTIYOT QISM',null,'PLATA REMONT'),
('2026-10-11'::date,4150::numeric,'QARZ TOLOV','BOBUR AKA','PENA QARZI'),
('2026-10-11'::date,200::numeric,'OYLIK','ABDULBOQIY',null),
('2026-10-11'::date,15::numeric,'XIMIYA',null,'KOLA BALON Q'),
('2026-10-11'::date,20::numeric,'REMONT / EHTIYOT QISM',null,'ATVERKA NABOR'),
('2026-10-11'::date,50::numeric,'REMONT / EHTIYOT QISM',null,'MOTOR'),
('2026-10-11'::date,88::numeric,'OBED',null,null),
('2026-10-13'::date,80::numeric,'REMONT / EHTIYOT QISM','USTA IZZATILLO',null),
('2026-10-13'::date,30::numeric,'BOSHQA',null,'TAKSI'),
('2026-10-14'::date,200::numeric,'OYLIK','ABDULBOQIY',null),
('2026-10-14'::date,1040::numeric,'XIMIYA','NAZZOF','XIMIYA'),
('2026-10-14'::date,75::numeric,'OBED',null,null),
('2026-10-14'::date,35::numeric,'OBED',null,'UJIN'),
('2026-10-14'::date,300::numeric,'BOSHQA',null,'YAMANI SUVI OLINDI (GANDAVOZ)'),
('2026-10-14'::date,30::numeric,'OYLIK','ABDULBOQIY',null),
('2026-10-14'::date,1140::numeric,'QARZ TOLOV','SADULLA','QARZ: VOSK 2 TA, GILISIN 2 TA'),
('2026-10-14'::date,15::numeric,'XIMIYA',null,'KOLA BALON Q'),
('2026-10-15'::date,1500::numeric,'OYLIK','QORAVUL ROSHAN',null),
('2026-10-15'::date,520::numeric,'XIMIYA',null,'XIMIYA'),
('2026-10-15'::date,1000::numeric,'BOSHQA','MUHAMMADUMAR','SENTYABR OYI UCHUN (NOZI BERGAN)'),
('2026-10-15'::date,25::numeric,'XIMIYA',null,'LIMON KISLOTA'),
('2026-10-15'::date,12::numeric,'REMONT / EHTIYOT QISM',null,'FILTR'),
('2026-10-15'::date,350::numeric,'OYLIK','ABDULBOQIY',null),
('2026-10-15'::date,200::numeric,'REMONT / EHTIYOT QISM',null,'GULBINA NASOS'),
('2026-10-15'::date,980::numeric,'XIMIYA','NAZZOF','XIMIYA 2 TA x 490'),
('2026-10-15'::date,500::numeric,'XIMIYA','NAZZOF','PENA 1 TA'),
('2026-10-15'::date,10::numeric,'BOSHQA','SHOPIR',null),
('2026-10-15'::date,45::numeric,'BOSHQA',null,'PAYNET'),
('2026-10-15'::date,20::numeric,'BOSHQA',null,'FARQ: kun jami 5162, qatorlar 5142 - TEKSHIRING'),
('2026-10-17'::date,700::numeric,'OYLIK','ABDULBOQIY',null),
('2026-10-17'::date,100::numeric,'REMONT / EHTIYOT QISM','USTA IZZATILLO',null),
('2026-10-18'::date,200::numeric,'REMONT / EHTIYOT QISM',null,'ULKA'),
('2026-10-18'::date,220::numeric,'REMONT / EHTIYOT QISM',null,'REM KAMPLEKT'),
('2026-10-18'::date,40::numeric,'BOSHQA','SHOPIR',null),
('2026-10-18'::date,15::numeric,'BOSHQA',null,'PAYNET USLUGA'),
('2026-10-18'::date,300::numeric,'OYLIK','ABDULBOQIY',null),
('2026-10-18'::date,4725::numeric,'QARZ TOLOV','SALOHIDDIN','TEMIR QARZI'),
('2026-10-18'::date,870::numeric,'XIMIYA','MURODILJON','XIMIYA'),
('2026-10-19'::date,2000::numeric,'OYLIK','QORAVUL MADAMIN',null),
('2026-10-19'::date,100::numeric,'REMONT / EHTIYOT QISM',null,'SANTEHNIKA'),
('2026-10-19'::date,15::numeric,'XIMIYA',null,'KOLA BALON Q'),
('2026-10-19'::date,5::numeric,'REMONT / EHTIYOT QISM',null,'IZALENTA'),
('2026-10-20'::date,1070::numeric,'REMONT / EHTIYOT QISM',null,'GULBINA NASOS, SHLANKA, XOMIT, ATVERYORKA, AMERIKANKA'),
('2026-10-20'::date,220::numeric,'XIMIYA',null,'TABLETKA 20 TA x 11'),
('2026-10-20'::date,54::numeric,'REMONT / EHTIYOT QISM',null,'KNOPKA 2 TA x 27'),
('2026-10-20'::date,375::numeric,'OYLIK','ABDULBOQIY',null),
('2026-10-22'::date,500::numeric,'OYLIK','ABDULBOQIY',null),
('2026-10-23'::date,175::numeric,'OYLIK','ABDULBOQIY',null),
('2026-10-23'::date,1200::numeric,'XIMIYA','SADULLA','XIMIYA / VOSK'),
('2026-10-24'::date,7700::numeric,'QARZ TOLOV','TUNIKA','QARZ'),
('2026-10-25'::date,260::numeric,'REMONT / EHTIYOT QISM',null,'PUSKATEL OSMOS'),
('2026-10-28'::date,540::numeric,'OYLIK','ABDULBOQIY',null),
('2026-10-28'::date,9370::numeric,'ARENDA',null,'ARENDA'),
('2026-10-30'::date,320::numeric,'OYLIK','ABDULBOQIY',null),
('2026-10-30'::date,480::numeric,'XIMIYA','MURODILJON','XIMIYA')
) v where not exists (select 1 from rasxod);

-- Supabase panelida yaratilgan har bir yangi foydalanuvchi avtomatik ruxsat oladi
-- (ochiq ro'yxatdan o'tish o'chirilgan: Authentication > Sign In / Providers)
create or replace function public.yangi_foydalanuvchiga_ruxsat() returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.ruxsat_etilganlar(user_id, izoh) values (new.id, new.email) on conflict do nothing;
  return new;
end $$;
drop trigger if exists ruxsat_avtomatik on auth.users;
create trigger ruxsat_avtomatik after insert on auth.users for each row execute function public.yangi_foydalanuvchiga_ruxsat();
