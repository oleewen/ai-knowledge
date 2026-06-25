---
type: Directory Meta
title: application 目录元数据
---

```yaml
# application/ 目录元数据（根导航与 SSOT 指针）
id: "DIR-APPLICATION"
name: "应用知识库根（application）"
description: "企业级知识库 application/ 根目录：人类与 Agent 的主导航（README、INDEX_GUIDE）、设计约束（DESIGN、CONTRIBUTING）及 SDD 各阶段与 knowledge SSOT。"

role:
  kind: "documentation_root"
  ssot_subdirectory: "knowledge/"
  # 治理与命名 SSOT 见 agent/knowledge/knowledge-governance.md

child_directories:
  knowledge:
    meta: "knowledge/knowledge-meta.md"
    description: "五视角业务 / 产品 / 应用 / 数据 / 技术（SSOT）"
  solutions:
    readme: "solutions/README.md"
    description: "解决方案阶段：平铺 SOLUTION-{IDEA-ID}.md（约定见 README，无 solutions_meta.yaml）"
  analysis:
    readme: "analysis/README.md"
    description: "需求分析阶段：平铺 ANALYSIS-{IDEA-ID}.md（约定见 README，无 analysis_meta.yaml）"
  requirements:
    readme: "requirements/README.md"
    description: "需求交付阶段：REQUIREMENT-{IDEA-ID}/ 树（约定见 README，无 requirements_meta.yaml）"
  changelogs:
    readme: "changelogs/README.md"
    description: "变更留痕与索引运维：CHANGE-LOG.md、INDEXING-LOG.md（约定见 README，无 changelogs_meta.yaml）"
  adr:
    readme: "adr/README.md"
    description: "应用层 ADR 正文（ADR-{序号}-{标题}.md）"

child_files:
  - "README.md"
  - "INDEX-GUIDE.md"
  - "DESIGN.md"
  - "CONTRIBUTING.md"

inputs:
  - path: "(from-repository-and-delivery)"
    description: "仓库治理、方案/分析/交付产出与归档回写"

outputs:
  primary_artifact:
    pattern: "README.md, INDEX-GUIDE.md, DESIGN.md, CONTRIBUTING.md, knowledge/**/*"
    description: "child_files（根级）+ knowledge/ 树（{perspective}-meta.md + 实体文件 {ID}.md，OKF SSOT）"

naming_conventions:
  directory_index:
    description: "knowledge/ 根见 knowledge-meta.md；五视角见 {perspective}-meta.md + 实体文件 {ID}.md"
    reference: "../agent/knowledge/naming-conventions.md"

integration:
  upstream:
    - path: "../agent/"
      description: "规范、模板与 Agent 技能（治理 SSOT：agent/rules/）"
  traceability:
    description: "阶段链 solutions → analysis → requirements；规约落在需求包内 specs/ 或 knowledge/application/；knowledge 为事实源，归档可回写"

references:
  - path: "./README.md"
  - path: "./INDEX-GUIDE.md"
  - path: "./DESIGN.md"
  - path: "./CONTRIBUTING.md"
  - path: "../agent/knowledge/knowledge-governance.md"
```
