# sdx-test 操作层陷阱

概念与原则：[references/design-principles.md](references/design-principles.md)。边界误判：[references/anti-patterns.md](references/anti-patterns.md)。

## 前置

- **无 PRD**：终止 → `sdx-prd`（用例缺 US-n/FR-n 锚点）。
- **无 DSD/specs** 却要「全覆盖接口」：§1 标「缺技术设计基线」；接口用例收窄到 PRD 已声明边界；勿编造路径。

## G1 §1

- 回归勿写泛「全量」或罗列模块无章；须对齐 **DSD/ASD** 影响面，标直接/间接与 **P0** 核心链优先。

## G2 §2

- 每 TC 至少锚 **US-n**、**DSD**/规约 API、或 **BR-n**；否则标待澄清勿空填。
- 每 US 须含备选/异常/边界；勿只 happy path。
- §2.4、§2.5 不适用须写「不适用」+原因，勿空白。
- 接口 TC 须含**幂等**与**并发**；BR TC 须有规则组合/冲突场景。

## G3–G4 §3–§4

- 数据须含边界、极端、异常形态（空、超长、特殊字符等）。
- 外部 RPC/MQ 等须写 **Mock/Stub** 策略（谁 Mock、行为）。

## G5 §5

- 进出标准须可检查、可度量（如通过率、缺陷等级）；勿「测试完成」「质量达标」空谈。
- 回归顺序须按影响面：**核心流程 → 直接 → 间接**，勿无序列模块。

## 阶段三

- **禁止**在 TDD 内写可执行脚本/自动化代码；仅 `TDD-*.md`。
- 六章顺序与 [assets/tdd-template.md](assets/tdd-template.md) 一致；无内容标「不适用/待补充」。
- 元数据**仅**文末 fenced `yaml`；须含 `parent`（PRD）、`mvp_phase`；**禁**文首 `---`。
