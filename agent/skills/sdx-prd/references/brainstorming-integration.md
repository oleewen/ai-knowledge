# brainstorming 与 sdx-prd（阶段二）

## 会话 spec 路径

闸门中间稿须落在 **`{DOC_DIR}/superpowers/`**。契约：[session-spec-path.md](../../../references/session-spec-path.md)。

示例：`{DOC_DIR}/superpowers/YYYY-MM-DD-<topic>-sdx-prd.md`

如何把 brainstorming 节奏嵌 **G{n}**，并与 Q-n、C/M/S/F 协同。执行阶段二时建议打开，避免与独立 **`/brainstorming`** 混淆。

## 与独立 `/brainstorming`

| | 独立 `/brainstorming` | 本技能阶段二 |
|---|----------------------|--------------|
| 主产物 | 常 `*-design.md` + writing-plans | `...-sdx-prd.md`；终稿 **PRD** |
| 终态 | 常进实现计划 | **Qclose-1** → 阶段三；默认**不以** writing-plans 收尾 |
| 硬门禁 | 随 brainstorming | **[gates.md](gates.md)** |

**禁止**：以「brainstorming 已完成」跳过 Gn、门禁或 Qclose-1；禁止默认 `*-design.md` 替代本会话 spec。若需独立设计 spec，**另开会话** `/brainstorming` 再在后续消费。

## 何时在 G{n} 做多方案

1. 同门禁下≥2条**真实**可选路径（流程、用例粒度、故事拆分、模块、验收切分等）。  
2. 信息够但需**利弊权衡**后再写「本门禁结论」。

单一合理路径或仅缺事实 → 不必强行走多方案。

## G{n} 多方案步骤

1. **2–3 套**，**业务语义**命名（忌空洞方案A/B）。  
2. 适用条件、成本/风险、推荐。  
3. **C/M/S/F** 收口；结论写入 spec，注明落选搁置理由。

**与 Q-n**：Q-n = **缺信息**；多方案 = **信息够要决策**。分叉里仍缺事实 → 先 Q-n。

## 各 G 典型分叉（非穷尽）

| G | 例 |
|---|-----|
| G1 | 成功标准优先级、MVP 叙事 |
| G2 | 主流程分叉、异常策略 |
| G3 | 交互深/浅 |
| G4 | 用例粒度 |
| G5 | 故事拆分、验收颗粒 |
| G6–G8 | 模块、规则口径、字典详略 |
| G9–G10 | NFR 强度、可测表述 |

**精简 6G** 下合并门禁内更易多方案，仍须在**当前门**内比选收口。
