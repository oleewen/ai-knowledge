# solutions — 解决方案

AI SDD **解决方案阶段**：从业务模糊诉求抽象结构化需求、评估影响、消解冲突，输出 `SOLUTION-{ID}.md`。

**元数据**：[solutions_meta.yaml](./solutions_meta.yaml) — 单文件 SSOT：`identity`、`repository`、`pipeline`、`integration`、`layers`（`key`: sol）。

---

## 三步流程

1. **输入**：业务材料、`knowledge/`（已有规约见各 `requirements/.../specs/` 或 `knowledge/technical/`）  
2. **编写**：按模板产出 `SOLUTION-{ID}.md`  
3. **登记**：在下表增加一行  

解决方案按目录约定在 `solutions/` 内标记状态与更新索引；目录级约定仍以 [solutions_meta.yaml](./solutions_meta.yaml) 为准。

---

## 方案索引

| 编号 | 标题 | 关联需求 | 状态 | 更新日期 |
|------|------|----------|------|----------|
| （有则填） | | | | |

---

## 命名

- 文件：`SOLUTION-{ID}.md`；`{ID}` 建议 `YYYYMMDD-{业务诉求概述}` 或项目编号，业务诉求概述由Agent根据输入自动提取和生成  
- frontmatter：`id` 与文件名一致；可选 `parent`、`dependencies`  

---

## 规范

- Skill：[`.ai/skills/sdx-solution/SKILL.md`](.ai/skills/sdx-solution/SKILL.md)  
- 模板：[`.ai/rules/solution/solution-template.md`](.ai/rules/solution/solution-template.md)  

---

## 与下游关系

- 影响面须与 **knowledge** 实体一致  
- **analysis** 中 `ANALYSIS-{ID}.md` 的 `parent` 指向本目录对应 Solution
