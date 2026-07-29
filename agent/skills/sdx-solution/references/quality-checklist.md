# sdx-solution 质量验收清单

阶段三终检：对齐模板 **§7.4**。达标项 `- [ ]`→`- [x]`；不达标保持 `- [ ]`，禁止假勾。

原则与反模式：[design-principles.md](design-principles.md)。

## 完整性

- [ ] **§1**：§1.1–§1.4 有实质叙述或「不适用」；G-n 可指回来源
- [ ] **§2**：场景与角色覆盖主路径；§2.3 In/Out + 成功标准；§2.4 含交付节点或「无外部截止」
- [ ] **§3**：§3.1–§3.3 与 §3.2 一致；影响含功能、数据、对外承诺、下游等**相关**维度；§3.4 每 C-n 有化解与成本
- [ ] **§4**：§4.1 可读；多方案 §4.2 已填，否则标「不适用」；§4.3 决策有推荐、备选与理由
- [ ] **§5**：§5.1 R-n 有可能性、影响与应对；§5.2 Q-n 已更新（无则写「无」）
- [ ] **§6**：MVP 能说清业务价值与依赖；里程碑含阶段/日期、交付物、验收；依赖无环

## 受众与语言

- [ ] 已按 [audience-and-language.md](../../../references/audience-and-language.md) + 本地 [audience-and-language.md](audience-and-language.md) 通过烤干受众维 A/B/C/E
- [ ] 正文（§1–§6、§7.1–§7.2）无接口/表字段/中间件/模块/协议栈等
- [ ] 技术线索仅在 §7.3 且含「待研发确认」

## 一致性

- [ ] 与原始需求及已引 `knowledge/` 无未解释冲突
- [ ] G-n、C-n、R-n、Q-n 连续（跳号须说明）
- [ ] 章间引用自洽

## 可追溯性

- [ ] 每 G-n 可指回需求来源
- [ ] 每 C-n 可指业务能力/协作环节
- [ ] 每 R-n 可指影响面或约束
- [ ] 每 MVP 可指业务问题

## 格式

- [ ] 文首 frontmatter 完整（id、title、version、status、created、updated、author、parent、dependencies、tags）
- [ ] 七章结构与 [solution-template.md](../assets/solution-template.md) 一致
- [ ] §7.1 覆盖文内专用术语；§7.2 列已引需求/知识库路径
