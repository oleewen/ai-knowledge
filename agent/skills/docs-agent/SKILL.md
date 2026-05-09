---
name: docs-agent
description: >
  维护或初始化仓库根目录 README.md 与 AGENTS.md。在用户执行 /docs-agent、入口与 INDEX 不同步、或说「写 README」「更新 AGENTS」「onboarding」时触发。
  以落盘 INDEX_GUIDE.md 为唯一地图，三文件职责不重叠。
  若用户只要 /docs-indexing、docs-build、docs-upgrade 或 SDD/docs-distill/docs-extract 等，则分流，不以本技能为主路径。
---

# 仓库入口文档（docs-agent）

调度器：步骤 0 对齐与门禁 → 读规范 → 依落盘 INDEX 生成根目录 `README.md` / `AGENTS.md`。索引维护见 **docs-indexing**；实体与 KNOWLEDGE_INDEX 见 **docs-build**。

## 边界

| 负责 | 不负责 |
| ---- | ------ |
| 根 `README.md`、`AGENTS.md`；最小阅读集；`--output` / `--mode`；步骤 0 确认书；与 INDEX 对齐的树与指针；`validate-guide.sh` | 生成/重写 `INDEX_GUIDE.md`（`/docs-indexing`）；`application/knowledge` 提取（`docs-build`）；术语批量替换（`docs-upgrade`）；SDD 与 distill/extract/archive 主流程 |

分流：仅更新索引地图 → `docs-indexing`；仅实体 → `docs-build`；入口已由本技能覆盖勿重复主路径。

## 执行前

- 落盘 **INDEX** 存在（例外见 `references/execution-spec.md`）。
- **`--output`**（`readme` / `agents` / `both`）与 **`--mode`**（`create` / `update`）已明确或可唯一推断。
- 已 `source` 共享引导并得到 **`REPO_ROOT`** / **`DOC_ROOT`**（`references/workflow.md` 步骤 1）。

## 读序（先读后写）

1. `references/gates.md` — 门禁与参数
2. `references/workflow.md` — 步骤与 bootstrap
3. `references/execution-spec.md` — Index 解析、探索、降级
4. `references/three-file-spec.md` — 三文件去重
5. `references/quality-standards.md` — 验收
6. `gotchas.md` — 易错点
7. `assets/readme-skeleton.md`、`assets/agents-skeleton.md`

## 门禁

覆盖根目录 `README.md` / `AGENTS.md` 前须完成步骤 0 确认书与用户 **C** / **S**（或等价明确同意）。详见 `references/gates.md`、[agent/rules/CONVENTIONS.md](../../rules/CONVENTIONS.md) 中等风险说明。

## 产出与校验

- 默认：`{REPO_ROOT}` 下 `README.md`、`AGENTS.md`（`--output` 可只其一）。

```bash
bash agent/skills/docs-agent/scripts/validate-guide.sh --root .
```

## 评测

- 样本：`evals/evals.json`
- 元数据模板：`evals/eval-metadata-template.json`
- 评分：`agents/grader.md`；失败分析：`agents/analyzer.md`

## 依赖

| 前置 | 说明 |
| ---- | ---- |
| `docs-indexing` | INDEX 须已落盘；更新 INDEX 单独运行 |
