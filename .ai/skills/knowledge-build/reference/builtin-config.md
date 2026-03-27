# 内置配置

knowledge-build 的默认配置。外部 `knowledge_meta.yaml` 的 `knowledge` 块存在时可补充或覆盖，但不改变本文件定义的核心语义。

优先级：**内置默认 → 外部 YAML `knowledge` 块覆盖**

---

## doc_root

```yaml
doc_root:
  description: "知识库体系统辖根路径，以仓库根 README 声明为准"
  inference_examples:
    - "docs/INDEX_GUIDE.md 存在 → Doc Root 倾向 docs/"
  rules:
    - "用户可显式指定 Doc Root；路径不存在则报错并停止"
    - "未指定且多个候选含 knowledge/ 时列出候选，禁止默认择一"
```

## ssot

```yaml
ssot:
  four_perspective_index:
    path: "knowledge/KNOWLEDGE_INDEX.md"
    relative_to: "doc_root"
    contains_prefixes:
      business: ["BD-", "BSD-", "BC-", "AGG-", "AB-"]
      product: ["PL-", "PM-", "FT-", "UC-"]
      technical: ["SYS-", "APP-", "MS-", "API-"]
      data: ["DS-", "ENT-"]
    excludes:
      description: "不得写入四视角 INDEX 的 ID 类别"
      items:
        - "联邦与阶段目录 ID（DIR-APPLICATION-*、DIR-KNOWLEDGE、DIR-REQUIREMENTS、DIR-CHANGELOGS 等）"
        - "各视角 identity.id 的 DIR-KNOWLEDGE-{PERSPECTIVE}（属联邦元数据）"
        - "宪法层治理编号与术语模式（ADR 文号、GLOSSARY 条目模式等）——导航见主 INDEX §2.5 与 constitution/"
    application_only_policy:
      description: "knowledge/KNOWLEDGE_INDEX 与各视角 README 仅登记当前应用已落地或有证据的链上 ID"
      forbid_foreign_template_rows: true
      allowed_gap_marker: "[实体 ID 待补充]"
  federal_index_pointer:
    path: "INDEX_GUIDE.md"
    relative_to: "doc_root"
    section_federation_ids: "§2.5"
```

## symmetry

```yaml
symmetry:
  description: "避免仅业务视角有物化 ID、其它视角空白或仅模板"
  rules:
    - id: "same_round_four_sections"
      text: "knowledge/KNOWLEDGE_INDEX.md 的 §1～§4 同一轮维护"
    - id: "no_template_only"
      text: "forbid_foreign_template_rows 为 true 时，禁止以非本应用模板 ID 作为 INDEX/README 唯一内容"
    - id: "index_over_template"
      text: "可登记 ID 时优先主 INDEX §3/§3.2/§六/§七 与工程事实"
    - id: "bc_agg_linkage"
      text: "§1 已登记 BC/AGG 时，§3 或 §4 至少一类有证据行，或显式待补充与原因"
```

## evidence

```yaml
evidence:
  primary_index_sections:
    - anchor: "§3"
      use: "详细索引表 / 模块与文件"
    - anchor: "§3.2"
      use: "关键实现标识速查"
    - anchor: "§六"
      use: "HTTP / Gateway 路径"
    - anchor: "§七"
      use: "定时任务 / Job"
  repo_facts:
    - "pom.xml"
    - "AGENTS.md"
    - "manifest.yaml"
    - "Mapper/XML 表名（data 视角，已读范围内）"
```

## meta_read_order

```yaml
meta_read_order:
  description: "阶段三生成结构前，按序读取（存在则读）"
  paths:
    - "application_meta.yaml"
    - "knowledge/knowledge_meta.yaml"
    - "knowledge/business/business_meta.yaml"
    - "knowledge/product/product_meta.yaml"
    - "knowledge/technical/technical_meta.yaml"
    - "knowledge/data/data_meta.yaml"
    - "requirements/requirements_meta.yaml"
    - "changelogs/changelogs_meta.yaml"
```

> 项目若有不同 meta 文件布局，可在外部 YAML 的 `knowledge.meta_read_order.paths` 中覆盖。

## meta_shapes

```yaml
meta_shapes:
  description: "*_meta.yaml 形态判定（用于选取 repository/layers）"
  federation_root:
    match:
      - "role.kind: federation_application_root"
      - "child_directories.knowledge"
    example_path: "application_meta.yaml"
  knowledge_tree_root:
    match:
      - "路径 knowledge/knowledge_meta.yaml"
    example_path: "knowledge/knowledge_meta.yaml"
  ssot_v1_1_perspective:
    match:
      - "schema_version: '1.1'"
      - "repository"
      - "layers"
    examples:
      - "knowledge/business/business_meta.yaml"
      - "knowledge/product/product_meta.yaml"
      - "knowledge/technical/technical_meta.yaml"
      - "knowledge/data/data_meta.yaml"
```

## cross_perspective

```yaml
cross_perspective:
  description: "与 business_meta.integration.cross_perspective 及各界 integration 对齐"
  business_meta_field: "integration.cross_perspective"
```

## phases

```yaml
phases:
  - id: 1
    name: "document_indexing"
    skill_ref: ".cursor/skills/document-indexing/SKILL.md"
    outputs:
      - "{doc_root}/INDEX_GUIDE.md"
  - id: 2
    name: "agent_guide"
    skill_ref: ".cursor/skills/agent-guide/SKILL.md"
    outputs:
      - "README.md"
      - "AGENTS.md"
  - id: 3
    name: "knowledge_materialize"
    must:
      - "维护 ssot.four_perspective_index.path"
      - "按各 *_meta.yaml 的 repository/layers 与 INDEX 登记 ID 物化目录与锚点"
    changelog:
      relative_path: "changelogs/CHANGELOG.md"
      meta: "changelogs/changelogs_meta.yaml"
  - id: 4
    name: "acceptance"
    gate: "未纳入 Index 的项须用户多选或「都不索引」书面声明"
```

---

## 外部覆盖机制

若 `{Doc Root}/knowledge/knowledge_meta.yaml` 存在 `knowledge:` 根键：

1. **逐字段合并**：外部值覆盖同路径的内置默认值
2. **新增字段保留**：外部 YAML 中的额外字段（如项目特定的 `meta_read_order.paths`）正常生效
3. **核心语义不可覆盖**：`phases` 的四阶段顺序与 `ssot.four_perspective_index.path` 的 SSOT 语义不可被外部改变
4. **无外部 YAML 时**：完全使用内置默认，技能仍可正常执行
