# docs-change 验证清单

落盘前对照。时间规则见 [gotchas.md](../gotchas.md)。

## 必查

- [ ] `CHANGE-LOG.md` 存在且为有效 Markdown
- [ ] 文末 `<!-- docs-change:baseline_time_ms=... -->` 与本轮基线一致
- [ ] 条目均标来源（`git` / `changelog` / `local`）且时间可核对
- [ ] 条目符合 [core-concepts.md](core-concepts.md) 的 baseline / cutoff 规则

## 运维（非阻塞）

- 定时或提交后跑，保持新鲜
- CI 生成产物可纳入 git
- 定期备份 `CHANGE-LOG.md` 防基线丢失

## 受众（写后 A/B）

- [ ] 已按 [audience-and-language.md](../../../references/audience-and-language.md) 轻流程默认读者表通过 A/B（维护者可读变更摘要；无臆造原因）
