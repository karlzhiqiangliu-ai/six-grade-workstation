// 调试：打印环境变量（上线务必删掉，不要打日志泄露密钥！）
console.log("SUPABASE_URL=", process.env.SUPABASE_URL);
console.log("SERVICE_ROLE exist?", !!process.env.SUPABASE_SERVICE_ROLE_KEY);
