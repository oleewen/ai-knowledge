# requirements — 需求交付

将 **analysis** 中的高层次需求按 MVP / 阶段落为可执行交付版本（PRD / ADD / TDD 等）。

**元数据**：[requirements_meta.yaml](./requirements_meta.yaml) — 单文件 SSOT：`identity`、`repository`、`pipeline`、`integration`、`layers`（`key`: req → mvp_phase）。不在各 `REQUIREMENT-{ID}/` 内复制根级 meta。

---

## 主线（四步）

1. **输入**：`analysis/ANALYSIS-{ID}.md`、`solutions/SOLUTION-{ID}.md`、模板  
2. **建包**：新建 `REQUIREMENT-{ID}/`
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
└── README.md
```

---

## 模板与命令

- 模板：PRD → [.cursor/skills/sdx-prd/assets/prd-template.md](../../.cursor/skills/sdx-prd/assets/prd-template.md)；ADD → [.cursor/skills/sdx-design/assets/add-template.md](../../.cursor/skills/sdx-design/assets/add-template.md)；TDD → [.cursor/skills/sdx-test/assets/tdd-template.md](../../.cursor/skills/sdx-test/assets/tdd-template.md)  
- Skills：sdx-prd、sdx-design、sdx-test（见 [.ai/README.md](.ai/README.md)）  

---

## 示例

结构说明见 [REQUIREMENT-EXAMPLE/README.md](./REQUIREMENT-EXAMPLE/README.md)。
