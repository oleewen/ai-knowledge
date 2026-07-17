# docs-indexing 常见陷阱

**错** vs **对**（参数收口、意图澄清与扫描）。

## 意图澄清

- **参数收口即写** → 还须完成六项清单 + 写前 `C`；须标「当前阶段：意图澄清」
- **路径/容器只写 INDEX** → 第 6 项须同时列出 `INDEX-GUIDE.md` 与 `changelogs/INDEXING-LOG.md` 的仓库根相对路径
- **把写前澄清当 grilling** → 写前用 intent-clarify；写后才烤干
- **无横幅发 C/M/G/S/F** → 须区分意图澄清 `C` 与烤干 `C`
- **用 G 做写前澄清** → `G` 仅写后深挖

## 参数

- **无日志就自动 full** → 说明增量不可用，请用户选 full **或中止**  
- **选预设≠已确认** → 仍复述 mode/depth/output/since，再 **C**  
- **擅自降 depth** → 可告知成本；深度由用户定  
- **默认 output/since 不展示** → 「默认」亦须确认或用户给字面量  
- **混淆基线** → 增量锚点首选 LOG **主表首行** `indexing_finished_ms`；`CHANGE-LOG` 文末 `docs-change:baseline_time_ms` 是 **docs-change** 用，≠ 索引锚点  

## 扫描

- **depth=3 抽样** → 排除集内系统遍历；未读写明 §八（[scan-spec.md](references/scan-spec.md)）  
- **未读当已索引** → 零幻觉；未读 `[未索引]`  
- **增量清空未成章** → 只并变更条目，勿整文件重写 INDEX  
- **索引 build/target/node_modules** → 须排除  
- **一文件多章重复写** → MECE；跨章用链接  

## 九章

- **空小节** → 无内容写 `[未索引]`+因，勿留白  
- **条目空话** → 目标 15–30 字可操作信息  
- **绝对路径** → 仅用根相对路径  
- **版本凭记忆** → 须来自已读 `pom.xml`/`application.yml` 等  

## 输出与日志

- **不写 LOG** → 每次成功 INDEX 后主表插一行（最新在上）；否则下轮增量无主表锚  
- **主表缺列** → `indexing_finished_ms`/`mode`/`depth`/`output_path` 等齐全（[indexing-log-spec.md](references/indexing-log-spec.md)）  
- **output 文件名漂移** → 输出文件名固定为 `INDEX-GUIDE.md`；`output` 只用于确认文档根，不得改成其他文件名；默认须确认  
- **改导航路径不烤干** → 导航/索引路径变更须强制烤干（默认本就必须）

## 上下游

- **增量跳过 docs-change** → 须 `CHANGE-LOG` 驱范围  
- **与 docs-agent §二矛盾** → 更 INDEX §二后 README 目录树应对齐  

## 速查

- [ ] mode/depth 用户确认  
- [ ] 写前意图澄清六项 + 双路径（INDEX-GUIDE + INDEXING-LOG）  
- [ ] since/output 已展示或有字面量  
- [ ] 九章无缺段（或 `[未索引]`）  
- [ ] 条目 15–30 字、根相对路径  
- [ ] 版本/配置有文件依据  
- [ ] MECE、已排除产物目录  
- [ ] LOG 主表已插行  
- [ ] 增量未误删未变章节  
- [ ] depth=3 无不合理抽样  
- [ ] 写后烤干收敛再 C/M/G/S/F  
