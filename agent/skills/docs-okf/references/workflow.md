# docs-okf 工作流

入口：[SKILL.md](../SKILL.md)。

## 前置

读 [path-resolution.md](path-resolution.md)。须有效 `.docsconfig`（含 `KNOWLEDGE_TYPE`）。解析后：

- `BUNDLE` = `{DOC_DIR}`
- viz `--out` = `{KNOWLEDGE_TYPE}/viz.html`
- viz `--name` = `"{KNOWLEDGE_TYPE} OKF"`

## 三步

### 1 refresh（全量编排）

**脚本**：`bash scripts/okf-migrate.sh [--dry-run]`

按序执行（可重复运行）；`BUNDLE` / `REPO_ROOT` 由 `resolve-okf-paths` 从 `.docsconfig` 解析：

1. `inject_frontmatter.py --bundle "${DOC_DIR}"`
2. `generate_index.py --bundle "${DOC_DIR}" --recursive`
3. `generate_knowledge_index.py --bundle "${DOC_DIR}"`
4. `visualize.py` → `{KNOWLEDGE_TYPE}/viz.html`
5. `validate-okf.sh`
6. `validate_viz_index.py`

环境变量 `BUNDLE` 或 CLI `--bundle` 可覆盖 `{DOC_DIR}`。

### 2 validate（门禁）

**脚本**：`bash scripts/validate-okf.sh [--bundle "${DOC_DIR}"]`

检查 frontmatter、`full_id` 唯一性、bundle-relative 链接、`index.md` 条目。有 **ERROR** exit 1；仅 WARN exit 0。

单独校验：`/docs-okf --validate` 或 `--validate --bundle "${DOC_DIR}"`。

### 3 viz（可视化）

**脚本**：

```bash
python3 scripts/okf/visualize.py \
  --bundle "${DOC_DIR}" \
  --out "${KNOWLEDGE_TYPE}/viz.html" \
  --name "${KNOWLEDGE_TYPE} OKF"
```

扫描所有 concept，解析 Markdown 链接构图，输出自包含 HTML（Cytoscape + marked）。

单独刷新：`/docs-okf --viz`。

## 参数组合

| 用户意图 | 命令 |
| ---------- | ------ |
| 全量刷新 | `bash scripts/okf-migrate.sh` |
| 预览 | `bash scripts/okf-migrate.sh --dry-run` |
| 仅校验 | `bash scripts/validate-okf.sh` |
| 仅 viz | `python3 scripts/okf/visualize.py --bundle "${DOC_DIR}" --out "${KNOWLEDGE_TYPE}/viz.html" --name "${KNOWLEDGE_TYPE} OKF"` |
| index 后补 OKF index | `python3 scripts/okf/generate_index.py --bundle "${DOC_DIR}" --recursive` 然后 validate |

## 与 docs-indexing 协作

更新九章索引 `index.md` 后（docs-indexing 步骤 6 落盘），**建议**：

```bash
python3 scripts/okf/generate_index.py --bundle "${DOC_DIR}" --recursive
bash scripts/validate-okf.sh
```

九章索引为 `index.md`；OKF 渐进披露入口为 bundle 根 `index.md` 的 OKF 区块与各级子目录 `index.md`（双索引并存）。
