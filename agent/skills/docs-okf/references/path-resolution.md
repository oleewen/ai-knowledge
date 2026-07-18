# OKF 路径解析（.docsconfig）

入口：[SKILL.md](../SKILL.md)。

## 硬门禁

| 条件 | 行为 |
| ---- | ---- |
| 无 `.docsconfig` | **中止** → `docs-install --scope=config --target <DOC_ROOT>` |
| 缺 `DOC_ROOT` / `REPO_ROOT` / `DOC_DIR` | **中止**（config-bootstrap 标准文案） |
| `.docsconfig` 所在目录与 `REPO_ROOT` 不一致 | **中止** → 视为配置漂移，重新执行 `docs-install` 修复 |
| 缺 `KNOWLEDGE_TYPE` | **中止** → `docs-install --scope=knowledge --target <DOC_ROOT>` |

禁止无 config 时默认 `application` 或 git 根回退。

运行前先 `cd` 到目标工程目录；运行时只解析当前工作目录所属工程的 `.docsconfig`。

## 映射

| 参数 | 来源 |
| ---- | ---- |
| `--bundle` | `{DOC_DIR}`（默认可被覆盖） |
| `--out` | `{KNOWLEDGE_TYPE}/viz.html`（**未**覆盖 bundle 时） |
| `--name` | `"{KNOWLEDGE_TYPE} OKF"`（**未**覆盖 bundle 时） |

`DOC_DIR=docs` + `KNOWLEDGE_TYPE=application` 时：默认 bundle 扫描 `docs/`，viz 写入 `application/viz.html`。

## Agent 步骤

1. 进入目标工程目录，确认 `.docsconfig` 与 `KNOWLEDGE_TYPE`；或由入口脚本调用 `resolve-okf-paths.sh`
2. 复述 `DOC_DIR` → 默认 bundle、`KNOWLEDGE_TYPE` → 默认 viz
3. 执行 [workflow.md](workflow.md) 对应命令

## 覆盖

CLI/env `--bundle` / `BUNDLE` 可覆盖 `DOC_DIR`。覆盖且与 config 推导值不同时：

- stderr 警告覆盖
- **viz 跟随 bundle 目录名**：`--out` → `{bundle_basename}/viz.html`，`--name` → `"{bundle_basename} OKF"`
- 例：`BUNDLE=company` → `company/viz.html`（不再写到主 `KNOWLEDGE_TYPE` 路径）

未覆盖时 viz 仍跟 `KNOWLEDGE_TYPE`。

## 脚本

`agent/skills/docs-okf/scripts/resolve-okf-paths.sh` — 与 `docs-build/scripts/validate-extraction.sh` 同源 bootstrap，按 `PWD` 解析当前工程 `.docsconfig`。

OKF refresh / 校验实现位于 `agent/skills/docs-okf/scripts/`（包含 `okf-indexing.sh`、`okf-validate.sh` 与相关 `*.py`）。
