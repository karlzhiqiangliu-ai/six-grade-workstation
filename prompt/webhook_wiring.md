# web-家长注册接收 — WorkBuddy Webhook 接线说明

## 整体链路
```
家长 H5 页面(无 supabase 密钥) --POST {username,password}--> WorkBuddy 公开 Webhook
  --> 本处理器(bcrypt 哈希) --service_role--> Supabase parent_profile
  --> 返回 {ok,message} 给网页
```

## 一、WorkBuddy 侧（在 UI 里手动创建，本 agent 无直接建触发器的工具）
1. 新建工作流：`web-家长注册接收`
2. 触发器：**HTTP Webhook（公开可访问）**
   - 请求方式：`POST`
   - 允许跨域 CORS：开启
   - 请求体：`application/json`
   - 复制得到的 Webhook 地址即 H5 表单的提交目标。
3. 在工作流里加一个「运行代码 / Node 脚本」步骤，粘贴 `functions/web_parent_register.js` 的 handler。
4. 在工作流的「密钥 / 环境变量」里注入（**切勿硬编码进代码或前端**）：
   - `SUPABASE_URL` = `https://klopmmqxxzlzrsjvwtrc.supabase.co`
   - `SUPABASE_SERVICE_ROLE_KEY` = 你的 service_role key（Supabase 后台 Project Settings → API → service_role）
5. 部署 / 启用工作流。

## 二、前端 H5 表单（最小可用，仅凭证）
```html
<form id="f">
  <input name="username" placeholder="用户名" required>
  <input name="password" type="password" placeholder="密码(≥6位)" required>
  <button type="submit">注册</button>
</form>
<pre id="out"></pre>
<script>
document.getElementById('f').onsubmit = async (e)=>{
  e.preventDefault();
  const fd = new FormData(e.target);
  const res = await fetch('https://<你的webhook地址>', {
    method:'POST',
    headers:{'Content-Type':'application/json'},
    body: JSON.stringify({username:fd.get('username'), password:fd.get('password')})
  }).then(r=>r.json());
  document.getElementById('out').textContent = JSON.stringify(res,null,2);
};
</script>
```
> H5 页面**不得包含任何 Supabase 密钥**，密钥只在 WorkBuddy 工作流服务端。

## 三、请求/响应约定
请求体：
```json
{ "username":"karl", "password":"明文密码123456" }
```
成功：`{ "ok":true, "message":"注册成功", "id":"<uuid>" }`
失败：`{ "ok":false, "error":"用户名已存在" }` 等

## 四、安全注意（公开端点必做）
- service_role key 仅服务端；前端永远不要带 supabase key。
- 公开 POST 端点易被刷：上线前加**频率限制 / 验证码 /  honeypot**，并监控 parent_profile 增长。
- 当前表 `parent_profile` 对 anon/authenticated 已 REVOKE，仅 service_role 可写 —— 设计吻合。
- 若 H5 仅收集 username+password，则 `real_name/phone/child_name/child_grade/remark` 写入为 NULL（需确认这些列允许 NULL；否则请让表单补全或改表放行）。

## 五、待用户确认
- 提供 `SUPABASE_SERVICE_ROLE_KEY`（否则处理器无法写入）。
- 是否让 H5 收集完整家长资料(real_name/phone/child_name/child_grade/remark)，还是仅凭证、其余后补。
