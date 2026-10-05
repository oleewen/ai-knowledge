---
type: Directory Meta
title: company 目录元数据
---
```yaml
# company/ 根目录元数据（导航与 SSOT 指针）
id: "DIR-COMPANY"
name: "公司知识库根（company）"
description: "公司层治理与导航根。契约见 DESIGN.md；knowledge/=实体 SSOT；solution-slots/=解决方案软链。"

role:
  kind: "documentation_root"
  ssot_subdirectory: "knowledge/"
  # 层设计入口：DESIGN.md；语义 SSOT：knowledge-governance.md

child_directories:
  knowledge:
    readme: "knowledge/README.md"
    description: "五视角；overview/=缓冲（非实体 SSOT）"
  domains:
    readme: "domains/README.md"
    description: "域架构（/sdx-domains）"
  adr:
    readme: "adr/README.md"
    description: "公司层 ADR + CONTEXT"
  solution-slots:
    readme: "solution-slots/README.md"
    description: "解决方案联邦槽位（solution-{NAME}）"
  system-slots:
    readme: "system-slots/README.md"
    description: "遗留；新边不写"
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
    description: "仓库治理、跨系统方案/分析产出与归档回写"

outputs:
  primary_artifact:
    pattern: "README.md, index.md, knowledge/**/*, solution-slots/**"
    description: "根导航、knowledge/ 公司层 OKF 实体、按需联邦槽位"

naming_conventions:
  directory_index:
    description: "实体 ID / IDEA-ID 见 naming-conventions.md"
    reference: "../agent/knowledge/naming-conventions.md"

integration:
  upstream:
    - path: "../agent/"
      description: "规范、模板与 Agent 技能"
  downstream:
    - path: "../system/"
      description: "系统层 reference 公司 BD/PL/TPL；SLN/PD/MDG 在解决方案或系统 SSOT"
  traceability:
    description: "domains → 各 SLN solutions/ → 各系统 analysis/features/requirements/"

references:
  - path: "./README.md"
  - path: "./DESIGN.md"
  - path: "./index.md"
  - path: "./knowledge-links.yaml"
  - path: "../agent/knowledge/knowledge-governance.md"
  - path: "../agent/knowledge/okf-spec.md"
```
