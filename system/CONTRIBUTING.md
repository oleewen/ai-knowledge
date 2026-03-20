# 贡献指南 — system/

参与维护前请先读 [DESIGN.md](./DESIGN.md) 与 [AGENTS.md](../AGENTS.md)。禁止在未评估影响面时修改已有实体 **ID** 或破坏跨视角引用。

---

## 工作流（最小步骤）

1. **定范围**：改 knowledge 还是某阶段文档？是否影响 ID 链？  
2. **读入口**：[INDEX.md](./INDEX.md) 对应节 + 子目录 README + 相关 YAML  
3. **落盘**：命名与 frontmatter 见下各节；跨文件只写 **ID**  
4. **登记**：在对应目录 `README.md` 的索引表中增加一行（若有表）  
5. **同步索引**：必要时更新 [INDEX.md](./INDEX.md) 与各视角 README  
6. **提交**：Conventional Commits；大变更可配 ADR  

---

## 一、knowledge

各视角结构以对应 README 为准：

- [knowledge/business/README.md](./knowledge/business/README.md)
- [knowledge/product/README.md](./knowledge/product/README.md)
- [knowledge/technical/README.md](./knowledge/technical/README.md)
- [knowledge/data/README.md](./knowledge/data/README.md)

### ADR

- 路径：`knowledge/constitution/adr/`  
- 文件名：`ADR-{序号}-{短标题}.md`  
- 结构：[standards/adr-template.md](./knowledge/constitution/standards/adr-template.md)

### ID 引用

- 跨文件、跨视角只写 ID，不重复描述  
- 被引用 ID 须在目标视角有定义；改 ID 须全局搜引用  

---

## 二、solutions

- 文件：`solutions/SOLUTION-{ID}.md`（`{ID}` 建议 `YYYYMMDD-SEQ` 或项目编号）  
- 模板：[../.ai/rules/solution/solution-template.md](../.ai/rules/solution/solution-template.md)  
- Skill：[../.ai/skills/sdx-solution/SKILL.md](../.ai/skills/sdx-solution/SKILL.md)  
- 完结 / 废弃 → `solutions/archive/`  

---

## 三、analysis

- 文件：`analysis/REQUIREMENT-{ID}.md`  
- `frontmatter.parent` → 对应 `SOLUTION-{ID}`  
- 模板：[../.ai/rules/analysis/requirement-template.md](../.ai/rules/analysis/requirement-template.md)  
- Skill：[../.ai/skills/sdx-analysis/SKILL.md](../.ai/skills/sdx-analysis/SKILL.md)  

---

## 四、requirements

- 目录：`requirements/REQUIREMENT-{ID}/`，下按 `MVP-Phase-*` 分阶段  
- 交付物：PRD.md、ADD.md、TDD.md 等（模板见 [../.ai/rules/requirement/](../.ai/rules/requirement/)）  
- 与 `analysis/`、`solutions/` 用 ID 保持可追溯  

---

## 五、specs

- 在 `specs/` 下按服务或类型建子目录  
- solutions / analysis 引用此处规约，避免重复定义  

---

更多设计背景见 [DESIGN.md](./DESIGN.md)，路径与示例见 [INDEX.md](./INDEX.md)。
