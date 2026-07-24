---
type: Directory Meta
title: application 目录元数据
---

```yaml
# application/ 根目录元数据（导航与 SSOT 指针）
id: "DIR-APPLICATION"
name: "应用知识库根（application）"
description: "application/ 根：导航、设计、SDD 阶段与 knowledge SSOT。"

role:
  kind: "documentation_root"
  ssot_subdirectory: "knowledge/"
  # 治理入口：agent/knowledge/README.md；三层边界：knowledge-governance.md

child_directories:
  knowledge:
    meta: "knowledge/knowledge-meta.md"
    description: "五视角；本层首次 API/TBL/MW/CMP"
  solutions:
    readme: "solutions/README.md"
    description: "SOLUTION-{IDEA-ID}.md（约定见 README）"
  analysis:
    readme: "analysis/README.md"
    description: "ANALYSIS-{IDEA-ID}.md（约定见 README）"
  requirements:
    readme: "requirements/README.md"
    description: "REQUIREMENT-{IDEA-ID}/ 树（约定见 README）"
  changelogs:
    readme: "changelogs/README.md"
    description: "CHANGE-LOG.md、INDEXING-LOG.md"
  adr:
    readme: "adr/README.md"
    description: "应用层 ADR（ADR-{序号}-{标题}.md）"

child_files:
  - "README.md"
  - "README-s.md"
  - "README-c.md"
  - "index.md"
  - "INDEX-GUIDE.md"
  - "DESIGN.md"
  - "CONTRIBUTING.md"
  - "docs-meta.md"
  - "manifest.md"
  - "viz.html"

inputs:
  - path: "(from-repository-and-delivery)"
    description: "仓库治理、方案/分析/交付产出；上行 pull/distill 入系统"

outputs:
  primary_artifact:
    pattern: "README.md, index.md, DESIGN.md, CONTRIBUTING.md, knowledge/**/*"
    description: "根入口 + knowledge/（{perspective}-meta.md + 实体 {ID}.md，OKF SSOT）"

naming_conventions:
  directory_index:
    description: "knowledge/ → knowledge-meta.md；五视角 → {perspective}-meta.md + 实体 {ID}.md"
    reference: "../agent/knowledge/naming-conventions.md"

integration:
  upstream:
    - path: "../agent/"
      description: "规范、模板与 Agent 技能"
  traceability:
    description: "solutions → analysis → requirements；规约 ∈ specs/ 或 knowledge/application/；上行 distill 仅写 system overview"

references:
  - path: "./README.md"
  - path: "./index.md"
  - path: "./DESIGN.md"
  - path: "./CONTRIBUTING.md"
  - path: "../agent/knowledge/knowledge-governance.md"
```
