# sdx-architect 质量检查

按已授权范围验收：单段检查当前段；整篇收口检查全部章节。结构脚本不能替代以下语义与授权检查。

## 内容与追溯

- [ ] 三章骨架完整；§1 有目标、约束、决策，§2 有边界及变更/交互，§3.1 有摘要表和下游承接。
- [ ] PRD 同链；ANALYSIS/overview 仅引用已核实材料，术语、范围、能力归属无跨段矛盾。
- [ ] DD 编号可追溯、无重复；真实备选方案已有取舍依据。
- [ ] 符合 [类型模式](knowledge-type-modes.md)；不把实现级 API/DDL 或 PRD 全文放进 ASD。

## 文件与链接

- [ ] frontmatter 为合法 YAML；`id`、文件名、`parent`、`mvp_phase` 同链。
- [ ] 路径符合 [工作流](workflow.md#产物路径)；规约链接按所在文件位置解析，已存在目标可达，未来承接明确标待建。
- [ ] 本轮完成部分已替换模板占位；未完成部分未冒充已确认事实。

## 收口证据

- [ ] 写前授权、语义决策及前文回改遵守 [gates.md](gates.md)。
- [ ] 已按 [共享受众契约](../../../references/audience-and-language.md) 与 [本地差额](audience-and-language.md) 通过 A/B/C/E，烤干收敛后等待用户动作。
- [ ] 整篇收口已运行 `validate-asd.sh --strict`，检查了实际文件数、诊断和退出码；未把零文件或草稿警告当通过。
