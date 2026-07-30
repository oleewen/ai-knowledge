# sdx-analysis 质量验收

阶段三：对齐模板 **§6.4**。达标 `- [ ]`→`- [x]`；禁假勾。

原则：[design-principles.md](design-principles.md)。

## 完整性

- [ ] **§1**：引用 SOLUTION；§1.2 **G-n** 对齐；§1.3 范围、假设、研究齐备
- [ ] **§2**：概览含「需求概要」与「所属里程碑」（`M{n}（短名）`、非空、禁 `MVP{n}`、一 FR 一里程碑）；需求名称 ≤30、需求概要 ≤60（Unicode 码点）；`### FR-n:` 标题 = 概览名称且 ≤30；每 **FR-n** 含描述、输入、处理（**BR**）、业务对象、输出、异常与边界、验收；概览与 FR 对齐
- [ ] **§3**：§3.1–§3.5 落位或「不适用」
- [ ] **§4**：§4.1–§4.3；`MVP{n}（{短名}）`；每 FR 恰好一 MVP；个数建议 ≈ 里程碑数（偏离有说明）；依赖无环
- [ ] **§5**：§5.1、§5.2 **R-n**
- [ ] **§6**：§6.1–§6.4；§6.2 含 CONTEXT/ADR（若有技术决策）；§6.4 已逐项判定

## 受众与语言

- [ ] 已按 [audience-and-language.md](../../../references/audience-and-language.md) + 本地 [audience-and-language.md](audience-and-language.md) 通过烤干受众维 A/B/C/E
- [ ] 正文（§1–§5、§6.1–§6.2）无接口/表字段/中间件/模块/协议栈
- [ ] 技术线索仅 §6.3 且「待研发确认」

## 一致性

- [ ] 与 SOLUTION、`knowledge/` 无未解释冲突
- [ ] FR/BR/R/MVP 编号连贯（跳号注明）
- [ ] 需求→规则→MVP→风险自洽

## 可追溯性

- [ ] FR-n → G-n
- [ ] BR-n → FR-n
- [ ] MVP → FR 列表；每 FR 恰好一 MVP；与里程碑不硬对齐（个数建议 ≈，偏离有说明）；概览「所属里程碑」可反查
- [ ] R-n → 依赖或影响分析
- [ ] 本轮技术决策：CONTEXT 已登记且 §6.2 可链到 ADR（见 [sdx-adr-protocol.md](../../../references/sdx-adr-protocol.md)）

## 格式

- [ ] 文首 frontmatter 完整（id、title、version、status、created、updated、author、reviewers、parent、tags）
- [ ] 六章与 [analysis-template.md](../assets/analysis-template.md) 一致
- [ ] §6.1 术语；§6.2 SOLUTION / 知识库路径 / 技术决策索引
