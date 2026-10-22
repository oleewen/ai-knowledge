# sdx-design 工作流

写作只推进已确认的当前段；纯校验直接使用 [SKILL.md](../SKILL.md#校验) 的命令。

## 输入与缺口

先读 `.docsconfig`，按 [knowledge-type-modes.md](knowledge-type-modes.md) 确认应用文档根。定位同一需求链的 PRD、ASD/spec-asd 和现有 DSD；只加载当前段涉及的章节。ANALYSIS、knowledge、代码与 ADR 按追溯缺口补读。

沿用用户已确认的基线；共识状态未知且影响当前段时先澄清，不把文件存在当作已获共识。

| 输入情况 | 处理 |
| --- | --- |
| PRD 可读，ASD 或 spec-asd 可读 | 核对 IDEA-ID、MVP 与应用归属；进入参数收口 |
| PRD 缺失或无法读取 | 停止生成，指出缺失路径并引导补齐 PRD；不自行代写需求 |
| ASD/spec-asd 均缺失 | 推荐先补架构；用户明确选择受限继续时，将盲区及影响记入 §1.2，不编造 `architecture_ref`，不宣称完整详设已通过 |
| 仅有 spec-asd | 以其 §1–§2 与 `refs` 承接架构，`architecture_ref` 指向真实 spec-asd；不假造 ASD |
| PRD 结构不全，或 ANALYSIS/knowledge 缺失 | 列明对当前段的影响；不影响时标注后继续，影响语义时先澄清 |
| 上游编号、MVP 或架构相互冲突 | 先确认目标基线；边界或能力归属变更回架构阶段 |

## 参数收口

复用用户已给定且核实的参数，只问缺项；可逐项确认或选快捷组合。

| 参数 | 用途 |
| --- | --- |
| `IDEA-ID`、`N` | 从上游获取，保持需求链一致，不另造编号 |
| 上游路径、目标应用、DSD 路径 | 确定证据与写入容器 |
| 标题、当前段/范围 | 新建默认从 §1 开始；补段使用用户指定位置 |
| `depth` | 未指定时用 `standard`；明确的单块补段可用 `quick` 并在摘要说明；`deep` 深入备选、异常与非功能取舍，不扩大范围 |

快捷组合：**标准全篇**（standard，从 §1 逐段推进）、**接口补段**（quick，单 API/错误码/幂等块）、**数据补段**（quick，单 TBL/DDL/事务块）、**深度详设**（deep，已选范围）。“全篇”不等于自动批写授权。

## 容器与当前段

1. 参数收口后，新文档按 [dsd-template.md](../assets/dsd-template.md) 建立 frontmatter、§1–§3 与必要表头；未写内容标为待补充。已有 DSD 原地修改，不重建或覆盖已确认内容。
2. 按 [gates.md](gates.md) 与 [意图澄清契约](../../../references/intent-clarify.md) 收口当前段；骨架不代替正文写前确认。
3. 依 [design-principles.md](design-principles.md) 写入。出现两条以上真实实现路径时，给出与当前段相关的取舍，确认后记录 DD；不为凑数量虚构方案。
4. 写后按下表烤干。动作、`F` 批确认、语义停问和前文重开遵循 [单元推进协议](../../../references/unit-cycle-protocol.md)。

## 写后默认表

| 对象 | 默认 | 必须停下的情况 |
| --- | --- | --- |
| 当前章节或 §2 单个设计块 | 必须自动烤干，含 [受众质检](audience-and-language.md) A/B/C/E | 接口语义、模型、事务/幂等、归属、非功能取舍或上游前提需变更；影响已确认前文 |

按 [grilling-skill.md](../../../references/grilling-skill.md) 检查缺口；修订后执行协议内 simplify 遍。收敛后给 `C/M/G/F` 等待选择。

## 收口

全篇完成或 `F` 补齐后，检查 [quality-checklist.md](quality-checklist.md)，对实际 DSD 运行 `validate-dsd.sh --file`。脚本失败须处理；受限草稿、空扫描或未执行校验均不能报告全篇完成。只补当前段时，报告本段结果与其余未完成范围。
