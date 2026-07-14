# sdx-analysis 质量验收

阶段三：对齐模板 **§6.4**。达标 `- [ ]`→`- [x]`；禁假勾。

原则：[design-principles.md](design-principles.md)。

## 完整性

- [ ] **§1**：引用 SOLUTION；§1.2 **G-n** 对齐；§1.3 范围、假设、研究齐备
- [ ] **§2**：概览表齐；每 **FR-n** 含描述、输入、处理（**BR**）、业务对象、输出、异常与边界、验收
- [ ] **§3**：§3.1–§3.5 落位或「不适用」
- [ ] **§4**：§4.1–§4.3；依赖无环
- [ ] **§5**：§5.1、§5.2 **R-n**
- [ ] **§6**：§6.1–§6.4；§6.4 已逐项判定

## 受众与语言

- [ ] 正文（§1–§5、§6.1–§6.2）无接口/表字段/中间件/模块/协议栈
- [ ] 技术线索仅 §6.3 且「待研发确认」

## 一致性

- [ ] 与 SOLUTION、`knowledge/` 无未解释冲突
- [ ] FR/BR/R/MVP 编号连贯（跳号注明）
- [ ] 需求→规则→MVP→风险自洽

## 可追溯性

- [ ] FR-n → G-n
- [ ] BR-n → FR-n
- [ ] MVP → FR 列表
- [ ] R-n → 依赖或影响分析

## 格式

- [ ] 文首 frontmatter 完整（id、title、version、status、created、updated、author、reviewers、parent、tags）
- [ ] 六章与 [analysis-template.md](../assets/analysis-template.md) 一致
- [ ] §6.1 术语；§6.2 SOLUTION / 知识库路径
