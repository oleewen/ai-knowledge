# requirements — 需求交付

将 **analysis** 中的高层次需求按 MVP / 阶段落为可执行交付版本（PRD / ADD / TDD 等）。

**元数据**：[requirements_meta.yaml](requirements_meta.yaml) — 单文件 SSOT：`identity`、`repository`、`pipeline`、`integration`、`layers`（`key`: req → mvp_phase）。不在各 `REQUIREMENT-{IDEA-ID}/` 内复制根级 meta。

---

## 主线（四步）

1. **输入**：`analysis/ANALYSIS-{IDEA-ID}.md`、`solutions/SOLUTION-{IDEA-ID}.md`、模板  
2. **建包**：新建 **`REQUIREMENT-{IDEA-ID}/`**（与 `ANALYSIS-*`、`PRD-*` 同属 `*-{IDEA-ID}`，仅类型前缀不同）  
3. **分阶段**：`MVP-Phase-1/`、`MVP-Phase-2/` …  
4. **落盘**：每阶段 `PRD-{IDEA-ID}.md`、`ADD-{IDEA-ID}.md`、`TDD-{IDEA-ID}.md` 等（亦可用阶段内固定名 `PRD.md` / `ADD.md` / `TDD.md`），并与上游 `ANALYSIS-*` 的 **IDEA-ID** 对齐  

---

## 目录结构

```text
requirements/
├── REQUIREMENT-{IDEA-ID}/
│   ├── MVP-Phase-1/
│   │   ├── PRD-{IDEA-ID}.md
│   │   ├── ADD-{IDEA-ID}.md
│   │   └── TDD-{IDEA-ID}.md
│   └── MVP-Phase-2/
│       └── ...
└── README.md
```

---

## 模板与命令

- 模板：PRD → [../../.agent/skills/sdx-prd/assets/prd-template.md](../../.agent/skills/sdx-prd/assets/prd-template.md)；ADD → [../../.agent/skills/sdx-design/assets/add-template.md](../../.agent/skills/sdx-design/assets/add-template.md)；TDD → [../../.agent/skills/sdx-test/assets/tdd-template.md](../../.agent/skills/sdx-test/assets/tdd-template.md)  
- Skills：sdx-prd、sdx-design、sdx-test（见 [../../.agent/README.md](../../.agent/README.md)）  

---

## 示例

结构说明见 [REQUIREMENT-EXAMPLE/README.md](REQUIREMENT-EXAMPLE/README.md)。
