# docs-okf 工作流

入口：[SKILL.md](../SKILL.md)。

## 三步

### 1 migrate（全量编排）

**脚本**：`bash scripts/okf-migrate.sh [--dry-run]`

按序执行（可重复运行）：

1. `migrate_entities.py` — 五视角；缺 `{perspective}-entities.md` 则跳过
2. `inject_frontmatter.py --bundle application`
3. `generate_index.py --bundle application --recursive`
4. `generate_knowledge_index.py --bundle application`
5. `validate-okf.sh`
6. `visualize.py` → `application/viz.html`

环境变量 `BUNDLE` 可覆盖默认 bundle 名。

### 2 validate（门禁）

**脚本**：`bash scripts/validate-okf.sh [--bundle application]`

检查 frontmatter、`full_id` 唯一性、bundle-relative 链接、`index.md` 条目。有 **ERROR** exit 1；仅 WARN exit 0。

单独校验：`/docs-okf --validate` 或 `--validate --bundle application`。

### 3 viz（可视化）

**脚本**：

```bash
python3 scripts/okf/visualize.py \
  --bundle application \
  --out application/viz.html \
  --name "application OKF"
```

扫描所有 concept，解析 Markdown 链接构图，输出自包含 HTML（Cytoscape + marked）。

单独刷新：`/docs-okf --viz`。

## 参数组合

| 用户意图 | 命令 |
|----------|------|
| 全量迁移 | `bash scripts/okf-migrate.sh` |
| 预览 | `bash scripts/okf-migrate.sh --dry-run` |
| 仅校验 | `bash scripts/validate-okf.sh --bundle application` |
| 仅 viz | `python3 scripts/okf/visualize.py --bundle application --out application/viz.html --name "application OKF"` |
| INDEX_GUIDE 后补 OKF index | `python3 scripts/okf/generate_index.py --bundle application --recursive` 然后 validate |

## 与 docs-indexing 协作

更新 `INDEX_GUIDE.md` 后（docs-indexing 步骤 6 落盘），**建议**：

```bash
python3 scripts/okf/generate_index.py --bundle application --recursive
bash scripts/validate-okf.sh --bundle application
```

`INDEX_GUIDE.md` 仍为九章 Agent 地图；各级 `index.md` 为 OKF 渐进披露入口（双索引并存）。
