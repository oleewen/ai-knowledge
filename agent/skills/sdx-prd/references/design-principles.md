# 设计原则（sdx-prd）

路由与阶段 [SKILL.md](../SKILL.md)、[workflow.md](workflow.md)。叙事反模式 [anti-patterns.md](anti-patterns.md)。终检 [quality-checklist.md](quality-checklist.md)。

## 原则

### 1. 模板驱动

跟 [prd-template.md](../assets/prd-template.md) §1–§11；不重排顶层；空节标「不适用/待补充」。

### 2. 证据优先

US/流程/BR 须锚定 ANALYSIS 的 FR-n、BR-n 与 `knowledge/` 事实。

| 类型 | 格式 | 例 |
|------|------|-----|
| FR / BR / US / UC / EX / AC / NAC | `FR-{NNN}` 等 | `FR-001 …` |

### 3. 按需加载

勿为「完整」通读 `knowledge/**` 或全仓。

### 4. 歧义标注

歧义、矛盾、缺失 → 待澄清后暂停；勿自补。

### 5. MVP 聚焦

仅目标 MVP（`--mvp`）；勿混入后续阶段。

### 6. 可追溯链

`SOLUTION → ANALYSIS → PRD`：US→FR；UC↔US；BR 继承 ANALYSIS；AC/NAC→US 或 §9；EX→流程步骤。

### 7. FR 句式

能力陈述、实现无关：「角色可以…使得可观察…」；正文避免堆技术栈、表字段、中间件名当需求。

### 8. NFR 与验收

§9 陈述 + 指标/度量；§10.2 NAC 与 §9 互链或「不适用」。

## 表格级禁止

| 反模式 | 说明 |
|--------|------|
| 臆测需求 | 无 FR 锚点编故事/流程 |
| 吞没歧义 | 不标待澄清自补 |
| 实现泄漏 | 接口路径、DDL、选型写进正文 |
| 模板跳章 | 改十一章顺序 |
| 通读全库 | 无的放矢扫 knowledge |
| 无编号 | 故事/用例/规则/验收无主键 |
| MVP 越界 | 塞进非当前 MVP |
| 故事堆砌 | 复述 FR 无场景与验收 |
| 空章 | 无内容且未标不适用 |
| 规则散落 | BR 不归 §7 |

## 常见错误处置

| 场景 | 处理 |
|------|------|
| 无 ANALYSIS | 停；先 `sdx-analysis` |
| 无 MVP 节 | 停；对齐 `--mvp` |
| ANALYSIS 结构缺 | 警告；继续则标风险 |
| 无 knowledge | 警告；标缺基线 |
| 无模板文件 | 停；核对 `assets/prd-template.md` |
| FR 覆盖不全 US | 停；列出未覆盖 FR |
| 输出目录无 | 创建 `requirements/.../MVP-Phase-{N}/` |
