# LOYIHA PASPORTI — CRYSTAL WASH SAM MOYKA

Faqat CRYSTAL WASH SAM MOYKA xisob-kitob dasturi. MILLIY-MOYKA, COMPMIR, COM-TECH bilan aralashtirilmaydi.

## Holat (13.11.2026)
- Versiya: APP_V = 3 (version.json → {"v":3})
- v3: Xisobotda "📈 Oylar dinamikasi" (oxirgi 12 oy ustunlari, bosilsa oy ochiladi) va "📋 Barcha oylar bo'yicha" jadvali (tushum, rasxod, sof foyda, exson, JAMI)
- v2: qarzlar so'm va $ da (valyuta tanlanadi, eslab qolinadi); boshlang'ich qarz so'm va $; $ to'lovida kurs so'raladi — rasxodga so'mda, usd va kurs ham saqlanadi
- 1-bosqich (asosiy dastur) — kod tayyor, telefon o'lchamida sinab ko'rildi
- Baza: MILLIY-MOYKA bilan bitta Supabase loyihasi "sammoyka" (scozfycitumfftdpuphd) — rahbar qarori 13.11.2026
  - CRYSTAL WASH jadvallari faqat cw_ bilan boshlanadi; MILLIY-MOYKA jadvallariga (prefikssiz) tegilmaydi
  - Loginlar: @crystalwash.app (MILLIY-MOYKA: @sammoyka.app)
  - MILLIY trigger yangi_foydalanuvchiga_ruxsat faqat @sammoyka.app loginlariga ruxsat beradigan qilib cheklandi (aks holda CRYSTAL WASH loginlari MILLIY'ga ishchi bo'lib qo'shilardi)
- GitHub: compmiruz-web/MILLIY-MOYKA repo ichida alohida papka crystal-wash/ (rahbar qarori). MILLIY fayllariga tegilmaydi
- Link: https://compmiruz-web.github.io/MILLIY-MOYKA/crystal-wash/

## Fayllar
- index.html — butun dastur (HTML+CSS+JS). Tepada: APP_V, SB_URL, SB_KEY
- schema.sql — baza jadvallari
- manifest.json, icon-192.png, icon-512.png — telefon ekraniga ilova qilib qo'shish
- version.json — yangilanish xabari uchun

## Baza jadvallari (hammasi cw_ bilan: cw_tushum, cw_rasxod, ...)
- tushum (sana, summa, izoh)
- rasxod (sana, summa, turi, kimga, izoh) — turlari: OYLIK, XIMIYA, REMONT / EHTIYOT QISM, QARZ TOLOV, ARENDA, APARAT TOLOV, SVET, OBED, BOSHQA
- yetkazuvchilar (nomi, tel, izoh)
- qarz_olingan (yetkazuvchi_id, sana, nima, summa)
- xodimlar (ism, oylik, faol)
- exson_berildi (sana, summa, izoh)
- sozlamalar (kalit, qiymat) — exson_foiz = 5

## Qoidalar
- Summalar bazada to'liq so'mda; kiritish ming so'mda (212 → 212 000)
- Ekranda bo'shliq bilan: 2 328 950
- Qarz to'lovi = rasxod, turi "QARZ TOLOV", kimga = yetkazuvchi nomi → qarzdan ayiriladi
- Oylik "berildi" = shu oydagi OYLIK rasxodlari, kimga = ishchi ismi
- Exson = har oy max(0, tushum − rasxod) × 5%; 🤲 tugmada: jami exson − berilgan
- Real vaqt (Supabase realtime) + har 2 daqiqada yangilash; formaga yozilganlar o'chmaydi
- Yangilanish: APP_V va version.json dagi v bir xil oshiriladi → "🔔 Yangilanish keldi"

## Xavfsizlik
- RLS yoqilgan, lekin 1-bosqichda vaqtincha ochiq siyosat (cw_bosqich1, faqat cw_ jadvallarda). MILLIY-MOYKA jadvallari anon uchun yopiq — tekshirildi. 2-bosqichda (login + PIN) olib tashlanadi — link boshqalarga berilmasin.

## Keyingi bosqichlar
2. Login + PIN · 3. Eski Excel · 4. Qarzlar ($) · 5. Sheriklar · 6. Rollar · 7. Excel yuklab olish · 8. Telefon ko'rinishi

## Telegram bot — qarz eslatmasi va kunlik xisobot (13.11.2026)
- Bot: @crystal_washbot, guruh "Crystal Wash" (chat_id -5358505217)
- Edge funksiya: cw-qarz-bot (verify_jwt o'chiq, o'rniga x-cw-key sarlavhasi tekshiriladi)
  - ?amal=chats — bot turgan guruhlar ro'yxati; ?amal=test — sinov xabari; ?force=1 — tungi vaqtda ham yuborish
  - ?amal=kunlik — standart kechagi kun; &sana=YYYY-MM-DD istalgan kun; &bugun=1 bugungi kun. Tarkibi: kun tushumi, rasxodi (turlar bo'yicha), kun qoldig'i, oy boshidan tushum/rasxod/sof foyda/exson, berilishi kerak exson
- Jadval: pg_cron "cw-kunlik-xisobot" — har kuni 09:00 Toshkent (0 4 * * * UTC), KECHAGI kunning xisoboti (masalan 12.11 xisoboti 13.11 ertalab)
- Jadval: pg_cron "cw-qarz-eslatma" — kuniga 1 marta, 09:00 Toshkent (0 4 * * * UTC); qarz bo'lmasa jim
- Sozlamalar yopiq jadvalda: cw_bot (bot_token, chat_id, cron_key) — RLS yoqilgan, anon/authenticated uchun yopiq
- Xabar: har bir yetkazuvchining so'm va $ qoldig'i + jami
- Baza o'zi api.telegram.org ga chiqa olmaydi — Telegram'ga faqat edge funksiya orqali
