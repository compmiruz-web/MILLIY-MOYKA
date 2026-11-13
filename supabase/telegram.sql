-- Telegram kunlik hisobot (2026-11-14)
create table if not exists public.bot_sozlama (kalit text primary key, qiymat text not null);
alter table public.bot_sozlama enable row level security;
revoke all on public.bot_sozlama from anon, authenticated;
-- insert: ('chat_id','<telegram id>'), ('cron_key', encode(extensions.gen_random_bytes(24),'hex'))
-- public.kunlik_hisobot_yubor(p_sana date) -> net.http_post .../functions/v1/kunlik-hisobot (x-cron-key)
-- select cron.schedule('kunlik-hisobot', '0 17 * * *', $$select public.kunlik_hisobot_yubor()$$);
