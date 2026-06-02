# sdx-solution 核心概念

## IDEA-ID

格式：`{YYMMDD}-{主题}`

- `YYMMDD`：日期，如 `260412`
- `主题`：中文短名，2–6 字；若含 ASCII slug，spec 同一行备注中文题名

| 产物 | 路径示例 |
|------|-----------|
| 会话 spec | `{DOC_DIR}/superpower/specs/2026-04-12-审批提效-sdx-solution.md` |
| 解决方案 | `{DOC_DIR}/solutions/SOLUTION-260412-审批提效.md` |
| 下游分析 | `{DOC_DIR}/analysis/ANALYSIS-260412-审批提效.md` |

## 编号

| 前缀 | 含义 | 例 |
|------|------|-----|
| G-n | §1.3 业务目标 | `G-1 …` |
| C-n | §3.4 冲突 | `C-1 …` |
| R-n | §5 风险 | `R-1 …` |
| Q-n | 阶段二待澄清 | `Q-1 …` |
| MVP-n | §6 交付阶段 | `MVP-1` |

**G{n}**（大括号）= 门禁编号；**G-n**（连字符）= 业务目标条目；二者勿混。

## `--depth`

| 值 | 含义 |
|----|------|
| `quick` | 压缩 §3；高影响项不可缺 |
| `standard` | 默认完整七章粒度 |
| `deep` | 加强数据影响与约束；正文仍须业务表述 |

## SOLUTION 七章

对齐 [solution-template.md](../assets/solution-template.md)：

| 章 | 内容 |
|---|------|
| §1 | 背景、问题、目标（G-n）、价值 |
| §2 | 场景、角色、In/Out、约束 |
| §3 | 影响面、冲突（C-n）与化解 |
| §4 | 思路、方案对比、关键决策 |
| §5 | 风险（R-n）、待澄清 |
| §6 | MVP、里程碑 |
| §7 | 术语、参考、内部参考（§7.3）、质量自查（§7.4） |

元数据：**仅**文末 fenced `yaml`；**禁止**文首 `---` frontmatter。
