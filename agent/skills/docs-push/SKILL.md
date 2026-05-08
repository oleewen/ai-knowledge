---
name: docs-push
description: >
  将 specs 目录下符合 `spec-asd-*.md`（架构规约草案）与 `spec-dsd-*.md`（详设规约终稿）的文件推送到 knowledge-links.yaml
  已登记目标库的 {path}/{doc_dir}/specs/；支持 path 与 repo+feature 模式；拷贝后通过脚本四档衔接 Git（不暂存/暂存/提交/推送）。
  只要用户提到以下任一场景，就应立即使用本技能，不要等用户明确说「/docs-push」：
  推送 spec 到应用库、同步 specs 到建联 path、按 knowledge-links 上传 spec、把中央 spec 推到目标工程、
  「spec 推到已注册的 app」「repo+feature 分支写 spec」「docs-push 一下」。
  若用户仅要 docs-pull、docs-distill、SDD 终稿闸门或只改 overview，则不要以本技能为主路径。
---

# docs-push（spec 推送到建联目标）

本技能以 **调度器** 方式工作：先读闸门与参数说明，在**用户确认**（尤其 `git push`）前提下调用 `scripts/push-specs.sh`。

> **写盘目标**：`knowledge-links.yaml` 中每条 link 的**本机 `path`** 下 `{doc_dir}/specs/`（`doc_dir` 缺省为 `docs`）。**不**使用 `repository` 做隐式 clone；远端仅作建联元数据。

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

`--links` 为相对路径时，相对于中央库根目录。

---

## 与 docs-pull 的边界

| docs-push | docs-pull |
|-----------|-----------|
| 中央 → 目标 `path` 下 `{doc_dir}/specs/` | 目标 → 中央 `applications/app-*` 镜像 |
| 需显式 `--links` | 依赖 manifest 等 |

---

## 评测（skill-creator）

- `evals/evals.json`
