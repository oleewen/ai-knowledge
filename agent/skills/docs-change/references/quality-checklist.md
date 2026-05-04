# docs-change 验证清单

步骤 5 与收束前逐项对照。时间规则细节见 [gotchas.md](../gotchas.md)。

---

## 文件存在性

- [ ] `CHANGE-LOG.md` 存在且为有效 Markdown

## 基线与内容

- [ ] 文末存在 `<!-- docs-change:baseline_time_ms=... -->`，且与本轮聚合后的基线一致
- [ ] 收录条目均标注来源（`git` / `changelog` / `local`）且时间可核对

## 时间一致性

- [ ] 条目时间均在约定的 `baseline_time` / `cutoff_time` 规则下（见 [core-concepts.md](core-concepts.md) 与 gotchas）

---

## 运维建议（非阻塞）

- **定时执行**：每日或每次提交后运行，保持索引新鲜
- **CI 集成**：在 CI/CD 流程中自动生成，产物纳入 git
- **基线备份**：定期备份 `CHANGE-LOG.md` 以防文末基线注释丢失
