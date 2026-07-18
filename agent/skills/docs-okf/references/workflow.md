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
3. `generate_knowledge_index.py --bundle "${DOC_DIR}"`（**必接**：见下方 HARD）
4. `visualize.py` → `{KNOWLEDGE_TYPE}/viz.html`（`BUNDLE` 覆盖时跟 bundle 名）
5. `okf-validate.sh`
6. `validate_viz_index.py`

环境变量 `BUNDLE` 或 CLI `--bundle` 可覆盖 `{DOC_DIR}`；覆盖时 viz 输出跟随 bundle 目录名（非主 `KNOWLEDGE_TYPE`）。

> **HARD**：`generate_index.py` 会重写各目录 `index.md`，其中 `knowledge/index.md` 的目录段会覆盖既有内容，**实体分表（§1–§5）会被冲掉**。单跑 `generate_index` 后必须立刻跑 `generate_knowledge_index.py`；或直接用全量 `okf-indexing.sh`，勿只跑 index 再 validate。

结果摘要至少包含：

- bundle 路径
- 是否写入 `index.md` / `KNOWLEDGE_INDEX`
- `validate-okf` 是否通过
- `viz.html` 是否生成

### 2 validate（门禁）

**入口**：`/docs-okf`（内部脚本：`bash agent/skills/docs-okf/scripts/okf-validate.sh [--bundle "${DOC_DIR}"]`）

检查 frontmatter、`full_id` 唯一性、bundle-relative 链接、`index.md` 条目。有 **ERROR** exit 1；仅 WARN exit 0。

单独校验：`/docs-okf --validate` 或 `--validate --bundle "${DOC_DIR}"`。

若出现 **ERROR**：

- 停止后续 refresh / viz
- 展示错误摘要
- 指向失败环节（frontmatter / full_id / links / index）

### 3 viz（可视化）

**内部脚本**：

```bash
python3 agent/skills/docs-okf/scripts/visualize.py \
  --bundle "${DOC_DIR}" \
  --out "${KNOWLEDGE_TYPE}/viz.html" \
  --name "${KNOWLEDGE_TYPE} OKF"
```

扫描所有 concept，解析 Markdown 链接构图，输出自包含 HTML（Cytoscape + marked）。

单独刷新：`/docs-okf --viz`。

若输出失败：

- 展示失败原因
- 不冒充 refresh 成功
- 若 validate 已通过，应明确“校验通过但可视化失败”

## 参数组合

| 用户意图 | 命令 |
| ---------- | ------ |
| 全量刷新 | `/docs-okf`（内部脚本：`bash agent/skills/docs-okf/scripts/okf-indexing.sh`） |
| 预览 | `/docs-okf`（内部脚本：`bash agent/skills/docs-okf/scripts/okf-indexing.sh --dry-run`） |
| 仅校验 | `/docs-okf`（内部脚本：`bash agent/skills/docs-okf/scripts/okf-validate.sh`） |
| 仅 viz | `/docs-okf`（内部脚本：`python3 agent/skills/docs-okf/scripts/visualize.py --bundle "${DOC_DIR}" --out "${KNOWLEDGE_TYPE}/viz.html" --name "${KNOWLEDGE_TYPE} OKF"`） |
| index 后补 OKF index | `generate_index.py --recursive` → `generate_knowledge_index.py` → `okf-validate.sh`（推荐直接 `okf-indexing.sh`） |

## 失败分流

| 场景 | 行为 |
| ---------- | ------ |
| `.docsconfig` 缺失 | 立即中止，提示补配置 |
| `KNOWLEDGE_TYPE` 缺失 | 立即中止，提示补类型 |
| bundle 解析失败 | 展示解析失败点，不继续 refresh |
| validate 出现 ERROR | 展示错误摘要，不继续后续步骤 |
| viz 输出失败 | 展示 viz 错误，不冒充成功 |

## 与 docs-indexing 协作

更新九章索引 `INDEX-GUIDE.md` 后，**建议**（须含 knowledge-index，见上方 HARD）：

```bash
# 推荐全量
bash agent/skills/docs-okf/scripts/okf-indexing.sh
# 或分步（顺序不可省 generate_knowledge_index）
python3 agent/skills/docs-okf/scripts/generate_index.py --bundle "${DOC_DIR}" --recursive
python3 agent/skills/docs-okf/scripts/generate_knowledge_index.py --bundle "${DOC_DIR}"
bash agent/skills/docs-okf/scripts/okf-validate.sh
```

九章索引为 `INDEX-GUIDE.md`；OKF 渐进披露入口为 bundle 根 `index.md` 的 OKF 区块与各级子目录 `index.md`（双索引并存）。
