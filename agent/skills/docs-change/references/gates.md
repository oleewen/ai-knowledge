# docs-change 闸门与边界

路径契约：[session-spec-path.md](../../../references/session-spec-path.md)（会话 spec 落在 `{DOC_DIR}/superpowers/specs/`，排除 `requirements/**/specs/`）。
与 [collection-rules.md](collection-rules.md) 互补；操作易错见 [gotchas.md](../gotchas.md)。

## 边界

- **负责**：Git、`CHANGELOG*` / `CHANGE-LOG`、本地 mtime 采集，聚合 `{output_dir}/CHANGE-LOG.md`，文末 `<!-- docs-change:baseline_time_ms=... -->`。
- **不负责**：`INDEX_GUIDE`、知识实体、批量改 `README`/`AGENTS`（→ docs-indexing、docs-build 等）。
- **分流**：只要全量/增量文档地图、`INDEX_GUIDE` 时，主路径为 **docs-indexing**，不以仅跑 docs-change 替代。

## `.docsconfig` 硬门禁

**须先**通过 `agent/scripts/config-bootstrap.sh` 之 `validate_bootstrap_docsconfig`（与 `docs-indexing` 之 `indexing.sh` 一致）。

| 条件 | 行为 |
|------|------|
| 仓库根无 `.docsconfig` | **立即中止**；stderr 提示 `docs-install --scope=config`；禁止用手写 `**/changelogs/` 绕过 |
| 缺少 `DOC_ROOT` / `REPO_ROOT` / `DOC_DIR` | 同上，解析失败即中止 |
| 门禁通过 | `cd "$REPO_ROOT"`；默认输出见 collection-rules |

Agent 与 `change-indexing.sh` **均须**走此门禁，不得仅改文档而不校验配置。

## 前置确认

**默认**：无歧义则直接执行 [workflow.md](workflow.md)、[collection-rules.md](collection-rules.md)。

下列情况须先与用户确认：

- 时间基准不清（无 `--since`、无有效文末基线、用户未说明范围）
- 用户显式 `--output` 与 `{DOC_DIR}/changelogs/` 不一致且未说明意图（少见）
- 用户要求**仅采单一来源**

**约定**

- **仅 Git**：`git log` 仍用 `baseline_time`；不写 changelog/local 条目；文末基线照常更新。
- **未指定 `--output`**：固定 `${DOC_ROOT}/changelogs/`（由 `.docsconfig` 解析）
- **已指定 `--output`**：以用户路径为准

上级 [SKILL.md](../SKILL.md)「前置确认」锚点指向本节细则。
