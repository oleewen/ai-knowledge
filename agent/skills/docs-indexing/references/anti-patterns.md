# docs-indexing 反模式（概念层）

- **跳过参数或写入门禁**：未 C 确认参数、或未 `docs-indexing-gate: CONFIRMED` + 路径清单即写 `INDEX_GUIDE` / `INDEXING-LOG`。
- **多根同名不加路径**：会话 spec 只写 `INDEX_GUIDE.md` 不写 `application/…` / `system/…` 等完整相对路径，导致钩子无法对齐意图。
- **深度 3 抽样跳读**：用户选 3 却以 token 为由少读；违反 [scan-spec.md](scan-spec.md) 应读尽读准则。
- **增量无基线静默全量**：须用户显式改 full 或中止，不得自动降级。

操作层见 [../gotchas.md](../gotchas.md)。
