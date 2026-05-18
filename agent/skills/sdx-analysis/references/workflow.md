# sdx-analysis 工作流

主干：[SKILL.md](../SKILL.md)。门禁：[gates.md](gates.md)。

## 目标

将已共识方案细化为可评审排期的 **`ANALYSIS-*.md`（六章）**，供 PRD / 架构等接续。

---

## 门禁状态机

```
[阶段一：参数] → （或 S/F）
[阶段二：逐门禁]
    全量 6G：G1→…→G6
    精简 4G：G(1–2)→G3→G4→G(5–6)
[Qclose-1] → C/S：PENDING→CONFIRMED
[阶段三] 骨架 → chunk 1–6 → 终检
```

| 精简门禁 | 全量 | 模板 |
|---------|------|------|
| G(1–2) | G1、G2 | §1、§2 |
| G3 | G3 | §3 |
| G4 | G4 | §4 |
| G(5–6) | G5、G6 | §5、§6 |

---

## 阶段一

一次抛出三项（支持快捷写法如 `1.1 M IDEA-ID=XXX`）：

1. **IDEA-ID** — `{YYMMDD}-{中文主题}`，**与** `SOLUTION-{IDEA-ID}.md` **同链**，见 [core-concepts.md](core-concepts.md)。
2. **门禁** — 2.1 全量 6G；2.2 精简 4G。
3. **深度** — `standard`（默认）/ `quick` / `deep`（仍须业务表述）。

---

## 阶段二

**路径**：`application/specs/YYYY-MM-DD-<topic>-sdx-analysis.md`，骨架：[analysis-session-spec-template.md](../assets/analysis-session-spec-template.md)。

- 各门禁末附 **C/M/S/F**（见 [gates.md](gates.md)）。
- **门禁进度表**：两列锚到本会话 `## Gn`。
- 单次一段或一点；Gn 收口后再进下一门禁；禁 specs 套话开篇。
- 嵌入 brainstorming：主线仍是本会话 spec + `ANALYSIS-*.md`；详见 [brainstorming-integration.md](brainstorming-integration.md)。

### Qclose-1

见 [gates.md](gates.md)。

---

## 回跳

| 依赖 | 处理 |
|------|------|
| 强 | 与 G{k} 矛盾或同实体（同 FR/MVP/R、同边界）→ 须重确认 |
| 弱 | 大量引用 G{k} 术语/范围/优先级/验收 → 建议重确认 |
| 无 | 可保持 |

例：回改 G2（FR/优先级）→ G4/G5 常为强；回改 G1 In/Out → G2–G5 多至少弱重审。由用户选「仅强」或「强弱一并」。

---

## Q-n 协议

**触发**：任一门禁出现歧义、矛盾或信息缺口。

- 单次一题；选项写业务含义，禁「方案A/B」。
- 结论写入 §1.3、范围或对应 FR；**S** 时标搁置与影响。
- **Q-n 优先模式**（可选）：全部门禁草案后集中澄清，再 Qclose-1。

---

## G{n} 填充要点（摘要）

### G1 §1

通读 SOLUTION → §1.2 **G-n** 对齐；§1.3 范围/假设/研究；四维度（领域边界、核心规则、跨域协作、惯例与陷阱）按 `depth` 取舍；知识库无对应实体标「研究盲区」。

### G2 §2

每 **FR-n** 成节：描述、输入、处理（**BR** 表）、业务对象、输出、异常、验收；章首概览表（FR、优先级、MVP、G-n）；BR 多引时首条详述余交叉引用。

### G3 §3

模板 §3.1–§3.5；优先可感知表述，工程数写「与研发共拟」或 §6.3。

### G4 §4

MVP：独立价值、单向依赖、P0 优先、共性随首个消费者；§4.1 总览、§4.2 分 MVP、§4.3 依赖图**无环**。

### G5 §5

§5.1 依赖（功能/数据/协作/外部），正文写「谁何时交付何结果」；§5.2 **R-n** 含可能/影响/可跟进应对。

### G6 §6

§6.1–§6.4 + 语言审读；文末 fenced `yaml`（`parent`: `SOLUTION-{IDEA-ID}`）；**禁**文首 `---`。终检 [quality-checklist.md](quality-checklist.md)。

---

## 阶段三

1. **骨架**：按 [analysis-template.md](../assets/analysis-template.md) 建 `{DOC_DIR}/analysis/` 下文稿，§6.4 预留 `- [ ]`。
2. **分块**（默认 6 chunk，对齐 G1–G6）：

| Chunk | 章 |
|-------|-----|
| 1 | §1 |
| 2 | §2 |
| 3 | §3 |
| 4 | §4 |
| 5 | §5 |
| 6 | §6（含 §6.4 与 yaml） |

每块末附四选项；可「暂停」。**终检**：quality-checklist，禁假勾。

### Chunk 完成标志

| Chunk | 标志 |
|-------|------|
| 1 | §1.2 G-n 对齐 SOLUTION；§1.3 三节落位 |
| 2 | FR-n 含规则与对象；概览与分节一致 |
| 3 | §3.1–§3.5 落位或「不适用」 |
| 4 | §4.1–§4.3 全；依赖无环 |
| 5 | §5.1–§5.2；R-n 有应对 |
| 6 | §6.4 逐项；元数据齐 |

**F**：一次填至可终检并说明策略；仍须合法例外。
