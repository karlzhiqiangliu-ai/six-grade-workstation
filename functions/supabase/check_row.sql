// 可选资料校验（H5 收集时才生效）
if (profile.phone && !/^1[3-9]\d{9}$/.test(profile.phone))
  return res.status(400).json({ ok: false, error: '手机号格式不对' });
if (profile.child_grade !== null && (!Number.isInteger(profile.child_grade) || profile.child_grade < 0 || profile.child_grade > 18))
  return res.status(400).json({ ok: false, error: '年级填 0-18 的整数' });
