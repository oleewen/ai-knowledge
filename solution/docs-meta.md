---
type: Directory Meta
title: solution 目录元数据
---
```yaml
id: "DIR-SOLUTION"
name: "解决方案知识库根（solution）"
description: "解决方案层治理根。契约见 DESIGN.md；knowledge/=SLN/PD/L2/MDG/TSD/BP SSOT；system-slots/=系统软链；solutions/=本层 SDD。"

role:
  kind: "documentation_root"
  ssot_subdirectory: "knowledge/"

child_directories:
  knowledge:
    readme: "knowledge/README.md"
    description: "五视角；overview/=缓冲（非实体 SSOT）"
  solutions:
    readme: "solutions/README.md"
    description: "本层 SOLUTION-{IDEA-ID}.md（/sdx-solution 仅此层）"
  adr:
    readme: "adr/README.md"
    description: "解决方案层 ADR + CONTEXT"
  system-slots:
    readme: "system-slots/README.md"
    description: "系统联邦槽位（system-{NAME}）"
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

inputs:
  - path: "(from-repository-and-delivery)"
    description: "跨系统共性、SA 第五至八章、系统槽位上行"

outputs:
  primary_artifact:
    pattern: "README.md, index.md, knowledge/**/*, system-slots/**, solutions/**"
    description: "根导航、本层 OKF 实体、系统槽位、SOLUTION 文"

naming_conventions:
  directory_index:
    description: "实体 ID / IDEA-ID 见 naming-conventions.md"
    reference: "../agent/knowledge/naming-conventions.md"

integration:
  upstream:
    - path: "../agent/"
      description: "规范、模板与 Agent 技能"
    - path: "../company/"
      description: "VC/BD/L1/CAP/BL/TPL"
  downstream:
    - path: "../system/"
      description: "SYS 与实现链；PD 1:1 SYS"
  traceability:
    description: "SA 1–4 → knowledge；5–8 → solutions/；拆分 → 各系统 requirements/"

references:
  - path: "./README.md"
  - path: "./DESIGN.md"
  - path: "./index.md"
  - path: "./knowledge-links.yaml"
  - path: "../agent/knowledge/knowledge-governance.md"
  - path: "../agent/knowledge/okf-spec.md"
```
