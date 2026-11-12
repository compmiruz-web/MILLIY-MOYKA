-- ===== 2026-11-12: Rahbar va ishchi profillari =====
-- Rahbar: hamma narsani ko'radi, qo'shadi, o'zgartiradi, o'chiradi.
-- Ishchi: faqat ruxsat berilgan narsani QO'SHADI (kunlik tushum, rasxod, qarzga olish, qarz berish);
--         o'zgartira va o'chira olmaydi. "Ishchi rejimi" o'chirilsa, ishchilar umuman kira olmaydi.

alter table public.ruxsat_etilganlar add column if not exists rol text not null default 'ishchi';
alter table public.ruxsat_etilganlar drop constraint if exists ruxsat_etilganlar_rol_check;
alter table public.ruxsat_etilganlar add constraint ruxsat_etilganlar_rol_check check (rol in ('rahbar','ishchi'));
alter table public.ruxsat_etilganlar add column if not exists ism text;
alter table public.ruxsat_etilganlar add column if not exists faol boolean not null default true;
alter table public.ruxsat_etilganlar add column if not exists ruxsat jsonb not null default '{"tushum":true,"rasxod":true,"qarz_ol":true,"qarz_ber":true}'::jsonb;
-- Hozirgi ikkala foydalanuvchi — rahbar
update public.ruxsat_etilganlar set rol = 'rahbar', ism = coalesce(ism, case when izoh = 'egasi' then 'Rahbar' else 'Umar' end)
 where rol = 'ishchi' and user_id in (select id from auth.users where created_at < '2026-11-12 18:00+00');
insert into public.sozlamalar(kalit, qiymat) values ('ishchi_rejim', '1') on conflict do nothing;

create or replace function public.rahbarmi() returns boolean language sql stable security definer set search_path = public as $f$
  select exists(select 1 from public.ruxsat_etilganlar where user_id = auth.uid() and rol = 'rahbar');
$f$;
create or replace function public.ishchi_ruxsat(k text) returns boolean language sql stable security definer set search_path = public as $f$
  select exists(select 1 from public.ruxsat_etilganlar r where r.user_id = auth.uid() and r.rol = 'ishchi' and r.faol
                  and coalesce((r.ruxsat->>k)::boolean, false))
     and coalesce((select qiymat from public.sozlamalar where kalit = 'ishchi_rejim'), '1') = '1';
$f$;
create or replace function public.ruxsat_bormi() returns boolean language sql stable security definer set search_path = public as $f$
  select public.rahbarmi() or exists(select 1 from public.ruxsat_etilganlar r where r.user_id = auth.uid() and r.rol = 'ishchi' and r.faol
         and coalesce((select qiymat from public.sozlamalar where kalit = 'ishchi_rejim'), '1') = '1');
$f$;
create or replace function public.men() returns jsonb language sql stable security definer set search_path = public as $f$
  select jsonb_build_object('rol', r.rol, 'ism', r.ism, 'faol', r.faol, 'ruxsat', r.ruxsat,
           'rejim', coalesce((select qiymat from public.sozlamalar where kalit = 'ishchi_rejim'), '1') = '1')
    from public.ruxsat_etilganlar r where r.user_id = auth.uid();
$f$;
-- Rahbar uchun: profillar ro'yxati (login bilan)
create or replace function public.profillar() returns jsonb language plpgsql stable security definer set search_path = public as $f$
begin
  if not public.rahbarmi() then raise exception 'Faqat rahbar'; end if;
  return (select coalesce(jsonb_agg(jsonb_build_object('id', r.user_id, 'rol', r.rol, 'ism', r.ism, 'faol', r.faol, 'ruxsat', r.ruxsat,
            'login', split_part(u.email, '@', 1), 'email', u.email, 'kirgan', u.last_sign_in_at) order by r.rol, r.ism), '[]'::jsonb)
            from public.ruxsat_etilganlar r join auth.users u on u.id = r.user_id);
end $f$;
create or replace function public.profil_saqla(p_id uuid, p jsonb) returns void language plpgsql security definer set search_path = public as $f$
begin
  if not public.rahbarmi() then raise exception 'Faqat rahbar'; end if;
  if p_id = auth.uid() and (p ? 'rol' and p->>'rol' <> 'rahbar' or p ? 'faol' and not (p->>'faol')::boolean) then
    raise exception 'O''zingizni rahbarlikdan chiqara olmaysiz';
  end if;
  update public.ruxsat_etilganlar set
    ism    = case when p ? 'ism' then nullif(trim(p->>'ism'), '') else ism end,
    rol    = case when p ? 'rol' then p->>'rol' else rol end,
    faol   = case when p ? 'faol' then (p->>'faol')::boolean else faol end,
    ruxsat = case when p ? 'ruxsat' then ruxsat || (p->'ruxsat') else ruxsat end
  where user_id = p_id;
end $f$;
revoke all on function public.rahbarmi(), public.ishchi_ruxsat(text), public.men(), public.profillar(), public.profil_saqla(uuid, jsonb) from public, anon;
grant execute on function public.rahbarmi(), public.ishchi_ruxsat(text), public.men(), public.profillar(), public.profil_saqla(uuid, jsonb) to authenticated;

-- Yangi foydalanuvchi endi ishchi bo'lib qo'shiladi (rahbarni faqat rahbar tayinlaydi)
create or replace function public.yangi_foydalanuvchiga_ruxsat() returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.ruxsat_etilganlar(user_id, izoh, rol, ism) values (new.id, new.email, 'ishchi', split_part(new.email, '@', 1)) on conflict do nothing;
  return new;
end $$;

-- Jadvallar: o'qish — ruxsati borlar; yozish — rahbar to'liq, ishchi faqat ruxsat berilganini qo'shadi
do $$ declare t text; begin
  foreach t in array array['tushum','rasxod','yetkazuvchilar','qarz_olingan','xodimlar','exson_berildi','sozlamalar','sheriklar','sherik_qarz'] loop
    execute format('drop policy if exists "faqat_ruxsatli" on public.%I', t);
    execute format('drop policy if exists "oqish" on public.%I', t);
    execute format('drop policy if exists "rahbar" on public.%I', t);
    execute format('drop policy if exists "ishchi_qoshish" on public.%I', t);
    execute format('create policy "oqish" on public.%I for select to authenticated using (public.ruxsat_bormi())', t);
    execute format('create policy "rahbar" on public.%I for all to authenticated using (public.rahbarmi()) with check (public.rahbarmi())', t);
  end loop;
end $$;
create policy "ishchi_qoshish" on public.tushum for insert to authenticated with check (public.ishchi_ruxsat('tushum'));
create policy "ishchi_qoshish" on public.rasxod for insert to authenticated with check (
  case when turi = 'QARZ TOLOV' then public.ishchi_ruxsat('qarz_ber') else public.ishchi_ruxsat('rasxod') end);
create policy "ishchi_qoshish" on public.qarz_olingan for insert to authenticated with check (public.ishchi_ruxsat('qarz_ol'));
create policy "ishchi_qoshish" on public.yetkazuvchilar for insert to authenticated with check (public.ishchi_ruxsat('qarz_ol'));
create policy "ishchi_qoshish" on public.sherik_qarz for insert to authenticated with check (
  case turi when 'qarz' then public.ishchi_ruxsat('qarz_ol') when 'tolov' then public.ishchi_ruxsat('qarz_ber') else false end);
