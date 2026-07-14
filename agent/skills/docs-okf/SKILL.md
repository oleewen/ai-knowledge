---
name: docs-okf
description: >
  OKF bundle refresh、校验与可视化：刷新 index.md、validate-okf、viz.html 与产物校验。
  须先读 .docsconfig：DOC_DIR→--bundle，KNOWLEDGE_TYPE→viz --out/--name；无 config 或缺 KNOWLEDGE_TYPE 硬中止。
  触发：/docs-okf、OKF refresh、刷新 viz、DOC_DIR、DOC_ROOT、KNOWLEDGE_TYPE、目标工程 OKF。
  分流：用户只要 docs-build 提取或 docs-indexing 九章为主路径 → 对应技能。
  推进协议：轻量参数向导、refresh/validate/viz、结果摘要与失败分流见 references/workflow.md。
---

# docs-okf（OKF refresh 与校验）

参数向导 → refresh / validate / viz → 结果摘要或失败分流。

## 输出硬约束（P0）

- 无有效 `.docsconfig` 时立即中止；不得猜测 bundle 路径继续。
- 缺 `KNOWLEDGE_TYPE` 时立即中止；不得生成默认 `viz.html` 路径继续。
- `--dry-run` 只预览，不写盘。
- `validate` 出现 **ERROR** 时不得静默继续后续步骤；必须汇报错误并停下。
- `docs-okf` 是运维维护技能，不引入当前单元循环或 `grilling` 协议。

## 边界

| 负责 | 不负责 |
| ------ | -------- |
| OKF refresh 编排、index、KNOWLEDGE_INDEX、validate-okf、viz、产物校验 | index（docs-indexing）；新实体提取（docs-build）；SDD |

## 最短路径

1. [path-resolution.md](references/path-resolution.md) → [workflow.md](references/workflow.md)
2. [naming-conventions.md](../../../agent/knowledge/naming-conventions.md) §OKF
3. INDEX 落盘后 index 刷新：见 [docs-indexing/SKILL.md](../docs-indexing/SKILL.md) 产出节

## 最少输入

- 目标工程目录
- 有效 `.docsconfig`
- 可解析的 `KNOWLEDGE_TYPE`
- 模式：`refresh` / `validate` / `viz` / `dry-run`

## 失败分流

- `.docsconfig` 缺失或解析失败：立即中止，并提示先补配置
- `KNOWLEDGE_TYPE` 缺失：立即中止，并提示补齐类型
- `validate` 报 **ERROR**：展示错误摘要，不继续后续刷新
- `viz` 输出失败：展示可视化失败原因，不冒充刷新成功

## 产出

刷新后的 bundle、`viz.html`、校验报告（参数见 workflow）。

## 评测 / 脚本

```bash
/docs-okf

bash agent/skills/docs-okf/scripts/okf-indexing.sh [--dry-run]
bash agent/skills/docs-okf/scripts/okf-validate.sh [--bundle "${DOC_DIR}"]
```

与 docs-build / docs-indexing 协作见 workflow 下游表。
