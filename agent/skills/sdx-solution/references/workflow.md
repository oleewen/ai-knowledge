# sdx-solution 工作流

主干：[SKILL.md](../SKILL.md)。门禁：[gates.md](gates.md)。

## 目标

会话 spec + 门禁收口后分块定稿 `SOLUTION-*.md`，为 `sdx-analysis` / `sdx-prd` 等提供稳定输入。

---

## 门禁状态机

```
[阶段一：参数确认] → （或 S/F 跳过）
[阶段二：逐门禁交互]
    全量 7G：G1→…→G7
    精简 5G：G(1–2)→G3→G4→G(5–6)→G7
    每门禁：草案 → （可选）多方案对比 → 确认点 → 收口
[Qclose-1 总确认] → C/S：PENDING→CONFIRMED
[阶段三] 骨架 → chunk 1–5 → 终检
```

| 精简门禁 | 对应 7G | 模板 |
|---------|--------|------|
| G(1–2) | G1、G2 | §1、§2 |
| G3 | G3 | §3 |
| G4 | G4 | §4 |
| G(5–6) | G5、G6 | §5、§6 |
| G7 | G7 | §7 |

---

## 阶段一

一次性抛出三项（支持快捷写法如 `1.1 M IDEA-ID=XXX`）：

1. **IDEA-ID** — 默认 `{YYMMDD}-{中文主题}`，见 [core-concepts.md](core-concepts.md)。
2. **门禁粒度** — 2.1 逐章 7G；2.2 精简 5G。
3. **深度** — 3.1 `standard`（默认）；3.2 `quick`；3.3 `deep`。

---

## 阶段二

**路径**：`{DOC_DIR}/superpowers/YYYY-MM-DD-<topic>-sdx-solution.md`，骨架：[solution-session-spec-template.md](../assets/solution-session-spec-template.md)。

- 各门禁末尾四选项：`C/M/S/F`（全文见 [gates.md](gates.md)）。
- **门禁进度表**：门禁列与「覆盖模板」列锚到**本会话** `## Gn`（占位见会话模板）。
- **节奏**：单次一段或一点；Gn 收口后再 G(n+1)；禁「已在 specs 补充…」类开篇；回跳参见下文。
- brainstorming 对齐：仍以本会话 spec 与 `SOLUTION-*.md` 为主线；详见 [brainstorming-integration.md](brainstorming-integration.md)。
- 任意 **G{n}** 若存在 ≥2 条真实路径，须在**本门禁内**完成对比后再收口（不限于 G4）。

### Qclose-1

见 [gates.md](gates.md)。

---

## 回跳

用户回改 G{k} 后：

| 依赖 | 处理 |
|------|------|
| 强 | 后续与 G{k} 矛盾或同实体引用 → 须重确认 |
| 弱 | 大量引用术语/范围/C-n → 建议重确认 |
| 无 | 可保持 |

由用户选「仅强依赖重走」或「强弱一并重走」。

---

## Q-n 协议

**触发**：阶段二任一门禁歧义、矛盾或信息缺失。

- 单次一个 Q-n，答后再下一题。
- 格式：`Q-{n}`、背景、选项（业务语义，不写「方案A/B」）。
- 结论写入对应门禁小节；用户选 **S** 时标注搁置与影响。
- **Q-n 优先模式**（可选）：全部门禁草案后集中澄清，再进 Qclose-1。

---

## 阶段三

1. **骨架**：按 [solution-template.md](../assets/solution-template.md) 建 `{DOC_DIR}/solutions/` 下文稿，§7.4 预留 `- [ ]`，文末 fenced yaml；可标「草稿填充中」。
2. **分块**（默认 5 chunk）：

| Chunk | 章节 |
|-------|------|
| 1 | §1、§2 |
| 2 | §3 |
| 3 | §4 |
| 4 | §5、§6 |
| 5 | §7（含 §7.4） |

每块结束附四选项；用户可「暂停」。

3. **终检**：[quality-checklist.md](quality-checklist.md) 逐项勾选，禁止假选。

### Chunk 完成标志

| Chunk | 标志 |
|-------|------|
| 1 | G-n 可追溯，In/Out 明确 |
| 2 | §3.4 C-n 齐全，含化解与成本 |
| 3 | 思路可读，关键决策有据 |
| 4 | R-n 有应对，MVP 依赖无环 |
| 5 | §7.4 逐项判定 |

**F**（跳过后续 chunk）：一次填至可终检状态并说明策略；终稿仍需满足 [gates.md](gates.md) 合法例外。
