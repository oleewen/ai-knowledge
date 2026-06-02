# brainstorming 嵌入（sdx-test）

## 会话 spec 路径

闸门中间稿须落在 **`{DOC_DIR}/superpowers/`**（不含 `requirements/**/specs/`）。契约：[session-spec-path.md](../../../references/session-spec-path.md)。

示例：`{DOC_DIR}/superpowers/YYYY-MM-DD-<topic>-sdx-test.md`

## 与独立 `/brainstorming`

| | `/brainstorming` | 本技能阶段二 |
|---|------------------|--------------|
| 产物 | 常 `*-design.md` + `writing-plans` | `…-sdx-test.md` → `TDD-*.md` |
| 终态 | 常进实现计划 | **Qclose-1** → 阶段三定稿 |
| 硬门禁 | brainstorming | **[gates.md](gates.md)** |

**禁止**：以「已完成 brainstorming」跳过 Gn、标记或 Qclose-1；默认不建 `*-design.md` 替代会话 spec。另需独立设计：另会话 `/brainstorming` 后再消费。

## G{n} 内多方案

**触发**：≥2 条真实路径（层次配比、回归范围、数据策略、进出阈值等）。

仍在 **G{n}**：2–3 套命名 → 利弊、条件、推荐 → 四选项 → 「本门禁结论」。**Q-n** 补缺；本节处理决策分叉。

## 各门禁可能触发（示例）

G1 层次与覆盖、G2 粒度与异常类、G3 脱敏/合成、G4 Mock 深度、G5 退出门槛、G6 附录。**G2** 常密集，但任一门禁有分叉须门内比选收口。
