---
type: Directory Meta
title: system 目录元数据
---

```yaml
# system/ 目录元数据（根导航与 SSOT 指针）
id: "DIR-SYSTEM"
name: "系统知识库根（system）"
description: "企业级知识库 system/ 根目录：人类与 Agent 的主导航（README、INDEX_GUIDE）、设计约束（DESIGN）及知识聚合与联邦槽位。"

role:
  kind: "documentation_root"
  ssot_subdirectory: "knowledge/"
  # 治理与命名 SSOT 见 agent/knowledge/knowledge-governance.md

child_directories:
  knowledge:
    readme: "knowledge/README.md"
    description: "五架构视角聚合；含 overview/ 蒸馏缓冲区"
  adr:
    readme: "adr/README.md"
    description: "系统层 ADR 正文"
  application-APPNAME:
    readme: "application-APPNAME/README.md"
    description: "联邦应用镜像槽位（占位 APPNAME）"
  solutions:
    readme: "solutions/README.md"
    description: "解决方案阶段：平铺 SOLUTION-{IDEA-ID}.md"
  analysis:
    readme: "analysis/README.md"
    description: "需求分析阶段：平铺 ANALYSIS-{IDEA-ID}.md"
  requirements:
    readme: "requirements/README.md"
    description: "需求交付阶段：REQUIREMENT-{IDEA-ID}/ 树"
  changelogs:
    readme: "changelogs/README.md"
    description: "变更留痕与索引运维"

child_files:
  - "README.md"
  - "INDEX_GUIDE.md"
  - "DESIGN.md"
  - "knowledge-links.yaml"

inputs:
  - path: "(from-repository-and-delivery)"
    description: "仓库治理、方案/分析/交付产出与归档回写"

outputs:
  primary_artifact:
    pattern: "README.md, INDEX_GUIDE.md, DESIGN.md, knowledge/**/*"
    description: "根级导航与设计 + knowledge/ 聚合视图与 per-entity OKF concept"

naming_conventions:
  directory_index:
    description: "实体 ID 与 IDEA-ID 命名以 agent/knowledge/naming-conventions.md 为准"
    reference: "../agent/knowledge/naming-conventions.md"

integration:
  upstream:
    - path: "../agent/"
      description: "规范、模板与 Agent 技能（命名 SSOT：agent/knowledge/；闸门：agent/rules/）"
  traceability:
    description: "阶段链 solutions → analysis → requirements；架构蒸馏经 overview → archive"

references:
  - path: "./README.md"
  - path: "./INDEX_GUIDE.md"
  - path: "./DESIGN.md"
  - path: "../agent/knowledge/knowledge-governance.md"
```
