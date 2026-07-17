---
type: Documentation
title: requirements — 需求交付
---
# requirements — 需求交付

索引入口见 [../INDEX-GUIDE.md](../INDEX-GUIDE.md) 与 [index.md](index.md)。前者负责 `application/` 九章地图，后者负责当前目录索引。

将 **analysis** 中的高层次需求按 MVP / 阶段落为可执行交付版本（PRD / **ASD** / **DSD** / TDD 等）。阶段约定 SSOT 为本 README（无 `{dirname}_meta.yaml`）；各 `REQUIREMENT-{IDEA-ID}/` 内不复制根级 meta。

## 层级与交付物

| 层级 | 路径 / 文件 | 约定 |
|------|---------------|------|
| 交付包 | `REQUIREMENT-{IDEA-ID}/` | 与 `ANALYSIS-{IDEA-ID}.md` **同 IDEA-ID**（见 [../../agent/knowledge/naming-conventions.md](../../agent/knowledge/naming-conventions.md)） |
| MVP 阶段 | `MVP-Phase-{N}/` | 阶段目录，其下平铺阶段产物 |
| 阶段产物 | `PRD-{IDEA-ID}.md`、`ASD-{IDEA-ID}-{N}.md`、`DSD-{IDEA-ID}-{N}.md`、`TDD-{IDEA-ID}.md` 等 | 文首 YAML frontmatter（必填） |
| 规约 | `MVP-Phase-{N}/specs/` | `spec-asd-*.md` 等（见 `sdx-architect`） |

## 阶段文档元数据

| 文件 | 关键字段 |
|------|----------|
| `PRD-{IDEA-ID}.md` | `id`、`parent`、`mvp_phase`；`parent` 与 `REQUIREMENT-{IDEA-ID}` 或 `ANALYSIS-{IDEA-ID}` 可追溯一致 |
| `ASD-{IDEA-ID}-{N}.md` | `id`、`parent`；`parent` → 对应 PRD |
| `DSD-{IDEA-ID}-{N}.md` | `id`、`parent`、`architecture_ref`（ASD）；`parent` → 对应 PRD |
| `TDD-{IDEA-ID}.md` | `id`、`parent`；`parent` → 对应 PRD |

## 输入

- [../analysis/](../analysis/) — `ANALYSIS-{IDEA-ID}.md`（可选）
- [../solutions/](../solutions/) — `SOLUTION-{IDEA-ID}.md`（可选）
- [../knowledge/](../knowledge/) — 五视角实体登记、实现映射与应用层实体主定义
- 各需求包内 `specs/` 与 SDX 模板

## 主线（四步）

1. **输入**：`analysis/ANALYSIS-{IDEA-ID}.md`、`solutions/SOLUTION-{IDEA-ID}.md`、模板
2. **建包**：新建 **`REQUIREMENT-{IDEA-ID}/`**（与 `ANALYSIS-*`、`PRD-*` 同属 `*-{IDEA-ID}`，仅类型前缀不同）
3. **分阶段**：`MVP-Phase-1/`、`MVP-Phase-2/` …
4. **落盘**：每阶段 PRD / ASD / DSD / TDD，并与上游 **IDEA-ID** 对齐

## 目录结构

```text
requirements/
├── REQUIREMENT-{IDEA-ID}/
│   ├── MVP-Phase-1/
│   │   ├── PRD-{IDEA-ID}.md
│   │   ├── ASD-{IDEA-ID}-{N}.md
│   │   ├── DSD-{IDEA-ID}-{N}.md
│   │   ├── TDD-{IDEA-ID}.md
│   │   └── specs/
│   └── MVP-Phase-2/
│       └── ...
└── README.md
```

## 交付包索引表

| REQUIREMENT 目录 | 标题 | 关联 ANALYSIS | 状态 | 更新时间 |
|------------------|------|---------------|------|----------|
| ... | ... | ... | ... | ... |

## 模板与命令

- 模板：PRD → [../../agent/skills/sdx-prd/assets/prd-template.md](../../agent/skills/sdx-prd/assets/prd-template.md)；ASD → [../../agent/skills/sdx-architect/assets/asd-template.md](../../agent/skills/sdx-architect/assets/asd-template.md)；DSD → [../../agent/skills/sdx-design/assets/dsd-template.md](../../agent/skills/sdx-design/assets/dsd-template.md)；TDD → [../../agent/skills/sdx-test/assets/tdd-template.md](../../agent/skills/sdx-test/assets/tdd-template.md)
- Skills：`sdx-prd`、`sdx-architect`、`sdx-design`、`sdx-test`（见 [../../agent/README.md](../../agent/README.md)）

## 示例

结构说明见 [REQUIREMENT-EXAMPLE/README.md](REQUIREMENT-EXAMPLE/README.md)。

## 索引维护

变更交付包或 MVP 阶段时，须同步更新上表；重大结构变更时按需更新根 `index.md`。
