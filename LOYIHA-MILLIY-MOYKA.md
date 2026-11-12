Bu loyiha faqat MILLIY-MOYKA (sammoyka) xisob-kitob dasturi uchun. COMPMIR va COM-TECH bu yerga qo'shilmaydi, o'xshash bo'lsa ham aralashtirilmaydi. Javoblar o'zbek tilida.

# MILLIY-MOYKA — loyiha pasporti
- Dastur: https://compmiruz-web.github.io/MILLIY-MOYKA/ (bitta fayl: index.html; yangilanish: index.html dagi APP_V va version.json dagi v ni bir xil oshirish — ochiq dasturda "🔔 Yangilanish keldi" chiqadi)
- GitHub: compmiruz-web/MILLIY-MOYKA (supabase/schema.sql, supabase/rollar.sql, supabase/functions/ishchi)
- Baza: Supabase loyihasi "sammoyka" (scozfycitumfftdpuphd). Kirish: login + PIN (Umar -> umar@sammoyka.app, qisqa PIN + "-moyka")
- Summalar bazada to'liq so'mda, kiritish ming so'mda (212 -> 212 000)
- Bo'limlar: Xisobot, Tushum, Rasxod, Qarzlar, Oylik, Profillar; Exson 5% (sof foydadan)

## 2026-11-12 da qilinganlar
- iPhone'da sana maydoni boshqa maydon ustiga chiqmaydi, forma maydonlari bir xil balandlikda va tekis
- Telefonda Xisobotdagi 4 ta kartochka kichrayib ekranga sig'adi
- Qarzlar: "🕓 Tarix" — berilgan qarzlar (to'lovlar) ro'yxati; qarzi to'liq yopilgan yetkazuvchi tarixga ko'chadi; 🗑 bilan yetkazuvchini o'chirish (xohlasa to'lovlari bilan)
- Qarzlar so'mda va dollarda: qarzga mol olishda valyuta; dollar to'lovi kurs bilan (rasxodga so'mda tushadi, summa_usd va kurs saqlanadi); boshlang'ich qarz so'm va $
- Rasxod yozilayotganda qarzi bor inson ismi (Kimga yoki Izoh) tanilsa: "qarz to'lovimi?" — Ha/Yo'q; Ha bo'lsa QARZ TOLOV bo'lib qarzdan ayiriladi; Qarz bo'limida sanani belgilab to'langan qarz o'sha kunning rasxodiga qo'shiladi
- Sheriklar qarzi (ABDULMUHSIN, MUHAMMADUMAR): har biri ichida haqdorlar ro'yxati, Qarz olindi / Qarz berildi (xohlasa "Moyka kassasidan" — rasxodga yoziladi) / Shaxsiy pul, tarix; jadvallar: sheriklar, sherik_qarz
- Excel (Xisobot → ⬇ Excel): "SAMMOYKA KUNLIK XISOB KITOB dd.mm.yyyy.xlsx" — egasining Excel fayli ko'rinishida: har oy alohida varaq (SANA | DAROMAT | SANA | RASXOD | SABAB | OSTATKA | OYLIK DAROMAD JAMI | 0.05, ming so'mda, formulalar), QARZLAR varag'i (so'm va $ ustunlari), har sherik uchun alohida varaq
- Rollar: rahbar (hamma narsani ko'radi va har qanday yozuvni ✎ tahrirlaydi/🗑 o'chiradi) va ishchi; "👥 Profillar" bo'limi: ishchi rejimini yoqish/o'chirish, profil ochish (ism, login, PIN, rol), ishchi ruxsatlari: kunlik tushum, kunlik rasxod, qarzga olish, qarz berish; ishchi faqat qo'sha oladi, Xisobot/Oylik/Exson/Excel ko'rinmaydi. Umar va compmir.uz@gmail.com — rahbar. RLS: rahbarmi(), ishchi_ruxsat(), men(), profillar(), profil_saqla(); edge funksiya "ishchi" (profil yaratish, PIN, o'chirish)

## Kelishuvlar
- Egasining asl Excel fayllari: kompyuterda Downloads/Telegram Desktop: "SAMMOYKA KUNLIK XISOB KITOB …", "RASXOD …", "QARZLARIMIZ …"
- Parol/PIN'ni Claude o'zi o'ylab kiritmaydi — rahbar o'zi kiritadi
