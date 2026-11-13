// MILLIY MOYKA — Telegram'ga kunlik hisobot (pg_cron har kuni chaqiradi)
import { createClient } from 'npm:@supabase/supabase-js@2';

const db = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!, { auth: { persistSession: false } });
const fmt = (n: number) => Math.round(+n || 0).toLocaleString('ru-RU').replace(/ /g, ' ');
const fmtU = (n: number) => '$' + (Math.round((+n || 0) * 100) / 100).toLocaleString('ru-RU').replace(/ /g, ' ');
const dmy = (s: string) => { const [a, b, c] = s.split('-'); return `${c}.${b}.${a}`; };
const OY = ['Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun', 'Iyul', 'Avgust', 'Sentyabr', 'Oktyabr', 'Noyabr', 'Dekabr'];
const HAF = ['Yakshanba', 'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba'];
const esc = (s: string) => String(s ?? '').replace(/[&<>]/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;' }[c]!));

async function all(t: string) {
  const out: any[] = []; for (let f = 0; ; f += 1000) {
    const { data, error } = await db.from(t).select('*').range(f, f + 999); if (error) throw error;
    out.push(...(data || [])); if (!data || data.length < 1000) return out;
  }
}

Deno.serve(async (req) => {
  try {
    const { data: cfg } = await db.from('bot_sozlama').select('kalit,qiymat');
    const C = Object.fromEntries((cfg || []).map((r: any) => [r.kalit, r.qiymat]));
    if (!C.cron_key || req.headers.get('x-cron-key') !== C.cron_key) return new Response('ruxsat yo\'q', { status: 401 });
    const token = Deno.env.get('TG_TOKEN') || C.tg_token; if (!token) return new Response('TG_TOKEN yo\'q', { status: 500 });
    // /start bosganlarni avtomatik qo'shish (chat_id ro'yxati, vergul bilan)
    const ids = new Set(String(C.chat_id || '').split(',').map((x) => x.trim()).filter((x) => x && x !== token.split(':')[0]));
    const up = await (await fetch(`https://api.telegram.org/bot${token}/getUpdates`)).json().catch(() => ({}));
    for (const u of up.result || []) { const ch = (u.message || u.my_chat_member)?.chat; if (ch && ch.type === 'private' && /^\/start/.test(u.message?.text || '')) ids.add(String(ch.id)); }
    const idStr = [...ids].join(',');
    if (idStr !== (C.chat_id || '')) await db.from('bot_sozlama').upsert({ kalit: 'chat_id', qiymat: idStr });
    const body = await req.json().catch(() => ({}));
    const now = new Date(Date.now() + 5 * 3600e3), day: string = body.sana || now.toISOString().slice(0, 10), k = day.slice(0, 7);

    const [tu, ra, yet, qo, ex, soz] = await Promise.all([all('tushum'), all('rasxod'), all('yetkazuvchilar'), all('qarz_olingan'), all('exson_berildi'), all('sozlamalar')]);
    const foiz = +((soz.find((z: any) => z.kalit === 'exson_foiz') || {}).qiymat ?? 5) || 5;
    const sum = (a: any[]) => a.reduce((s, r) => s + +r.summa, 0);
    const tD = tu.filter((r) => r.sana === day), rD = ra.filter((r) => r.sana === day);
    const tDay = sum(tD), rDay = sum(rD);
    const tM = sum(tu.filter((r) => r.sana.slice(0, 7) === k && r.sana <= day)), rM = sum(ra.filter((r) => r.sana.slice(0, 7) === k && r.sana <= day));
    const months = [...new Set([...tu, ...ra].map((r) => r.sana.slice(0, 7)))];
    const E = months.reduce((s, m) => s + Math.max(0, sum(tu.filter((r) => r.sana.slice(0, 7) === m)) - sum(ra.filter((r) => r.sana.slice(0, 7) === m))) * foiz / 100, 0);
    const exQ = E - sum(ex);
    let qU = 0, qD = 0, qN = 0;
    for (const y of yet) {
      const S = { uzs: +y.boshlangich_qarz || 0, usd: +y.boshlangich_usd || 0 };
      qo.filter((q) => q.kim === y.kim).forEach((q) => { S[q.valyuta === 'usd' ? 'usd' : 'uzs'] += +q.summa; });
      ra.filter((r) => r.turi === 'QARZ TOLOV' && r.kimga === y.kim).forEach((r) => { if (r.summa_usd != null && r.summa_usd !== '') S.usd -= +r.summa_usd; else S.uzs -= +r.summa; });
      if (S.uzs > 0 || S.usd > 0) qN++; qU += Math.max(0, S.uzs); qD += Math.max(0, S.usd);
    }
    const wd = HAF[new Date(day + 'T00:00:00Z').getUTCDay()], m = +k.slice(5) - 1;
    const L: string[] = [`📊 <b>MILLIY MOYKA — kunlik hisobot</b>`, `📅 ${dmy(day)}, ${wd}`, ''];
    L.push(tD.length ? `💵 Tushum: <b>${fmt(tDay)}</b> so'm` : `💵 Tushum: <b>yozilmagan</b> ⚠️`);
    L.push(`🧾 Rasxod: <b>${fmt(rDay)}</b> so'm`);
    rD.forEach((r) => { const kg = (r.kimga || '').trim(), iz = (r.izoh || '').trim();
      const nm = (iz && kg && iz.toUpperCase().includes(kg.toUpperCase()) ? iz : [kg, iz].filter(Boolean).join(' ')) || r.turi || '';
      L.push(`   • ${esc(nm.toUpperCase())} — ${fmt(r.summa)}${r.summa_usd ? ` (${fmtU(r.summa_usd)})` : ''}`); });
    L.push(`${tDay - rDay < 0 ? '🔻' : '💰'} Kunlik qoldiq: <b>${fmt(tDay - rDay)}</b> so'm`, '');
    L.push(`🗓 <b>${OY[m]} (1–${+day.slice(8)})</b>`, `   Tushum: ${fmt(tM)}`, `   Rasxod: ${fmt(rM)}`, `   Ostatka: <b>${fmt(tM - rM)}</b>`, `   Exson ${foiz}%: ${fmt(Math.max(0, tM - rM) * foiz / 100)}`, '');
    L.push(`🤲 Exson qoldig'i (jami): <b>${fmt(exQ)}</b> so'm`);
    if (qN) L.push(`📦 Qarzlarimiz: ${[qU ? fmt(qU) + " so'm" : '', qD ? fmtU(qD) : ''].filter(Boolean).join(' + ')} (${qN} ta sotuvchi)`);
    L.push('', `🔗 https://compmiruz-web.github.io/MILLIY-MOYKA/`);

    const chats = body.chat_id ? [String(body.chat_id)] : [...ids];
    if (!chats.length) return new Response(JSON.stringify({ ok: false, sabab: "Hech kim botga /start bosmagan" }), { status: 409, headers: { 'content-type': 'application/json' } });
    const res: any[] = [];
    for (const chat of chats) {
      const r = await fetch(`https://api.telegram.org/bot${token}/sendMessage`, { method: 'POST', headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ chat_id: chat, text: L.join('\n'), parse_mode: 'HTML', disable_web_page_preview: true }) });
      const j = await r.json(); res.push({ chat, ok: j.ok, err: j.ok ? undefined : j.description });
    }
    const ok = res.some((x) => x.ok);
    return new Response(JSON.stringify({ ok, res }), { status: ok ? 200 : 502, headers: { 'content-type': 'application/json' } });
  } catch (e) { return new Response(String((e as Error).message || e), { status: 500 }); }
});
