// functions/web_parent_register.js
// WorkBuddy 工作流「web-家长注册接收」的处理器（运行在 HTTP Webhook 触发器内）
//
// 链路: H5(POST {username,password[,可选资料]}) -> 本处理器 -> bcrypt哈希 -> service_role 写 parent_profile -> 返回 JSON
//
// 安全约定:
//  - service_role 密钥仅服务端(本函数/env), 绝不出现在前端 H5 页面, 也绝不写进仓库。
//  - 明文密码只在函数内存中参与哈希, 不落库、不打日志。
//  - service_role 绕过 RLS, 不受此前 `REVOKE ... FROM anon/authenticated` 影响, 可写 parent_profile。
//
// 部署前: npm i bcryptjs   (纯 JS, 免原生编译; 与 Python bcrypt 生成的 $2b$04$ 哈希互验)

const bcrypt = require('bcryptjs');

const SUPABASE_URL = process.env.SUPABASE_URL;               // 例: https://xxxx.supabase.co
const SERVICE_ROLE = process.env.SUPABASE_SERVICE_ROLE_KEY;  // 服务端机密, 从工作流「密钥/环境变量」注入
const COST = 4; // 与既有 parent_profile 中哈希一致 ($2b$04$)

module.exports = async function handler(req, res) {
  // ---- CORS（Webhook 触发器需开启跨域，否则 H5 fetch 报错）----
  res.setHeader('Access-Control-Allow-Origin', '*'); // 生产可收紧为具体域名
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(204).end();           // 预检
  if (req.method !== 'POST') return res.status(405).json({ ok: false, error: 'method not allowed' });

  if (!SUPABASE_URL || !SERVICE_ROLE) {
    return res.status(500).json({ ok: false, error: '服务端未配置 SUPABASE_URL / SERVICE_ROLE' });
  }

  // ---- 解析请求体 ----
  let body;
  try { body = typeof req.body === 'string' ? JSON.parse(req.body) : req.body; }
  catch { return res.status(400).json({ ok: false, error: 'invalid json' }); }
  if (!body || typeof body !== 'object') return res.status(400).json({ ok: false, error: 'invalid body' });

  const username = (body.username || '').toString().trim();
  const password = (body.password || '').toString();
  if (!username || !password) return res.status(400).json({ ok: false, error: 'username 和 password 必填' });
  if (password.length < 6) return res.status(400).json({ ok: false, error: '密码至少 6 位' });
  if (!/^[A-Za-z0-9_]{3,32}$/.test(username)) return res.status(400).json({ ok: false, error: '用户名限 3-32 位字母/数字/下划线' });

  // 可选资料字段（若 H5 表单额外收集；不传则为 null）
  const profile = {
    real_name: body.real_name || null,
    phone: body.phone || null,
    child_name: body.child_name || null,
    child_grade: (body.child_grade === undefined || body.child_grade === null || body.child_grade === '') ? null : Number(body.child_grade),
    remark: body.remark || null,
  };

  // ---- bcrypt 哈希（明文仅在内存）----
  const pwd_hash = bcrypt.hashSync(password, bcrypt.genSaltSync(COST));

  // ---- service_role 写入 parent_profile ----
  const payload = { username, pwd_hash, ...profile };
  let r;
  try {
    r = await fetch(`${SUPABASE_URL}/rest/v1/parent_profile`, {
      method: 'POST',
      headers: {
        'apikey': SERVICE_ROLE,
        'Authorization': `Bearer ${SERVICE_ROLE}`,
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      },
      body: JSON.stringify(payload),
    });
  } catch (e) {
    return res.status(502).json({ ok: false, error: '上游 Supabase 连接失败', detail: String(e).slice(0, 200) });
  }

  const text = await r.text();
  if (r.ok) {
    let row; try { row = JSON.parse(text)[0]; } catch {}
    return res.status(200).json({ ok: true, message: '注册成功', id: row && row.id });
  }

  // 错误归类
  let msg = '注册失败';
  if (text.includes('parent_profile_username_key') || text.includes('23505')) msg = '用户名已存在';
  else if (text.includes('42501')) msg = '服务端权限不足（请检查 service_role 密钥）';
  else if (text.includes('23502') || text.includes('23503')) msg = '资料字段不完整（表约束）';
  return res.status(r.status === 409 ? 409 : 400).json({ ok: false, error: msg, detail: text.slice(0, 200) });
};
