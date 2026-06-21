---
name: docs-okf
description: >
  OKF bundle 迁移、校验与可视化：从 legacy `*-entities.md` 拆出 per-entity concept、注入 frontmatter、
  生成各级 index.md 与 KNOWLEDGE_INDEX、运行 validate-okf、产出 viz.html。
  触发：/docs-okf、OKF 迁移、刷新 viz、对齐 application/ 与 OKF v0.1。
  参数：--dry-run、--validate、--viz、--bundle application。
  设计 spec：docs/superpowers/specs/2026-06-21-application-okf-design.md。
  用户只要 docs-build 提取或 docs-indexing 九章地图为主路径 → 分流对应技能。
---

# docs-okf（OKF 迁移与校验）

判定路径 → 读 [references/workflow.md](references/workflow.md) → 按参数调用 `scripts/okf-migrate.sh` / `validate-okf.sh` / `visualize.py`。

## 边界

| 负责 | 不负责 |
|------|--------|
| OKF 全量/增量迁移编排、frontmatter 注入、index 生成、KNOWLEDGE_INDEX 扫描生成、`validate-okf.sh`、`viz.html` | 九章 `INDEX_GUIDE.md`（docs-indexing）；从源码提取新实体（docs-build）；SDD 终稿 |

## 前置

- 设计 spec：[docs/superpowers/specs/2026-06-21-application-okf-design.md](../../../docs/superpowers/specs/2026-06-21-application-okf-design.md)
- 仓库根可写；默认 bundle 为 `application/`（`--bundle` 可覆盖）
- 全量迁移需存在 legacy `*-entities.md`（缺则对应视角跳过迁移步）

## 参数

| 参数 | 默认 | 说明 |
|------|------|------|
| `--dry-run` | off | 预览各步命令，不写盘 |
| `--validate` | off | 仅运行 `scripts/validate-okf.sh` |
| `--viz` | off | 仅运行 `scripts/okf/visualize.py` 刷新 `viz.html` |
| `--bundle` | `application` | OKF bundle 根目录名（相对仓库根） |

无 flags 时执行完整迁移编排（等同 `okf-migrate.sh`）。

## 脚本入口

```bash
bash scripts/okf-migrate.sh [--dry-run]
bash scripts/validate-okf.sh [--bundle application]
python3 scripts/okf/visualize.py --bundle application --out application/viz.html --name "application OKF"
python3 scripts/okf/generate_index.py --bundle application --recursive
```

## 阅读顺序

1. [references/workflow.md](references/workflow.md) — migrate / validate / viz 三步
2. [docs/superpowers/specs/2026-06-21-application-okf-design.md](../../../docs/superpowers/specs/2026-06-21-application-okf-design.md) — type taxonomy、落盘与 RAG 策略
3. [scripts/README.md](../../../scripts/README.md) — OKF 工具表

## 下游

| 技能 | 关系 |
|------|------|
| docs-build | 新实体应直接产出 per-entity `{ID}.md` |
| docs-indexing | INDEX_GUIDE 更新后建议 `--recursive` index + validate-okf |
