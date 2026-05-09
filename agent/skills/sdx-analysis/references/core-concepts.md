# sdx-analysis 核心概念

## IDEA-ID

`{YYMMDD}-{主题}`，与 **sdx-solution** / `SOLUTION-{IDEA-ID}.md` **同链**。

- `YYMMDD`：如 `260412`
- `主题`：中文短名 2–6 字

| 产物 | 路径示例 |
|------|-----------|
| 会话 spec | `docs/superpowers/specs/2026-04-12-审批提效-sdx-analysis.md` |
| 需求分析 | `{DOC_DIR}/analysis/ANALYSIS-260412-审批提效.md` |
| 上游方案 | `{DOC_DIR}/solutions/SOLUTION-260412-审批提效.md` |

## 编号

| 前缀 | 含义 | 例 |
|------|------|-----|
| G-n | §1.2 目标（对齐 SOLUTION） | `G-1 …` |
| FR-nnn | §2 功能需求 | `FR-001` |
| BR-nnn | 业务规则（挂在 FR 内） | `BR-001` |
| R-n | §5.2 风险 | `R-1` |
| MVP-n | §4 阶段 | `MVP-1` |
| Q-n | 阶段二待澄清 | `Q-1` |

**G{n}** = 门禁；**G-n** = 目标条目；勿混。

## `--depth`

| 值 | 含义 |
|----|------|
| `quick` | 研究收窄；FR 主攻 P0/P1 |
| `standard` | 默认全量细化 |
| `deep` | 对标与可行性加强；工程数可收敛 §6.3 |

## ANALYSIS 六章

对齐 [analysis-template.md](../assets/analysis-template.md)：

| 章 | 内容 |
|---|------|
| §1 | 背景、G-n、范围与约束、研究与分析 |
| §2 | FR（含 BR、对象、验收）+ 概览表 |
| §3 | 非功能 §3.1–§3.5 |
| §4 | MVP、依赖图 |
| §5 | 依赖、R-n |
| §6 | 术语、参考、变更历史（§6.3）、自查（§6.4） |

元数据：**仅**文末 fenced `yaml`；**禁止**文首 `---`。
