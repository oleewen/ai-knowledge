# docs-change 风险控制与边界

与 [collection-rules.md](collection-rules.md) 互补；操作易错见 [gotchas.md](../gotchas.md)。

## 边界

- **负责**：Git、`CHANGELOG*` / `CHANGE-LOG`、本地 mtime 采集，聚合 `{output_dir}/CHANGE-LOG.md`，文末 `<!-- docs-change:baseline_time_ms=... -->`。
- **不负责**：`index`、知识实体、批量改 `README`/`AGENTS`（→ docs-indexing、docs-build 等）。
- **分流**：只要全量/增量文档地图、`index` 时，主路径为 **docs-indexing**，不以仅跑 docs-change 替代。

## `.docsconfig` 硬门禁

**须先**通过 `agent/scripts/config-bootstrap.sh` 之 `validate_bootstrap_docsconfig`（与 `docs-indexing` 之 `indexing.sh` 一致）。

| 条件 | 行为 |
| ---- | ---- |
| 仓库根无 `.docsconfig` | **立即中止**；stderr 提示 `docs-install --scope=config`；禁止用手写 `**/changelogs/` 绕过 |
| 缺少 `DOC_ROOT` / `REPO_ROOT` / `DOC_DIR` | 同上，解析失败即中止 |
| 门禁通过 | `cd "$REPO_ROOT"`；默认输出见 collection-rules |

Agent 与 `change-indexing.sh` **均须**走此门禁，不得仅改文档而不校验配置。

## 参数确认

参数向导至少收口以下内容：

- `--since` 或基线策略
- `--output`
- 来源范围（默认三源）

下列情况须先与用户确认：

- 时间基准不清（无 `--since`、无有效文末基线、用户未说明范围）
- 用户显式 `--output` 与 `{DOC_DIR}/changelogs/` 不一致且未说明意图（少见）
- 用户要求**仅采单一来源**

## 风险与动作

以下情况属于风险项，必须先给出结论、推荐方案与动作选项，再等待用户确认：

- 无基线时如何确定时间起点
- 单源模式是否会漏掉用户预期的变更
- `--output` 是否偏离默认目录
- 聚合完成后是否继续下一输出目录

推荐会话格式：

```text
即将执行 /docs-change，当前参数如下：
- since/baseline: <...>
- output: <路径>
- source-scope: <git|changelog|local|all>
- 当前输出单元: <CHANGE-LOG.md 路径>

C 确认当前输出单元 / M 修改参数 / S 跳过当前输出单元 / F 补齐剩余输出目录
```

## 约定

- **仅 Git**：`git log` 仍用 `baseline_time`；不写 changelog/local 条目；文末基线照常更新。
- **未指定 `--output`**：固定 `${DOC_ROOT}/changelogs/`（由 `.docsconfig` 解析）
- **已指定 `--output`**：以用户路径为准

上级 [SKILL.md](../SKILL.md) 的参数与风险约束以本节为准。
