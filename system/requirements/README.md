# requirements — 需求交付

将 **analysis** 中的高层次需求按 MVP / 阶段落为可执行交付包（PRD / ADD / TDD 等）。

**元数据**：[requirements_meta.yaml](./requirements_meta.yaml)（目录级约定；字段以 YAML 为准）。

---

## 主线（四步）

1. **输入**：`analysis/REQUIREMENT-{ID}.md`、`solutions/SOLUTION-{ID}.md`、模板  
2. **建包**：新建 `REQUIREMENT-{ID}/`（可参考 [REQUIREMENT-EXAMPLE/](./REQUIREMENT-EXAMPLE/)）  
3. **分阶段**：`MVP-Phase-1/`、`MVP-Phase-2/` …  
4. **落盘**：每阶段 `PRD.md`、`ADD.md`、`TDD.md` 等，并用 ID 与上游文档对齐  

---

## 目录结构

```text
requirements/
├── REQUIREMENT-{ID}/
│   ├── MVP-Phase-1/
│   │   ├── PRD.md
│   │   ├── ADD.md
│   │   └── TDD.md
│   └── MVP-Phase-2/
│       └── ...
├── REQUIREMENT-EXAMPLE/
│   └── README.md
└── README.md
```

---

## 模板与命令

- 模板：[../../.ai/rules/requirement/](../../.ai/rules/requirement/)（prd / add / tdd）  
- Skills：sdx-prd、sdx-design、sdx-test（见 [../../.cursor/README.md](../../.cursor/README.md)）  

---

## 示例

结构说明见 [REQUIREMENT-EXAMPLE/README.md](./REQUIREMENT-EXAMPLE/README.md)。
