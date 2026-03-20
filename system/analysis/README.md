# analysis — 需求分析

AI SDD **需求分析阶段**：基于 Solution 与知识库做研究、细化、MVP 拆分，输出 `REQUIREMENT-{ID}.md`。

**元数据**：[analysis_meta.yaml](./analysis_meta.yaml)（目录级约定；字段以 YAML 为准）。

---

## 三步流程

1. **输入**：[solutions/](../solutions/)、[knowledge/](../knowledge/)、[specs/](../specs/)  
2. **编写**：`REQUIREMENT-{ID}.md`，`parent` → 对应 `SOLUTION-{ID}`  
3. **登记**：在下表增加一行  

---

## 分析索引

| 文件 | 标题 | parent（Solution） | 说明 |
|------|------|-------------------|------|
| （有则填） | | | |

---

## 命名

- 文件：`REQUIREMENT-{ID}.md`；`{ID}` 与项目或 Solution 可追溯  
- frontmatter：`id` 与文件名一致；**必填** `parent`  

---

## 规范

- Skill：[../../.ai/skills/sdx-analysis/SKILL.md](../../.ai/skills/sdx-analysis/SKILL.md)  
- 模板：[../../.ai/rules/analysis/requirement-template.md](../../.ai/rules/analysis/requirement-template.md)  

---

## 追溯

- 可与 business / product 的用例、功能 ID 对齐  
- 实现向 technical / data 对齐  
