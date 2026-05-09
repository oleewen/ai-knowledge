---
name: docs-push
description: >
  推送规约：**`spec-asd-*.md`** 递归收集，落成 `{path}/{doc_dir}/requirements/REQUIREMENT-*/MVP-Phase-*/specs/`（中央常在 `{DOC_DIR}/specs/` 落盘则由脚本按文件名归位；若以 `requirements/` 为前缀则从 `--specs-dir` 镜像相对路径）。
  **`spec-{yyMMdd}-{n}-{app}.md`** 仅从 `--specs-dir` 顶层匹配，落成 `{path}/{doc_dir}/specs/`。**`spec-dsd-*.md`** 仍按需将 `--specs-dir` 指到 `requirements/.../MVP-Phase-*/specs/`（脚本行为未改）。
  依据 knowledge-links.yaml 的 `{path}/{doc_dir}`；支持 path 与 repo 模式四档 Git；执行 push 须用户确认。
  只要用户提到以下任一场景，就应立即使用本技能，不要等用户明确说「/docs-push」：
  推送 spec 到应用库、同步 specs 到建联 path、按 knowledge-links 上传 spec、把中央 spec 推到目标工程、
  「spec 推到已注册的 app」「repo+feature 分支写 spec」「docs-push 一下」。
  若用户仅要 docs-pull、docs-distill、SDD 终稿闸门或只改 overview，则不要以本技能为主路径。
---

# docs-push（spec 推送到建联目标）

本技能以 **调度器** 方式工作：先读闸门与参数说明，在**用户确认**（尤其 `git push`）前提下调用 `scripts/push-specs.sh`。

> **写盘目标**：每条 link 的**本机 `path`** × `{doc_dir}`（缺省常为 `application`/`docs`，以 YAML 为准）。**Legacy**规约 → `{doc_dir}/specs/`。**spec-asd** → `{doc_dir}/requirements/REQUIREMENT-{IDEA}/MVP-Phase-{N}/specs/` 或镜像 `requirements/` 子树。**不**使用 `repository` 隐式 clone；远端仅元数据。

---

## 读序（先读后写）

1. [references/gates.md](references/gates.md)
2. [references/parameters.md](references/parameters.md)
3. [references/workflow.md](references/workflow.md)
4. 陷阱：[gotchas.md](gotchas.md)

---

## 脚本入口

从**中央知识库仓库根**执行（路径相对根）：

```bash
bash agent/skills/docs-push/scripts/push-specs.sh copy --specs-dir DIR --links system/knowledge-links.yaml --mode path
```

**spec-asd 中央在 `application/specs/` 时**（`--specs-dir` 取 `{DOC_DIR}` 根或其父级，以便 `find` 命中子目录下的 `spec-asd-*.md`）：

```bash
bash agent/skills/docs-push/scripts/push-specs.sh copy --specs-dir ./application --links system/knowledge-links.yaml --mode path --dry-run
```

`--links` 为相对路径时，相对于中央库根目录。

---

## 与 docs-pull 的边界

| docs-push | docs-pull |
|-----------|-----------|
| 中央 → 目标：`spec-asd` 入 `{doc_dir}/requirements/…/specs/`；legacy 入 `{doc_dir}/specs/` | 目标 → 中央 `applications/app-*` 镜像 |
| 需显式 `--links` | 依赖 manifest 等 |

---

## 评测（skill-creator）

- `evals/evals.json`
