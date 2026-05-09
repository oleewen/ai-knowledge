---
name: docs-push
description: >
  按 `knowledge-links.yaml` 将中央规约复制到各应用本机 `path`×`doc_dir`：legacy `spec-{yyMMdd}-{n}-{app}.md` → `{doc_dir}/specs/`（仅 `--specs-dir` 顶层）；`spec-asd-*.md` 递归收集，归位到 `requirements/REQUIREMENT-*/MVP-Phase-*/specs/` 或按 `requirements/` 前缀镜像。
  `spec-dsd-*.md` 需将 `--specs-dir` 指到对应 Phase 下 `specs/`。支持 `path`/`repo` 与 Git 四档（`none|stage|commit|push`）；**非 dry-run 写盘与 `git push` 须用户确认**。
  「推 spec 到应用库」「按 knowledge-links 同步 specs」「docs-push」等意图触发；仅 docs-pull、distill、SDD 闸门或只改 overview 时分流。
---

# docs-push：spec 推送到建联目标

调度器：读闸门与参数 → 用户确认（尤其写盘、`push`）→ 调用 `scripts/push-specs.sh`。

**写盘**：每条 link 的**本机 `path`** × `doc_dir`（YAML 为准）。**不**用 `repository` 做隐式 clone；远端仅元数据。

## 读序

1. [references/gates.md](references/gates.md)
2. [references/parameters.md](references/parameters.md)
3. [references/workflow.md](references/workflow.md)
4. [gotchas.md](gotchas.md)

## 脚本（中央库根执行）

```bash
bash agent/skills/docs-push/scripts/push-specs.sh copy \
  --specs-dir DIR --links system/knowledge-links.yaml --mode path
```

**`spec-asd` 常在 `{DOC_DIR}/specs/`**：`--specs-dir` 取能 `find` 到文件的根（常 `./application`），先 `--dry-run`。

相对 `--links` 相对**中央库根**。

## 与 docs-pull

| docs-push | docs-pull |
|-----------|-----------|
| 中央 → 目标（asd → `requirements/…/specs/`；legacy → `specs/`） | 目标 → 中央 `applications/app-*` |
| 显式 `--links` | 依赖 manifest 等 |

## 评测

[evals/evals.json](evals/evals.json)
