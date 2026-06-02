# brainstorming 嵌入（sdx-analysis）

## 会话 spec 路径

闸门中间稿须落在 **`{DOC_DIR}/superpowers/`**（不含 `requirements/**/specs/`）。契约：[session-spec-path.md](../../../references/session-spec-path.md)。

示例：`{DOC_DIR}/superpowers/YYYY-MM-DD-<topic>-sdx-analysis.md`
## 与独立 `/brainstorming`

| | `/brainstorming` | 本技能阶段二 |
|---|------------------|---------------|
| 产物 | 常 `*-design.md` + `writing-plans` | `…-sdx-analysis.md` → `ANALYSIS-*.md` |
| 终态 | 常进实现计划 | **Qclose-1** → 阶段三分块 |
| 硬门禁 | brainstorming | **sdx-analysis** [gates.md](gates.md) |

**禁止**：以「已完成 brainstorming」跳过 Gn、标记或 Qclose-1；默认不建 `*-design.md` 替代会话 spec。另需独立设计：另会话 `/brainstorming` 后再消费结论。

## G{n} 内多方案

**触发**：≥2 条真实路径（FR 切法、非功能、MVP、依赖假设、风险应对等）。

仍在 **G{n}** 内：2–3 套业务命名 → 利弊、条件、推荐 → 四选项 → 写入「本门禁结论」。**Q-n** 补缺事实；本节处理决策分叉。

## 各门禁可能触发（示例）

G1 范围叙事、G2 FR/P0、G3 非功能取舍、G4 MVP、G5 依赖与风险应对、G6 附录粒度。**G2、G4** 常密集，但任一门禁有方案分叉须门内比选收口。
