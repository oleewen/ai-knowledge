# docs-indexing 交互与确认闸门

与 **sdx-*** / **docs-build** 同构：**中间会话 spec → 参数 Qclose-1 → 写入总确认（`CONFIRMED`）→ 解锁受管路径写入**。硬条件见 [gates.md](gates.md)；六步流程见 [workflow.md](workflow.md)。

---

## 会话 spec

- 路径：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-indexing.md`
- 起稿可选用 [../assets/docs-indexing-session-spec-template.md](../assets/docs-indexing-session-spec-template.md)

---

## 推荐交互节奏

1. **步骤 1～2**：完成参数 **Qclose-1**（C/M/S）；将参数摘要写入会话 spec。
2. **写入前**：在 spec 中列出「**本轮写入路径清单**」（完整仓库根相对路径），保持 `PENDING`，再次请用户确认后改为 `CONFIRMED`。
3. **步骤 3～6**：仅在对照路径清单执行 `INDEX_GUIDE` 与 `INDEXING-LOG` 写入；先主产物、后日志（见 [indexing-log-spec.md](indexing-log-spec.md)）。

---

## 与独立 brainstorming 的边界

本会话主产物为 **`…-docs-indexing.md` + INDEX 资产**；九章结构元变更、全库索引策略重定义等宜先评审再回到本技能参数与事实扫描。详见 [brainstorming-integration.md](brainstorming-integration.md)。
