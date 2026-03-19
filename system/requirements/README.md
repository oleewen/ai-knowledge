> **模板示例**：本文件为知识库模板示例，实际项目请按需替换内容与 ID。

# requirements - 需求交付

本文档描述需求交付阶段的目标、输入输出、产物目录结构及工作流程。

## 1. 阶段目标

将需求分析阶段（`analysis/`）输出的高层次需求，按照交付节奏和价值最小化可行产品（MVP）进行拆分与落地。每个需求子包（`REQUIREMENT-{ID}/`）以清晰的结构沉淀为一组交付物，支撑后续详细设计（SPEC）、开发（DEV）、测试（TDD）等流程的顺畅衔接。

## 2. 输入与输出

**输入：**
- 需求分析文档（`analysis/REQUIREMENT-{ID}.md`）
- 解决方案文档（`solutions/SOLUTION-{ID}.md`）
- 相关规范/约定（如 PRD/ADD/TDD 模板等）

**输出：**
- 标准化组织的需求交付目录（`REQUIREMENT-{ID}/`），每阶段一个子目录，内含阶段 PRD、ADD、TDD 等核心文档

## 3. 产物目录结构

```text
requirements/
├── REQUIREMENT-{ID}/                # 单个需求交付包
│   ├── MVP-Phase-1/                 # 阶段（如 MVP、Beta 等）可多级嵌套
│   │   ├── PRD.md                   # 产品需求文档
│   │   ├── ADD.md                   # 架构决策文档（可选）
│   │   └── TDD.md                   # 测试设计文档
│   ├── MVP-Phase-2/
│   └── ...（如需更多阶段）
│
├── REQUIREMENT-EXAMPLE/             # 示例参考（见本目录下README）
│   ├── MVP-Phase-1/
│   │   ├── PRD.md
│   │   └── ...
│   └── README.md
└── README.md                        # 本说明文档
```

## 4. 推荐工作流

1. **建立需求目录**：以 `REQUIREMENT-{ID}/` 新建交付包目录，参考 `REQUIREMENT-EXAMPLE/`。
2. **按阶段组织**：按交付节奏创建 `MVP-Phase-*` 子目录。
3. **落盘交付物并保持追溯**：在每阶段补齐 `PRD.md` / `ADD.md` / `TDD.md` 等，并与 `analysis/REQUIREMENT-{ID}.md`、`solutions/SOLUTION-{ID}.md` 保持 ID 关联。

## 5. 示例参考

具体结构和范例请参考本目录下 [REQUIREMENT-EXAMPLE/README.md](./REQUIREMENT-EXAMPLE/README.md)。

## 6. 相关模板与规范

- 模板：`.ai/rules/requirement/`（prd-template.md、add-template.md、tdd-template.md）
- 阶段规范：`.ai/skills/sdx-prd/`、`.ai/skills/sdx-design/`、`.ai/skills/sdx-test/`

> 阶段命令：`/sdx-prd`、`/sdx-design`、`/sdx-test`；详见 `.cursor/README.md`。
