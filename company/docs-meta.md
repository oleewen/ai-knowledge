---
type: Directory Meta
title: company 目录元数据
---

```yaml
# company/ 根目录元数据（导航与 SSOT 指针）
id: "DIR-COMPANY"
name: "公司知识库根（company）"
description: "公司层治理与导航根；knowledge/=公司级实体 SSOT；system-{name}/=系统镜像槽位。"

role:
  kind: "documentation_root"
  ssot_subdirectory: "knowledge/"
  # 治理入口：agent/knowledge/README.md；三层边界：knowledge-governance.md
  # 文件分型 / concept：agent/knowledge/okf-spec.md

child_directories:
  knowledge:
    readme: "knowledge/README.md"
    description: "五视角企业架构；overview/=extract·archive·tag 缓冲（非 docs-distill 目标）"
  solutions:
    readme: "solutions/README.md"
    description: "公司级跨系统解决方案"
  analysis:
    readme: "analysis/README.md"
    description: "公司级跨系统需求分析"
  adr:
    readme: "adr/README.md"
    description: "公司层 ADR 正文与 CONTEXT 决策台账"
  system-SYSNAME:
    readme: "system-SYSNAME/README.md"
    description: "系统镜像槽位（占位 SYSNAME）"
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
    description: "仓库治理、跨系统方案/分析产出与归档回写"

outputs:
  primary_artifact:
    pattern: "README.md, index.md, DESIGN.md, knowledge/**/*, system-{name}/**"
    description: "根导航与设计、knowledge/ 公司层 OKF 实体、按需系统槽位镜像"

naming_conventions:
  directory_index:
    description: "实体 ID 与 IDEA-ID 命名以 agent/knowledge/naming-conventions.md 为准"
    reference: "../agent/knowledge/naming-conventions.md"

integration:
  upstream:
    - path: "../agent/"
      description: "规范、模板与 Agent 技能（命名 SSOT：agent/knowledge/；闸门：agent/rules/）"
  downstream:
    - path: "../system/"
      description: "系统层 reference 引用公司层 BD/PL/SYS/MDG/TPL SSOT"
  traceability:
    description: "阶段链 solutions → analysis；各系统 PRD/ASD ∈ system/requirements/"

references:
  - path: "./README.md"
  - path: "./index.md"
  - path: "./DESIGN.md"
  - path: "./knowledge-links.yaml"
  - path: "../agent/knowledge/knowledge-governance.md"
  - path: "../agent/knowledge/okf-spec.md"
```
