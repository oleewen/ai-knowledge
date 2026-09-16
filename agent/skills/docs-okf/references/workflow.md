# docs-okf 工作流

入口：[SKILL.md](../SKILL.md)。

## 参数向导

按以下顺序收口；用户已明确时可跳过对应项：

1. 目标工程目录
2. 模式：`refresh` / `validate` / `viz` / `dry-run`
3. `--bundle`（默认由 `.docsconfig` 的 `DOC_DIR` 解析）

参数未收口前，不进入执行。

## 前置

读 [path-resolution.md](path-resolution.md)。先 `cd` 到目标工程目录；须有效 `.docsconfig`（含 `KNOWLEDGE_TYPE`）。解析后：

- 默认 `BUNDLE` = `{DOC_DIR}`
- 默认 viz `--out` = `{KNOWLEDGE_TYPE}/viz.html`，`--name` = `"{KNOWLEDGE_TYPE} OKF"`
- 若 CLI/env 覆盖 `BUNDLE` 且与 `{DOC_DIR}` 不同：viz 改为 `{bundle_basename}/viz.html`（见 path-resolution「覆盖」）

若 `.docsconfig` 缺失、解析失败或缺 `KNOWLEDGE_TYPE`，立即中止。

## 三步

### 1 refresh（全量编排）

**入口**：`/docs-okf`（内部脚本：`bash agent/skills/docs-okf/scripts/okf-indexing.sh [--dry-run]`）

按序执行（可重复运行）；`BUNDLE` / `REPO_ROOT` 由 `resolve-okf-paths` 从当前工程 `.docsconfig` 解析：

1. `inject_frontmatter.py --bundle "${DOC_DIR}"`
2. `generate_index.py --bundle "${DOC_DIR}" --recursive`
3. `visualize.py` → `{KNOWLEDGE_TYPE}/viz.html`（`BUNDLE` 覆盖时跟 bundle 名）
4. `okf-validate.sh`
5. `validate_viz_index.py`

实体扫描表 `{DOC_DIR}/INDEX-GUIDE.md` 第五章 **不由本技能写入**；改实体后跑 `/docs-build` 或：

```bash
python3 agent/skills/docs-build/scripts/generate_knowledge_index.py --bundle "${DOC_DIR}"
```

环境变量 `BUNDLE` 或 CLI `--bundle` 可覆盖 `{DOC_DIR}`；覆盖时 viz 输出跟随 bundle 目录名（非主 `KNOWLEDGE_TYPE`）。

> **HARD**：`generate_index.py` 重写目录 `index.md`。实体表在根 `INDEX-GUIDE.md` 第五章标记块，不被 `generate_index` 冲掉。`validate_viz_index` 要求该标记块存在（docs-build 写入）。

结果摘要至少包含：

- bundle 路径
- 是否写入目录 `index.md`
- `validate-okf` 是否通过
- `viz.html` 是否生成
- `INDEX-GUIDE.md` 第五章实体块是否存在（缺则提示跑 docs-build）

### 2 validate

跑 `okf-validate.sh` + `validate_viz_index.py`；不写盘（除校验脚本自身无副作用约定外）。

### 3 viz

单独重跑 `visualize.py`。

## 常用命令

```bash
# 全量 OKF refresh
bash agent/skills/docs-okf/scripts/okf-indexing.sh

# 仅目录 index
python3 agent/skills/docs-okf/scripts/generate_index.py --bundle application --recursive

# 实体扫描索引（docs-build）
python3 agent/skills/docs-build/scripts/generate_knowledge_index.py --bundle application
```

更新九章索引 `INDEX-GUIDE.md` 后，建议跑全量 `okf-indexing.sh`；实体有增删再补 `generate_knowledge_index.py`。
