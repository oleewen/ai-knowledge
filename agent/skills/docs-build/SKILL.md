---
name: docs-build
description: >
  从已核实资料构建或同步五视角知识实体、视角 README 与 INDEX-GUIDE 第四章导航。
  用于 /docs-build、初始化知识实体、对齐实体 ID，或 docs-indexing 后的实体构建。
  仅更新九章索引用 docs-indexing；overview 提炼与归档不属本技能。
---

# docs-build

把已核实事实写成每实体一个 `{ID}.md`，同步视角 README 台账，再更新 `{DOC_DIR}/INDEX-GUIDE.md` 第四章导航。脚本负责导航与结构校验，实体提取由 Agent 完成。

## 开始前

1. 从目标仓解析 `.docsconfig`，确认 `{DOC_DIR}`、知识层与主 `INDEX-GUIDE.md`。目录名不等于知识层；缺地图先转 `docs-indexing`。
2. 读 [workflow.md](references/workflow.md) 的参数与执行步骤、[gates.md](references/gates.md) 的当前单元约束。
3. 读 [knowledge-governance.md](../../knowledge/knowledge-governance.md) 的层职责与引用边界；按当前视角查 [extraction-rules.md](references/extraction-rules.md)，无需全量加载参考文件。

## 写入边界

- 当前单元为一个视角批次、路径组或实体集合。写前澄清须列出实体/README 路径和层根 INDEX 导航块；获写前 `C` 后写入，写后校验、烤干并停等下一动作。
- 只落本层首次定义实体；保留已有 ID。重命名须确认引用链；不可因证据不足补造父实体、关系或示例行。
- `knowledge/**` 引用遵守治理规则：同层 knowledge 内互引；上层有 parent 时用约定函数生成 HTTP，否则纯 ID；下层仅纯 ID。读取联邦清单时校验 `${WORK_SPACE}` 路径契约。
- 只更新 INDEX 第四章导航块；九章骨架、OKF 目录索引、overview、归档与 SDD 各走所属技能。导航刷新不删除旧文件。
- 校验失败或路径/语义不明时停止当前单元，保留问题清单；不得继续下一批或宣称收敛。

## 按任务读取

| 当前工作 | 参考 |
| --- | --- |
| 策略、证据不足、增量恢复 | [builtin-config.md](references/builtin-config.md) |
| 实体提取与字段来源 | [extraction-rules.md](references/extraction-rules.md) |
| 更新实体台账 | [readme-fill-spec.md](references/readme-fill-spec.md) |
| 生成导航、脚本参数与兼容行为 | [consolidation-spec.md](references/consolidation-spec.md) |
| 收敛检查 | [quality-checklist.md](references/quality-checklist.md)、[audience-and-language.md](references/audience-and-language.md) |
| 排错 | [gotchas.md](gotchas.md) |

## 维护与验证

技能回归：`python3 -B -m unittest discover -s <技能目录>/tests -v`（Bash 5+ 在 PATH 中）。行为场景见 [evals.json](evals/evals.json)，评分见 [grader.md](agents/grader.md)。
