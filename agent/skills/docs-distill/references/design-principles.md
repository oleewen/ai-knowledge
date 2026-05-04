# docs-distill 设计原则

与 [anti-patterns.md](anti-patterns.md) 互补；**操作层易错点**仍见 [../gotchas.md](../gotchas.md)。

---

## 原则

1. **单一上行目标**：可晋升知识只写入 `{APPNAME}-overview.md` 第三列；不把应用侧整段原文当作蒸馏终态。
2. **增量默认可重入**：默认依赖 `DISTILL-LOG` + 应用日志确定区间，避免重复全量除非显式 `--full` 且已确认。
3. **先读后写**：落盘前读目标 overview 现有行，再决定 A/U/D。
4. **日志与内容原子**：overview 第三列成功后再写 DISTILL-LOG；失败不前移锚点。
5. **overview 正文无出处脚注**：可追溯性走 CHANGE-LOG / DISTILL-LOG / 会话 spec，不在第三列堆链接。
6. **联邦优先**：系统权威域与应用侧冲突时，按 [federation-spec.md](federation-spec.md) 消解，不强行覆盖。
7. **用户可见风险先预览**：HARD-GATE 场景默认 `dry-run`，再求 `CONFIRMED`。
