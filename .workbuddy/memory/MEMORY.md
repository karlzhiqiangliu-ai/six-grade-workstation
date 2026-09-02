# 六年级学习工作台 — 项目长期记忆

## 项目概述
单文件离线 HTML「六年级学习工作台」（`六年级学习工作台.html`），为六年级孩子打造的期末复习学习工作台。
蓝本为「少年学习空间站.html」（三升四版本），内容已全部替换为六年级（部编版六上/六下）知识。

## 关键约定
- 单文件 + localStorage（`STORAGE_KEY = 'wb_xuexi_station_v1'`），双击离线打开，电脑手机自适应
- 五大模块：英语星球、诗文花园、数学王国、思维训练场、闯关冒险乐园 + 宠物小屋、趣味小游戏、错题本
- 数学 11 题型：fracmul/fracdiv/fracmixed/ratio/ratiodiv/circle/ring/percent/discount/pie/direction
- 语文：15 首必背古诗文（含《学弈》《两小儿辩日》文言文 isProse:true）、22 条背诵素材、6 篇阅读
- 成语 `idiomsData` 59 条，分三组：`g:'new'` 43（六上23+六下20）｜`g:'classic'` 11 拓展典故｜`g:'review'` 5 三下寓言；字段含 `bk`（册次）、`note`（用法提示）、`st:1`（有典故故事）
- 成语图鉴三板块由 `IDIOM_GROUPS` 驱动；`idiomStoryPool()` 只取 `st` 的 26 条供「故事猜成语」出题
- 硬规则：拔苗助长 = 揠苗助长，只保留「拔苗助长」，禁止重复出现
- 文件为纯 CRLF 换行，Python 读写需 `encoding='utf-8'`（历史 _build_grade6.py 曾导致 CRLF 丢失，现已统一）

## 背诵录音打分（2026-09-02 改造）
- 旧 `analyzeRecite()` 只读音频能量包络，**不看内容**，乱背也 70~85 分 —— 已删除
- 现方案：Web Speech API（`window.SpeechRecognition || webkitSpeechRecognition`）转文字 →
  `reciteDiff()` LCS 逐字比对 → `score = 100 * pow(accuracy, 0.9) - min(8, pauses*2)`
- 浏览器无通道直连操作系统语音引擎，Web Speech API 是唯一入口，**必须联网 + Chrome/Edge**
- 识别为空 / 引擎不支持 → 不编造分数，走 `renderReciteNoAsr()` + 家长评分（90/75/60），不计入成绩
- 家长评分模式 `startRecite(i,1)` 必须有 MediaRecorder（要回放），否则拦截
- 关键函数：`asrStart/asrStop/asrNorm/scoreReciteByText/renderReciteDiff/commitReciteScore/
  recitePreflight/showAsrUnsupported/beginReciteSession/finishReciteCommon/recitePauseCount/asrEngineTip`
- `recitePauseCount` 只统计停顿次数用于小幅扣分；`analyzeRecite` 已成历史，勿再引用

## 线上发布
- 发布目录统一为 `Artifacts/app/`（只含 `index.html`，从 `六年级学习工作台.html` 复制），不再用旧 `site/`
- 工具 `workbuddy_sites_deploy`，`language:"static"`，`appName:"六年级学习工作台"`
- 当前分享链接：https://512acd6d39e243659b07c21a0634a731.app.workbuddy.link （2026-09-02 从 Artifacts/app 部署）
- 旧链接（site/ 目录，可能仍在线，建议下线）：https://bcb72e70873f4267a42528e2b2577610.app.workbuddy.link
- 管理入口：设置—数据管理—我发布的应用
- **发布后语音识别才真正可用**：线上 https 满足 Web Speech API / getUserMedia 的安全上下文，
  本地 file:// 双击会被浏览器拒绝
- localStorage 按域名隔离：线上与本地进度不互通；不同访客各自独立
- 更新流程：改本地 → `cp 六年级学习工作台.html Artifacts/app/index.html` → 重新发布

## 校验方式（重要，改代码后必跑）
1. 语法：`node -e "new Function(script)"` 检查 <script> 块
2. 数据冒烟：`node _check_grade6.js`（poemsData/reciteData/readingPassages 一致性 + 11 题型各 200 题）
3. 运行时冒烟：`node _check_grade6_runtime.js`（vm + 最小 DOM 桩，全模块渲染/判分/存储）
4. 成语专项：`node _check_idioms.js`（分组/册次/去重/字段/故事题库/清单核对，165 项）
5. 背诵打分专项：`node _check_recite_asr.js`（评分曲线各档位、真实篇目端到端、全链路入账、
   录音会话渲染 + 实时反馈、逐字对比渲染、无引擎降级，49 项）

## 批量改 HTML 的硬性安全规则（血泪教训）
- 用 Node 脚本定位数组起点时，若 KEY 形如 `'const X = ['`，`[` 的位置是 `i + KEY.length - 1`，**不是** `i + KEY.length`（曾因此把数据插进 `defaultState()` 并误删 6512 字符）
- 替换前必须校验被替换区间：含预期旧数据标记、且**不含** `function ` / `const ` 定义，否则中止
- 本仓库无 git。误删时可从蓝本 `少年学习空间站.html` 精确回填：先比对待恢复区块前后各 3000 字符是否完全一致，并确认区块内无年级专属词，再截取同名区块回填
- **Python 脚本文本替换**：文件是纯 CRLF，脚本里多行 `old_string` 用 `\n` 书写会匹配失败。
  读入后先 `s.replace('\r\n','\n')`，写回前再 `s.replace('\n','\r\n')`
- **多步 cut() 会互相吃掉区间**：按 A→C 整段替换时，中间的 B 也一并被替换，后续再按 B 定位必然失败，
  应合并为一次替换；模板字符串里两次替换可能重复插入同一内容，换完必须回读确认

## 已清理的孤儿代码
- 除法专项「三位数÷一位数」填空矩阵（genDivDrillProblem 等）
- 计算练习卷（genWorksheet/startWorksheet 等，旧 div/mul/rem 题型）
- 均已在 2026-09-01 删除，勿再引用

## 课标约束（AGENTS.md）
- 严格贴人教版六年级课标，禁止超纲
- 知识点三层：了解｜理解｜掌握；出题难度：基础｜巩固｜拓展（主要作用于 .md 原子笔记/讲义输出）
- 原子笔记路径 `knowledge/grade6/`，讲义 `lecture/grade6/`，错题本 `errorbook/grade6.md`（待生成）

## 产物输出规则（2026-09-02 起，重要）
- 用户要求：**所有 html / app 产物统一输出到 `Artifacts/` 目录**，后续每次生成都按此操作
- 源文件 `六年级学习工作台.html` 改完即 `cp` 到 `Artifacts/六年级学习工作台.html` 与 `Artifacts/app/index.html`
- `app/` 为发布导出产物目录，不要直接改其内部源码；`site/` 为线上发布目录
- 临时脚手架（`_regen_*.py`/`_verify_new.js`/`_audit_data.js`/`_syn_0.js`）用毕即删，不留垃圾；`_check*.js` 校验套件与 `.bak_*.html` 备份按 gitignore 保留

## 构建脚本 _build_grade6.py（2026-09-02 改造为幂等生成器）
- 作用：读取 `六年级学习工作台.html`，按 9 个内容块标记替换诗词/背诵/阅读/目标/数学提示/数学出题/渲染分支/复习清单/题型映射，重生成产物
- 改造前：陈旧——内嵌只有 11 题型（缺六下 8 新题型）、`reciteData` 缺《花之歌》《有的人》、mathTips 结束注释漂移导致 `s.index()` 抛 ValueError，且用文本模式读写把 CRLF 变成 LF
- 改造后：内嵌定义全部抽取自当前成品（19 题型含 negaxis/proportion/scale/cyls/cylv/conev/pigeon/numshape；reciteData 24 条含花之歌/有的人），读入 `newline=''` 保留 `\r\n`、写回前 `\n`→`\r\n`，token 结束标记去掉前导 `\n\n` 防止换行翻倍
- 验证：对真文件实跑 md5 前后一致（逐字节幂等），`new Function` SYNTAX OK，`_check_grade6.js` 150 PASS，`_check_grade6_runtime.js` 73 PASS
- 用法：改下方 `NEW_*` 数据后重跑 `python _build_grade6.py` 即可刷新；释放数据改动入口，避免手改 HTML 易错

## 侧边栏折叠架构（2026-09-02）
- 4 个可折叠分组 + 底部固定系统项：`toggleNavGroup(g)` 切换；跳转时自动展开所在分组
- 📚学科学习【展开】今日任务/英语星球/语文天地/数学王国 ｜ 🧩练习训练【收起】思维训练场/闯关冒险
- 🛠️学习工具【收起】错题记录本/学习收藏夹 ｜ 🎮趣味乐园【收起】趣味小游戏/宠物小屋 ｜ ⚙️系统 数据管理
- 移动端 `.sidebar{display:flex;transform:translateX(-100%)}`

## 学习数据记录 + 图表（2026-09-02，对应需求更新 2026-9-2）
- `studyLog` 按 `YYYY-MM-DD` 聚合 `{sec, correct, wrong, subjects}`；`logStudy(subject,correct,wrong)` 各判分入口调用
- `flushStudySession()` 切模块/visibilitychange隐藏/beforeunload 落盘；`subjectOfSection(name)` 映射模块→学科
- 数据管理页 `renderStudyStats()` 纯 SVG：近7天时长**柱状图** + **当天(今天)答对/答错柱状图** + **近7天正确率折线图**(`renderLine` 画 polyline) + `renderPie` 两个饼图（学科时长占比 / 正确错误占比）；`todayKey()`(=`logStudy` 的 `todayStr()` 格式) 取当天

## 数学题型（MATH_GEN_TYPES = 19）
- 原 11：fracmul/fracdiv/fracmixed/ratio/ratiodiv/circle/ring/percent/discount/pie/direction
- 六下 8 新：negaxis/proportion/scale/cyls/cylv/conev/pigeon/numshape
- `genMathProblem(type)` 返回 `{q, ans, options}`（字段是 `ans` 不是 `answer`）；`mathTips[type]={tip, pit}`
- 语文：poemsData 15 首必背 + reciteData 24 条（含《花之歌（选段）》《有的人——纪念鲁迅有感》）；vocabData 六上41/六下46
