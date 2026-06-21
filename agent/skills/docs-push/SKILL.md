---
name: docs-push
description: >
  按 knowledge-links.yaml 将中央规约复制到各应用本机 path×doc_dir（legacy spec → specs/；spec-asd → requirements/…/specs/）。
  触发：推 spec 到应用库、按 knowledge-links 同步、docs-push。
  分流：仅 docs-pull/distill/SDD/overview 时 → 对应技能；DSD 正文一般不经本技能。
  门禁：非 dry-run 写盘与 git push 须用户确认（gates.md）。
---

# docs-push：spec 推送到建联目标

读闸门与参数 → 用户确认 → 调用 push-specs.sh。

## 边界

| 负责 | 不负责 |
|------|--------|
| legacy / spec-asd 规约路由与复制；Git 四档 | DSD 正文（sdx-design）；docs-pull 镜像回拉 |

## 最短路径

1. [gates.md](references/gates.md)
2. [parameters.md](references/parameters.md)
3. [workflow.md](references/workflow.md)
4. [gotchas.md](gotchas.md)

## 门禁

非 dry-run 写盘与 `git push` 须用户确认（[gates.md](references/gates.md)）。

## 产出

目标应用本机 `{doc_dir}/specs/` 或 `requirements/…/specs/`（YAML + 脚本为准）。

```bash
bash agent/skills/docs-push/scripts/push-specs.sh copy \
  --specs-dir DIR --links system/knowledge-links.yaml --mode path
```

## 评测 / 脚本

评测：[evals/evals.json](evals/evals.json)。`--specs-dir` 与 `--links` 细则见 parameters.md。
