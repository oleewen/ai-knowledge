# sdx-analysis 操作层陷阱

概念反模式：[references/anti-patterns.md](references/anti-patterns.md)。原则：[references/design-principles.md](references/design-principles.md)。

## 阶段一

- IDEA-ID、门禁粒度、深度一次列全并支持快捷改；勿逐项追问。
- IDEA-ID 须与 `SOLUTION-{IDEA-ID}.md` 同链。

## 阶段二

- 禁「已在 `…/specs/….md` 补充 G{n}…」套话开篇。
- **G{n}** = 门禁；**G-n** = §1.2 目标；勿混。
- Gn 收口后再 G(n+1)。
- 回跳 G{k} 后做强/弱依赖评估，勿默认全州作废。
- 确认人：`$HOME` 末级用户名；勿占位词。
- Spec：文末 `<!-- sdx-analysis-gate: PENDING -->`（总确认后 `CONFIRMED`）；正文至少一次 `ANALYSIS-{IDEA-ID}.md`。
- 任一 G{n} 有 ≥2 真实路径须在本门禁比选（不限 G2/G4）。

## 阶段三

- §1–§5、§6.1–§6.2：技术词转业务语；线索收 §6.3「待研发确认」。
- §6.4：对照 [references/quality-checklist.md](references/quality-checklist.md) 逐项勾选。
- **P0** FR 须落入首个合理 MVP；基础设施随首个消费方 MVP。

## 输入与歧义

- 无 `SOLUTION-{ID}`：终止并指向 `sdx-solution`。
- 方案结构不全：警告并列缺失，正文标「基于不完整方案，存在分析盲区」。
- 无 `knowledge/`：§1.3 标「缺少知识库基线，以下仅基于方案」。

## MVP

- 每个 MVP 须能回答解决的**业务问题**；§4.3 依赖无环。
- FR-n 须标 P0–P3，否则 G4 无据。
