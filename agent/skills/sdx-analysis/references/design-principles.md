# sdx-analysis 设计原则

终检：[quality-checklist.md](quality-checklist.md)。语言：[audience-and-language.md](audience-and-language.md)。

## 原则

| 原则 | 要求 |
| ---- | ---- |
| 模板驱动 | 六章与 [analysis-template.md](../assets/analysis-template.md) 一致；无内容标「不适用/待补充」 |
| 证据优先 | FR/BR/风险须有 SOLUTION 与 `knowledge/` 依据 |
| 业务可读 | §1–§5、§6.1–§6.2 无工程标识；§6.3 可收线索并标「待研发确认」 |
| 歧义标注 | Q-n 单题澄清 |
| 按需加载 | 禁通扫 `knowledge/**` |
| 可追溯 | FR→G-n；BR→FR；MVP→FR；MVP↔SOLUTION 里程碑 1:1；R-n→依赖/影响 |
| 概览先确认 | `### 概览` 独立成段；主料上游 §6.1；未确认不写 FR 正文 |
| 范围清晰 | 仅 ANALYSIS；不写 PRD/ASD/DSD/代码 |

### 证据引用

| 类型 | 格式 | 例 |
| ---- | ---- | --- |
| 目标 | `G-{N}` | `G-1 …` |
| 实体 | `{视角}-{ID}` | `BC-001 …` |
| 文档 | `{文件} §{节}` | `index.md §3.2` |

## 异常处理

| 场景 | 处理 |
| ---- | ---- |
| 无 SOLUTION | 终止 → `sdx-solution` |
| §6.1 里程碑不可用 | 硬停：回补 SOLUTION 或等价里程碑清单；不自拟阶段 |
| SOLUTION 其他结构不全 | 警告列缺失；正文标分析盲区 |
| 无 `knowledge/` | 警告；§1.3 标缺基线 |
| 无模板文件 | 终止：需 `assets/analysis-template.md` |
| 另起 MVP 阶段 / 与里程碑不成 1:1 | 终止：对齐上游 §6.1 或回改 SOLUTION |
| MVP 成环 | 终止：出依赖图请用户调 |
| 无 `analysis/` | 可建 `{DOC_DIR}/analysis/` |
