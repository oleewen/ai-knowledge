# 内置配置与错误处理

硬约束全文；摘要见 [SKILL.md](../SKILL.md)、[workflow.md](workflow.md)。

---

## 内置配置

### 表头约定（table_schema）

```yaml
table_schema:
  header: ["层级", "ID", "别名（英文名）", "名称", "证据链"]
  semantics:
    id: "数字编码（同一层级下按数字序列管理）"
    alias: "英文编码（机器可读标识）"
    name: "中文名称（面向业务/阅读）"
  uniqueness:
    - "层级+ID 全知识库唯一"
    - "层级+别名（英文名） 全知识库唯一"
```

### ID 前缀定义（contains_prefixes）

```yaml
contains_prefixes:
  application: ["SYS-", "APP-", "MS-", "API-"]
  data:      ["DS-", "ENT-"]
  business:  ["BD-", "BSD-", "BC-", "AGG-", "AB-"]
  product:   ["PL-", "PM-", "FT-", "UC-"]
```

### 证据规则（evidence）

```yaml
evidence:
  primary_index_sections:
    - { anchor: "§3",   use: "详细索引表 / 模块与文件" }
    - { anchor: "§3.2", use: "关键实现标识速查" }
    - { anchor: "§六",  use: "HTTP / Gateway 路径" }
    - { anchor: "§七",  use: "定时任务 / Job" }
  repo_facts:
    - "pom.xml"
    - "AGENTS.md"
    - "manifest.yaml"
    - "Mapper/XML 表名（data 视角，已读范围内）"
```

### 对称规则（symmetry）

```yaml
symmetry:
  rules:
    - id: same_round_four_sections
      text: "KNOWLEDGE_INDEX.md 的 §1～§4 同一轮维护"
    - id: no_template_only
      text: "禁止以非本应用模板 ID 作为 INDEX/README 唯一内容"
    - id: index_over_template
      text: "可登记 ID 时优先主 INDEX §3/§3.2/§六/§七 与工程事实"
    - id: bc_agg_linkage
      text: "§1 已登记 BC/AGG 时，§3 或 §4 至少一类有证据行，或显式待补充与原因"
```

---

## 设计原则

| # | 原则 | 说明 |
|---|------|------|
| 1 | 证据优先 | high=代码/配置；medium=文档推；low=间接 |
| 2 | 视角分离 | 后序可引前序 ID，不改前序产物 |
| 3 | 按需加载 | 不为「完整」通读全仓 |
| 4 | 契约驱动 | 本文件为硬约束；`knowledge-meta.md` 只可补不可盖 |
| 5 | 幂等 | 断点续跑；失败视角标记 |
| 6 | 边界 | 只提取+归并；无锚点/CHANGELOG/目录树 |

### 禁止

| 行为 | 含义 |
|------|------|
| 编造 ID | 未读路径或无依据 |
| Maven→MS | MS 须宿主聚类 |
| 通读全库 | 无 INDEX 导航的盲扫 |
| 破引用 | 单改旧 ID 不断链 |
| 跳验证 | 无前缀/对称检查就写索引 |
| 模板冒充 | 非本应用模板当唯一内容 |
| 无证据写 | 缺 evidence_chain |

---

## 错误处理

| 情形 | 处理 |
|------|------|
| 无主 INDEX | 停；先 docs-indexing |
| 证据不足 | `confidence: low`，可继续 |
| 前缀冲突 | 跳过并记日志 |
| 不可写 | 停；权限 |
| 无输出目录 | 自动建 |

### 恢复

- 部分成功：保留已成，标失败视角
- 幂等：从阶段/视角续跑
- 更 INDEX 前备份（若实现）
