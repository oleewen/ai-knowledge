# solutions — 解决方案

AI SDD **解决方案阶段**：从诉求抽象结构化需求、评估影响、消解冲突，输出 `SOLUTION-{ID}.md`。

**元数据**：[solutions_meta.yaml](./solutions_meta.yaml)（目录级约定；字段以 YAML 为准）。

---

## 三步流程

1. **输入**：业务材料、`knowledge/`、`specs/`  
2. **编写**：按模板产出 `SOLUTION-{ID}.md`  
3. **登记**：在下表增加一行；完结可移入 [archive/](./archive/)  

子目录 **[archive/](./archive/)** 仅存放已结案方案 Markdown；目录级约定仍以 [solutions_meta.yaml](./solutions_meta.yaml) 为准，**不**单建 `archive_meta.yaml`。

---

## 方案索引

| 编号 | 标题 | 关联需求 | 状态 | 更新日期 |
|------|------|----------|------|----------|
| （有则填） | | | | |

---

## 命名

- 文件：`SOLUTION-{ID}.md`；`{ID}` 建议 `YYYYMMDD-SEQ` 或项目编号  
- frontmatter：`id` 与文件名一致；可选 `parent`、`dependencies`  

---

## 规范

- Skill：[../../.ai/skills/sdx-solution/SKILL.md](../../.ai/skills/sdx-solution/SKILL.md)  
- 模板：[../../.ai/rules/solution/solution-template.md](../../.ai/rules/solution/solution-template.md)  

---

## 与下游关系

- 影响面须与 **knowledge** 实体一致  
- **analysis** 中 `REQUIREMENT-{ID}.md` 的 `parent` 指向本目录对应 Solution  
