# docs-agent 工作流

主干：[SKILL.md](../SKILL.md)。步骤 0：[gates.md](gates.md)。

## 输入输出

| 类型 | 内容 |
| ---- | ---- |
| 硬输入 | 落盘 INDEX；无则不编造 |
| 可选 | 目标、`--output`、`--mode` |
| 固定输出 | `{REPO_ROOT}/README.md`、`AGENTS.md` |
| 不产出 | 不替代 INDEX；不把 INDEX 全文并入 AGENTS |

## 参数

| 参数 | 默认 | 说明 |
| ---- | ---- | ---- |
| `--output` | `both` | `readme` / `agents` / `both` |
| `--mode` | `update` | `create` 初始化；`update` 合并 |

## 步骤 1：Index 解析

`source` `agent/scripts/config-bootstrap.sh`，`validate_bootstrap_docsconfig` 指向本技能 `scripts/`，解析 `.docsconfig` 得 **`REPO_ROOT`**、**`DOC_ROOT`**（及可选 `AGENT_*`）。

```bash
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
source "$REPO_ROOT/agent/scripts/config-bootstrap.sh"
validate_bootstrap_docsconfig "$REPO_ROOT/agent/skills/docs-agent/scripts"
DOC_ROOT="$(resolve_repo_doc_root)"
```

按序查找落盘 Index，命中即停并记录相对路径：`REPO_ROOT` 下 `index.md` / `index.md`，再 `DOC_ROOT` 下同名。未命中 → 终止并提示 `/docs-indexing`。细则与降级见 [execution-spec.md](execution-spec.md)。

## 步骤 2：探索

以 INDEX 为地图，最小阅读集；禁止为 AGENTS 通读全仓。章节 → 去向见 [execution-spec.md](execution-spec.md) §2。

## 步骤 3–4：生成

- README：`assets/readme-skeleton.md`；30 秒内「是什么、下一步」；目录树唯一起源 INDEX §2。
- AGENTS：`assets/agents-skeleton.md`；去重 [three-file-spec.md](three-file-spec.md)；概述 ≤3 行；命令块只在 README。

**顺序：先 README，后 AGENTS。**

## 步骤 5：验证

```bash
bash agent/skills/docs-agent/scripts/validate-guide.sh --root .
```

清单与反模式：[quality-standards.md](quality-standards.md)。

## 约束摘要

| 项 | 要求 |
| -- | ---- |
| 零幻觉 | 无落盘 INDEX 不编造；未读不写死 |
| 意图清 | [gates.md](gates.md) 澄清路径确认前不落盘 |
| 单一事实 | 命令在 README；AGENTS ≤3 行；不复制 INDEX §3 表 |
| INDEX | 本技能内不调 docs-indexing |
| update | `update` 合并，不全量覆盖 |
