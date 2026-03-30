# 内置配置与设计原则

knowledge-extract 的硬约束：内置配置、设计原则与错误处理。SKILL.md「核心约束」为精简版，本文件为完整规范。

---

## 内置配置

### 表头约定（table_schema）

```yaml
table_schema:
  header:
    - "层级"
    - "ID"
    - "别名（英文名）"
    - "名称"
    - "证据链"
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
  business: ["BD-", "BSD-", "BC-", "AGG-", "AB-"]
  product: ["PL-", "PM-", "FT-", "UC-"]
  technical: ["SYS-", "APP-", "MS-", "API-"]
  data: ["DS-", "ENT-"]
```

### 证据规则（evidence）

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

### 对称规则（symmetry）

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

---

## 设计原则

| # | 原则 | 说明 |
|---|------|------|
| 1 | 证据优先 | 每个实体 ID 必须有可验证证据。置信度三级：high（代码/配置）、medium（文档推断）、low（间接关联） |
| 2 | 视角分离 | 四视角独立提取，后续视角可引用前序 ID 但不修改前序输出 |
| 3 | 按需加载 | 仅打开本轮任务需要的文件，禁止为「完整性」通读全仓 |
| 4 | 契约驱动 | 以本文件内置配置为硬约束，外部 `knowledge_meta.yaml` 可补充不可覆盖 |
| 5 | 幂等可重试 | 支持中断后从指定视角继续，已提取视角保留，失败视角标记 |
| 6 | 边界清晰 | 仅负责提取和归并，不生成锚点文档、CHANGELOG 或目录树 |

---

## 反模式（禁止）

| 反模式 | 说明 |
|--------|------|
| 编造 ID | 从未读路径提取或凭空发明实体 ID |
| Maven 模块映射 MS | 使用 Maven 模块名作为 MS-ID（应按宿主类聚类） |
| 通读全库 | 一次性通读全仓源码而无论本轮是否用到 |
| 破坏引用 | 更改已有 ID 或断裂已有交叉引用 |
| 跳过验证 | 跳过前缀验证或对称性检查直接写入索引 |
| 模板冒充 | 以非本应用模板 ID 作为索引唯一内容 |
| 无证据写入 | 写入缺少证据链的实体 ID |

---

## 错误处理

| 错误类型 | 处理方式 | 示例 |
|----------|----------|------|
| 主 INDEX 缺失 | 终止，提示先运行 `document-indexing` | Index Guide 未落盘 |
| 证据不足 | 标记 `confidence: low`，继续执行 | MS-* 无宿主类证据 |
| 前缀冲突 | 跳过冲突项，记录日志 | PL-* 无对应 SYS-* |
| 文件不可写 | 终止，提示权限 | KNOWLEDGE_INDEX.md 只读 |
| 输出目录不存在 | 自动创建 | `knowledge/` 缺失 |

### 恢复策略

1. **部分成功**：已提取视角保留，失败视角标记
2. **幂等重试**：支持中断后从指定阶段继续
3. **备份机制**：更新索引前自动备份
