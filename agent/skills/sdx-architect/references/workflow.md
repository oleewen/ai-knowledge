# sdx-architect 工作流

[SKILL.md](../SKILL.md) 为主干；写入类门禁与例外见 [gates.md](gates.md)。

---

## 目标

在架构阶段输出可追溯、可落地的 `ASD-{IDEA-ID}-{N}.md`，并为下游 `/sdx-design` 提供稳定输入。

## 标准流程

1. **准备**
   - 确认 `IDEA-ID`、`MVP-Phase`、`KNOWLEDGE_TYPE`、范围边界。
   - 明确输入来源：`ANALYSIS`、`PRD`、现有约束与上下文。
2. **会话草稿**
   - 在会话 spec 中形成 ASD 草稿提纲（对应 `§1/§2/§3`）。
   - 对关键分歧给出可选方案并收敛。
3. **用户总确认**
   - 明确“是否同意以当前草稿生成 ASD 正文”。
   - 未确认前仅允许在会话草稿迭代，不进入 ASD 正式文件写入。
4. **ASD 落盘**
   - 写入 `{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/ASD-{IDEA-ID}-{N}.md`。
   - 内容遵循 `asd-template.md`，至少覆盖 `§1/§2/§3` 与文末元数据。
5. **validate**
   - 在**仓库根**运行 `agent/skills/sdx-architect/scripts/validate-asd.sh`（或于 `agent/skills/sdx-architect/` 下执行 `./scripts/validate-asd.sh`）。
   - 失败则回到草稿修正，再次校验。

## 执行原则

- 先确认再写入：门禁优先于产出速度。
- 结构先行：先定章节骨架，再填业务细节。
- 边界清晰：ASD 只做架构设计，不下沉到 DSD 级实现细节。
