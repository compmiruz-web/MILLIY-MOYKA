// Ishchi profillarini boshqarish (faqat rahbar): yaratish, PIN almashtirish, o'chirish.
// Login "Ali" -> ali@sammoyka.app ; qisqa PIN -> PIN + "-moyka" (ilovadagi kirish bilan bir xil).
import { createClient } from 'npm:@supabase/supabase-js@2.45.4';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};
const json = (d: unknown, s = 200) => new Response(JSON.stringify(d), { status: s, headers: { ...cors, 'Content-Type': 'application/json' } });
const emailOf = (login: string) => login.includes('@') ? login.toLowerCase() : login.trim().toLowerCase().replace(/\s+/g, '') + '@sammoyka.app';
const passOf = (pin: string) => (pin.length < 6 ? pin + '-moyka' : pin);

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });
  try {
    const url = Deno.env.get('SUPABASE_URL')!;
    const jwt = (req.headers.get('Authorization') || '').replace(/^Bearer\s+/i, '');
    const user = createClient(url, Deno.env.get('SUPABASE_ANON_KEY')!, { global: { headers: { Authorization: `Bearer ${jwt}` } } });
    const { data: isBoss, error: e0 } = await user.rpc('rahbarmi');
    if (e0 || !isBoss) return json({ error: 'Faqat rahbar' }, 403);
    const admin = createClient(url, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
    const b = await req.json();

    if (b.action === 'create') {
      const login = String(b.login || '').trim(), pin = String(b.pin || '');
      if (!/^[A-Za-z0-9_.-]{2,30}$/.test(login)) return json({ error: "Login faqat lotin harflari va raqamlardan (2-30 belgi)" }, 400);
      if (pin.length < 4) return json({ error: 'PIN kamida 4 belgi' }, 400);
      const { data, error } = await admin.auth.admin.createUser({ email: emailOf(login), password: passOf(pin), email_confirm: true });
      if (error) return json({ error: /registered|exists/i.test(error.message) ? 'Bu login band' : error.message }, 400);
      const ruxsat = b.ruxsat && typeof b.ruxsat === 'object' ? b.ruxsat : { tushum: true, rasxod: true, qarz_ol: true, qarz_ber: true };
      const { error: e2 } = await admin.from('ruxsat_etilganlar').upsert({
        user_id: data.user!.id, izoh: emailOf(login), rol: b.rol === 'rahbar' ? 'rahbar' : 'ishchi', ism: String(b.ism || login).trim(), faol: true, ruxsat,
      });
      if (e2) return json({ error: e2.message }, 400);
      return json({ ok: true, id: data.user!.id });
    }
    if (b.action === 'pin') {
      const pin = String(b.pin || '');
      if (pin.length < 4) return json({ error: 'PIN kamida 4 belgi' }, 400);
      const { error } = await admin.auth.admin.updateUserById(String(b.id), { password: passOf(pin) });
      if (error) return json({ error: error.message }, 400);
      return json({ ok: true });
    }
    if (b.action === 'delete') {
      const { data: me } = await user.auth.getUser();
      if (me?.user?.id === b.id) return json({ error: "O'zingizni o'chira olmaysiz" }, 400);
      const { error } = await admin.auth.admin.deleteUser(String(b.id));
      if (error) return json({ error: error.message }, 400);
      return json({ ok: true });
    }
    return json({ error: "Noma'lum amal" }, 400);
  } catch (e) {
    return json({ error: String((e as Error)?.message || e) }, 500);
  }
});
