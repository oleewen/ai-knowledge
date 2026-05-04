# docs-build 交互与确认闸门

与 **sdx-*** / **docs-extract** 同构：**中间会话 spec → Qclose-1 总确认 → 解锁写入**。硬条件与标记语法见 [gates.md](gates.md)；阶段与参数见 [workflow.md](workflow.md)。

---

## 会话 spec

- 路径：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-build.md`
- 起稿可选用 [../assets/docs-build-session-spec-template.md](../assets/docs-build-session-spec-template.md)

---

## 推荐交互节奏

1. **阶段 1 后**：必须完成 Qclose-1（文件清单 + C/M/S），再改 `CONFIRMED`。
2. **一次一个澄清点**：参数歧义、`DOC_DIR`、校验失败选项，逐项处理。
3. **阶段 2–4**：严格按 [workflow.md](workflow.md) 顺序；后续视角不覆写前序 JSON。
4. **落盘后**：跑 `validate-extraction.sh`，对照 [quality-checklist.md](quality-checklist.md)。

---

## 与独立 brainstorming 的边界

本会话主产物为 **`…-docs-build.md` + knowledge 资产**；重组元模型、改 schema 主版本等应先走设计/评审再回到本技能参数与提取事实。详见 [brainstorming-integration.md](brainstorming-integration.md)。
