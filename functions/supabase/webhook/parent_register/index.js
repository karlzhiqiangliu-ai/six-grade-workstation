import bcrypt from "npm:bcryptjs@2.4.3";

const COST = 4;
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Access-Control-Allow-Headers": "authorization, apikey, content-type",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response(null, { status: 204, headers: corsHeaders });
  if (req.method !== "POST")
    return Response.json({ ok: false, error: "method not allowed" }, { status: 405, headers: corsHeaders });

  const url = Deno.env.get("SUPABASE_URL")!;          // 平台自动注入，无需手配
  const key = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  if (!url || !key)
    return Response.json({ ok: false, error: "服务端未配置 service_role" }, { status: 500, headers: corsHeaders });

  let body: Record<string, unknown>;
  try { body = await req.json(); }
  catch { return Response.json({ ok: false, error: "invalid json" }, { status: 400, headers: corsHeaders }); }

  const username = String(body.username ?? "").trim();
  const password = String(body.password ?? "");
  if (!username || !password)
    return Response.json({ ok: false, error: "username 和 password 必填" }, { status: 400, headers: corsHeaders });
  if (password.length < 6)
    return Response.json({ ok: false, error: "密码至少 6 位" }, { status: 400, headers: corsHeaders });
  if (!/^[A-Za-z0-9_]{3,32}$/.test(username))
    return Response.json({ ok: false, error: "用户名限 3-32 位字母/数字/下划线" }, { status: 400, headers: corsHeaders });

  const profile = {
    real_name: (body.real_name as string) || null,
    phone: (body.phone as string) || null,
    child_name: (body.child_name as string) || null,
    child_grade: body.child_grade == null || body.child_grade === "" ? null : Number(body.child_grade),
    remark: (body.remark as string) || null,
  };

  const pwd_hash = bcrypt.hashSync(password, bcrypt.genSaltSync(COST)); // 明文仅在内存

  const r = await fetch(`${url}/rest/v1/parent_profile`, {
    method: "POST",
    headers: {
      apikey: key,
      Authorization: `Bearer ${key}`,
      "Content-Type": "application/json",
      Prefer: "return=representation",
    },
    body: JSON.stringify({ username, pwd_hash, ...profile }),
  });

  const text = await r.text();
  if (r.ok) {
    let id; try { id = JSON.parse(text)[0]?.id; } catch { /* 忽略 */ }
    return Response.json({ ok: true, message: "注册成功", id }, { headers: corsHeaders });
  }

  let msg = "注册失败";
  if (text.includes("23505") || text.includes("parent_profile_username_key")) msg = "用户名已存在";
  else if (text.includes("42501")) msg = "服务端权限不足（检查 service_role 密钥）";
  else if (text.includes("23502") || text.includes("23503")) msg = "资料字段不完整（表约束）";
  return Response.json({ ok: false, error: msg, detail: text.slice(0, 200) },
    { status: r.status === 409 ? 409 : 400, headers: corsHeaders });
});
