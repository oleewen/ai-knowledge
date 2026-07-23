---
type: Directory Meta
title: system 目录元数据
---

```yaml
# system/ 根目录元数据（导航与 SSOT 指针）
id: "DIR-SYSTEM"
name: "系统知识库根（system）"
description: "系统层治理与导航根；knowledge/=系统级实体 SSOT；application-{name}/=应用镜像槽位；solutions→analysis→requirements=系统 SDD。"

role:
  kind: "documentation_root"
  ssot_subdirectory: "knowledge/"
  # 治理入口：agent/knowledge/README.md；三层边界：knowledge-governance.md
  # 文件分型 / concept：agent/knowledge/okf-spec.md

child_directories:
  knowledge:
    readme: "knowledge/README.md"
    description: "五视角架构；overview/=docs-distill·archive 缓冲"
  adr:
    readme: "adr/README.md"
    description: "系统层 ADR 正文"
  application-APPNAME:
    readme: "application-APPNAME/README.md"
    description: "应用镜像槽位（占位 APPNAME）"
  solutions:
    readme: "solutions/README.md"
    description: "系统级 SOLUTION-{IDEA-ID}.md"
  analysis:
    readme: "analysis/README.md"
    description: "系统级 ANALYSIS-{IDEA-ID}.md"
  requirements:
    readme: "requirements/README.md"
    description: "需求交付：REQUIREMENT-{IDEA-ID}/ 树"
  changelogs:
    readme: "changelogs/README.md"
    description: "变更留痕与索引运维"

child_files:
  - "README.md"
  - "index.md"
  - "INDEX-GUIDE.md"
  - "DESIGN.md"
  - "docs-meta.md"
  - "knowledge-links.yaml"
  - "viz.html"

inputs:
  - path: "(from-repository-and-delivery)"
    description: "仓库治理、方案/分析/交付产出与归档回写"

outputs:
  primary_artifact:
    pattern: "README.md, index.md, DESIGN.md, knowledge/**/*, application-{name}/**"
    description: "根导航与设计、knowledge/ 系统层 OKF 实体、按需应用槽位镜像"

naming_conventions:
  directory_index:
    description: "实体 ID 与 IDEA-ID 命名以 agent/knowledge/naming-conventions.md 为准"
    reference: "../agent/knowledge/naming-conventions.md"

integration:
  upstream:
    - path: "../agent/"
      description: "规范、模板与 Agent 技能（命名 SSOT：agent/knowledge/；闸门：agent/rules/）"
  traceability:
    description: "阶段链 solutions → analysis → requirements；架构蒸馏 overview → archive"

references:
  - path: "./README.md"
  - path: "./index.md"
  - path: "./DESIGN.md"
  - path: "./knowledge-links.yaml"
  - path: "../agent/knowledge/knowledge-governance.md"
  - path: "../agent/knowledge/okf-spec.md"
```
