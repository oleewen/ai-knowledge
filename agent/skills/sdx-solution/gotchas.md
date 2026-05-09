# sdx-solution 操作层陷阱

概念反模式：[references/anti-patterns.md](references/anti-patterns.md)。原则表：[references/design-principles.md](references/design-principles.md)。

## 阶段一

- 参数（IDEA-ID、门禁粒度、深度）一次性列全并支持快捷改；勿逐项追问。
- IDEA-ID：主题以中文为主；若用 ASCII slug，本行备注中文题名。

## 阶段二

- 禁「已在 `…/specs/….md` 补充 G{n}…」套话开篇；直接给要点或问句。
- **G{n}** = 门禁；**G-n** = §1.3 业务目标；勿混。
- Gn 未收口不展开 G(n+1)。
- 回跳 G{k} 后按强/弱依赖评估后续，勿默认全州作废。
- 确认人：填 `$HOME` 末级目录名；勿填显示名、邮箱、「用户」。
- Spec：文末须有 `<!-- sdx-solution-gate: PENDING -->`（总确认后 `CONFIRMED`）；正文至少一次完整 `SOLUTION-{IDEA-ID}.md`。
- 任一 G{n} 若有 ≥2 条真实路径，须在本门禁内比选收口（不限 G4）。

## 阶段三

- §1–§6 / §7.1–§7.2：技术名词转业务表述；确需保留的线索放 §7.3。
- §7.4：须对照 [references/quality-checklist.md](references/quality-checklist.md) 逐项勾选，勿未核全选。

## 输入与歧义

- 无原始描述不开写；过短则补背景。
- 歧义建 Q-n，逐题选项写清业务含义，勿自填。

## 影响面与冲突

- 影响面至少覆盖：功能、数据、接口/对外承诺、下游协作。
- `--depth=quick` 可压缩但不得整块省略；须保留高影响项。
- 每项 C-n 须有化解策略、成本档（高/中/低）、残余风险。

## 方案与 MVP

- 每个 G-n 须可度量或标「待澄清」。
- MVP 须能单独向业务演示并对应明确业务问题。
