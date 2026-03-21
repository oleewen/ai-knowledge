# analysis — 需求分析

AI SDD **需求分析阶段**：基于解决方案（solution）与知识库，做深度研究和分析、细化需求和功能、拆分MVP，输出 `ANALYSIS-{ID}.md`。

**元数据**：[analysis_meta.yaml](./analysis_meta.yaml) — 单文件 SSOT：`identity`、`repository`、`pipeline`、`integration`、`layers`（`key`: an）。

---

## 三步流程

1. **输入**：[solutions/](../solutions/)、[knowledge/](../knowledge/)（已有规约见各 `requirements/.../specs/` 或 [technical](../knowledge/technical/)）
2. **编写**：`ANALYSIS-{ID}.md`，`parent` → 对应 `SOLUTION-{ID}`
3. **登记**：在下表增加一行

---

## 分析索引


| 文件    | 标题  | parent（Solution） | 说明  |
| ----- | --- | ---------------- | --- |
| （有则填） |     |                  |     |


---

## 命名

- 文件：`ANALYSIS-{ID}.md`；`{ID}` 与项目或 Solution 可追溯  
- frontmatter：`id` 与文件名一致；**必填** `parent`

---

## 规范

- Skill：[.ai/skills/sdx-analysis/SKILL.md](.ai/skills/sdx-analysis/SKILL.md)  
- 模板：[.ai/rules/analysis/analysis-template.md](.ai/rules/analysis/analysis-template.md)

---

## 追溯

- 可与 business / product 的用例、功能 ID 对齐  
- 实现向 technical / data 对齐

