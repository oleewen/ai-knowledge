# OKF 路径解析（.docsconfig）

入口：[SKILL.md](../SKILL.md)。

## 硬门禁

| 条件 | 行为 |
|------|------|
| 无 `.docsconfig` | **中止** → `docs-install --scope=config --target <DOC_ROOT>` |
| 缺 `DOC_ROOT` / `REPO_ROOT` / `DOC_DIR` | **中止**（config-bootstrap 标准文案） |
| 缺 `KNOWLEDGE_TYPE` | **中止** → `docs-install --scope=knowledge --target <DOC_ROOT>` |

禁止无 config 时默认 `application` 或 git 根回退。

## 映射

| 参数 | 来源 |
|------|------|
| `--bundle` | `{DOC_DIR}` |
| `--out` | `{KNOWLEDGE_TYPE}/viz.html` |
| `--name` | `"{KNOWLEDGE_TYPE} OKF"` |

`DOC_DIR=docs` + `KNOWLEDGE_TYPE=application` 时：bundle 扫描 `docs/knowledge/`，viz 写入 `application/viz.html`。

## Agent 步骤

1. 确认 `.docsconfig` 与 `KNOWLEDGE_TYPE`；或由入口脚本调用 `resolve-okf-paths.sh`
2. 复述 `DOC_DIR` → bundle、`KNOWLEDGE_TYPE` → viz
3. 执行 [workflow.md](workflow.md) 对应命令

## 覆盖

CLI/env `--bundle` 可覆盖 `DOC_DIR`；viz 仍用 `KNOWLEDGE_TYPE`。覆盖时 stderr 一行 warn。

## 脚本

`agent/skills/docs-okf/scripts/resolve-okf-paths.sh` — 与 `docs-build/scripts/validate-extraction.sh` 同源 bootstrap。

OKF refresh / 校验实现位于 `agent/skills/docs-okf/scripts/`（包含 `okf-indexing.sh`、`okf-validate.sh` 与相关 `*.py`）。
