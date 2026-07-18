# sdx-prd 操作层陷阱

概念反模式：[references/anti-patterns.md](references/anti-patterns.md)。原则：[references/design-principles.md](references/design-principles.md)。

## 参数向导

- 支持逐项确认与快捷组合。
- 禁止退回已删除的 HTML gate / `PENDING→CONFIRMED` / 会话 spec 写前主线；主线=参数向导 + 「澄清 → 生成 → 烤干」（见 [unit-cycle-protocol.md](../../references/unit-cycle-protocol.md)）。
- `IDEA-ID` / `N` 须与 `ANALYSIS-{IDEA-ID}.md` 及 `MVP-Phase-{N}` 同链。
- 用户若已给 `IDEA-ID`、`N`、章节范围、深度，直接确认缺口，不重复追问已知信息。

## Section Cycle（澄清 → 生成 → 烤干）

- 写入前先意图澄清（六项清单 + 阶段横幅）；未获写前 `C` 勿写正文。
- 一次只处理一个当前段；在 `§4/§5/§10` 可细到单个 `UC` / `US` / `AC/NAC`。
- `C` 同符异义：须标「当前阶段：意图澄清」或「当前阶段：烤干」。
- 自动 `grilling` 要连续收敛，不要每一轮都停下来等用户。
- 当前段若有 `>=2` 条真实路径，先在当前段内完成方案比选。
- 语义性问题先给结论、推荐和数字选项，未确认不得改文。
- 非语义性修订可直改当前段，但不要扩展到前文章节。
- 前文一旦回改，当前段必须 `reopened`：再意图澄清 → 再写/修订 → 再 grill。
- 自动收敛后再给 `C/M/G/F`；不要默认替用户选下一步。
- 勿把 `G` 当意图澄清。

## 输入与歧义

- 无 `ANALYSIS-{ID}`：终止并指向 `sdx-analysis`。
- 未锁 MVP：只写 `MVP-Phase-{N}` 内 FR；混后续阶段 → 范围失控。
- ANALYSIS 结构残：警告并列缺失，正文标「基于不完整基线」。

## §2 主流程

- 主流程与分支/异常分开；扩展节点或子图标触发条件。
- 跨系统节点：系统名、同步/异步、关键 I/O；异步标回调。
- 节点不写长规则正文；旁标 `[BR-n]`，正文汇 §7。

## §4 用例

- 参与者用**业务角色**，不要把“某某服务”直接当角色。
- UC 须有前后置条件。
- UC 描述与 US **双向**互标。

## §5 用户故事

- 每 US 须有 GWT；含边界/异常。
- US 须能独立演示（INVEST）；强依赖则合并或拆。
- 每 US 标 **关联 FR-n、BR-n**。

## §6-§8 模块与规则

- 模块按**业务能力域**，不按前后端分层。
- BR 有优先级；互斥写化解策略。
- 字典字段：类型、必填、枚举、含义；状态机有终态与非法转换策略。

## §9-§11 与元数据

- NAC 指回 §9 或写明不适用。
- 不重排十一章；空节标不适用/待补充。
- 文首 frontmatter 必须齐全；含 `id`、`parent`、`mvp_phase` 等，且 `id` 与路径一致。
- PRD 不写“怎么用 Redis”“调哪个 RPC”这类实现细节，属 DSD。
- 歧义标待澄清，勿自假设。
- Mermaid：`flowchart` / `sequenceDiagram` / `stateDiagram-v2` / `journey` 等按需选对类型。

## 批量补齐

- `F` 须先批确认剩余意图，再补齐剩余未完成章节；不能覆盖已确认前文。
- `F` 过程中若打出语义性问题或前文冲突，必须立刻停下等待用户确认。
