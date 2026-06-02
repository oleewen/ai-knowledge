# brainstorming 与 sdx-design

## 会话 spec 路径

闸门中间稿须落在 **`{DOC_DIR}/superpowers/`**（不含 `requirements/**/specs/`）。契约：[session-spec-path.md](../../../references/session-spec-path.md)。

示例：`{DOC_DIR}/superpowers/YYYY-MM-DD-<topic>-sdx-design.md`

阶段二如何在 **Gd{n}**（DSD §1–§3）内嵌 brainstorming，以及与独立 **`/brainstorming`** 的边界。

## 对照

| | 独立 `/brainstorming` | 本技能阶段二 |
|---|----------------------|--------------|
| 主产物 | 常 `*-design.md` + writing-plans | `...-sdx-design.md`；终稿 **DSD** |
| 终态 | 常进入实现计划 | **Qclose-1** → 阶段三分块 |
| 硬门禁 | 随 brainstorming 技能 | **[gates.md](gates.md)** |

**禁止**：以「已完成 brainstorming」为由跳过 **Gd{n}** 收口、门禁或 Qclose-1；禁止默认用独立 `*-design.md` 替代本会话 spec。若需单独产品/架构会话，另开 **`/brainstorming`**，再在本技能消费结论。

## Gd{n} 内多方案

**触发**：本门禁须在≥2条真实可选路径间选结论（接口、数据模型、追溯拆分等；**架构选型**多在 **`/sdx-architect`**）。

**步骤**（仍在同一 Gd{n}）：列 2–3 套**语义命名**方案 → 利弊/条件/推荐 → 标准四选项收口 → 写入「本门禁结论」（含落选搁置理由）。

**与 Q-n**：Q-n = **信息缺口**；本节 = **信息够但分叉**。分叉里仍有缺口则先 Q-n。

## 各门禁多方案示例（非穷尽）

| 门禁 | 例 |
|------|-----|
| Gd1 | §1 与 ASD §1 的粒度、约束摘取 |
| Gd2 | API 风格、幂等、缓存、DDL、与 FR/ASD §3 的映射 |
| Gd3 | 附录深度、对外引用级别、术语范围 |

Gd2 常最密，任一 Gd{n} 有方案分叉都应在本门禁内比选再收口。
