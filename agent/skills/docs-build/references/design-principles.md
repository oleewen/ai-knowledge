# docs-build 设计原则

与 [anti-patterns.md](anti-patterns.md) 互补；操作细节见 [../gotchas.md](../gotchas.md)。

---

## 原则

1. **Index 先行**：无主 Index Guide 不提取。
2. **证据链**：每个实体 ID 可追溯到已读文件片段。
3. **顺序与依赖**：技术 → 数据 → 业务 → 产品；后序只引用前序 ID。
4. **JSON 与 README 同源**：阶段 3 与 4 避免人类读视角目录与主索引不一致。
5. **对称归并**：`KNOWLEDGE_INDEX` 四段同轮维护。
6. **闸门先于写盘**：Qclose-1 与 `CONFIRMED` 后再改 `{DOC_DIR}/knowledge/`。
7. **可验证**：阶段 4 跑 `validate-extraction.sh` 并对照 [quality-checklist.md](quality-checklist.md)。
