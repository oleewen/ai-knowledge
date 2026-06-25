# docs-indexing 常见陷阱

**错** vs **对**（门禁与扫描）。

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
- **output 优先级记不清** → 用户指定 > `{DOC_DIR}/` > `doc/` > 根 `index.md`（仓库根索引为 `index.md`）；默认须确认  

## 上下游

- **增量跳过 docs-change** → 须 `CHANGE-LOG` 驱范围  
- **与 docs-agent §二矛盾** → 更 INDEX §二后 README 目录树应对齐  

## 速查

- [ ] mode/depth 用户确认  
- [ ] since/output 已展示或有字面量  
- [ ] 九章无缺段（或 `[未索引]`）  
- [ ] 条目 15–30 字、根相对路径  
- [ ] 版本/配置有文件依据  
- [ ] MECE、已排除产物目录  
- [ ] LOG 主表已插行  
- [ ] 增量未误删未变章节  
- [ ] depth=3 无不合理抽样  
