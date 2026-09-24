---
type: Directory Meta
title: system 目录元数据
---

```yaml
# system/ 根目录元数据（导航与 SSOT 指针）
id: "DIR-SYSTEM"
name: "系统知识库根（system）"
description: "系统层治理与导航根。契约见 DESIGN.md；knowledge/=实体 SSOT；application-slots/=应用软链；solutions→analysis→requirements=系统 SDD。"

role:
  kind: "documentation_root"
  ssot_subdirectory: "knowledge/"
  # 层设计入口：DESIGN.md；语义 SSOT：knowledge-governance.md；组件：agent/knowledge/README.md
  # 文件分型 / concept：agent/knowledge/okf-spec.md

child_directories:
  knowledge:
    readme: "knowledge/README.md"
    description: "五视角；overview/=缓冲（非实体 SSOT）"
  adr:
    readme: "adr/README.md"
    description: "系统层 ADR + CONTEXT"
  application-slots:
    readme: "application-slots/README.md"
    description: "应用联邦槽位（application-{NAME}）"
  solutions:
    readme: "solutions/README.md"
    description: "系统级 SOLUTION-{IDEA-ID}.md"
  analysis:
    readme: "analysis/README.md"
    description: "系统级 ANALYSIS-{IDEA-ID}.md"
  requirements:
    readme: "requirements/README.md"
    description: "REQUIREMENT-{IDEA-ID}/ 交付树"
  changelogs:
    readme: "changelogs/README.md"
    description: "变更留痕与索引运维"

child_files:
  - "README.md"
  - "DESIGN.md"
  - "index.md"
  - "INDEX-GUIDE.md"
  - "docs-meta.md"
  - "knowledge-links.yaml"
  - "viz.html"

inputs:
  - path: "(from-repository-and-delivery)"
    description: "仓库治理、方案/分析/交付与归档回写"

outputs:
  primary_artifact:
    pattern: "README.md, index.md, knowledge/**/*, application-slots/**"
    description: "根导航、knowledge/ 实体、按需应用槽位"

naming_conventions:
  directory_index:
    description: "实体 ID / IDEA-ID 见 naming-conventions.md"
    reference: "../agent/knowledge/naming-conventions.md"

integration:
  upstream:
    - path: "../agent/"
      description: "规范、模板与 Agent 技能"
  traceability:
    description: "solutions → analysis → requirements；overview → archive"

references:
  - path: "./README.md"
  - path: "./DESIGN.md"
  - path: "./index.md"
  - path: "./knowledge-links.yaml"
  - path: "../agent/knowledge/knowledge-governance.md"
  - path: "../agent/knowledge/okf-spec.md"
```
