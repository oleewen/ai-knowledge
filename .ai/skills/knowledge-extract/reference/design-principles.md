# 内置配置与设计原则

knowledge-extract 技能的完整内置配置、设计原则、错误处理策略与常见问题。主文件 SKILL.md 中的「核心约束」为精简版，本文件为完整规范。

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

### 1. 证据优先

每个实体 ID 必须有可验证的证据来源。证据来自已读文件，禁止凭空编造。置信度分三级：high（代码/配置直接确认）、medium（文档推断）、low（间接关联）。

### 2. 视角分离

四个视角独立提取，各自输出 `*_knowledge.json`（schema 2.1）中间文件。后续视角可引用前序视角 ID，但不修改前序视角输出。技术视角使用分类 entities 对象，其余三视角使用扁平 entities 数组。

### 3. 按需加载

仅在本轮任务需要时打开文件。如仅提取技术视角，只读主 INDEX 与相关源代码。禁止为「完整性」通读全仓。

### 4. 契约驱动

以本 SKILL 内置配置（table_schema、contains_prefixes、evidence、symmetry）为硬约束。外部 `knowledge_meta.yaml` 存在时可补充但不覆盖。

### 5. 幂等可重试

支持中断后从指定视角继续。已提取视角保留，失败视角标记。更新索引前自动备份。

### 6. 边界清晰

仅负责实体提取和归并到 `*_knowledge.json` + `KNOWLEDGE_INDEX.md`。不生成锚点文档、CHANGELOG 或目录树。

---

## 反模式清单（禁止）

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

### 错误类型与处理方式

| 错误类型 | 处理方式 | 示例 |
|----------|----------|------|
| 主 INDEX 缺失 | 技能终止，提示先运行 document-indexing | Index Guide 未落盘 |
| 证据不足 | 标记 low 置信度，继续执行 | MS-* 无宿主类证据 |
| 前缀冲突 | 跳过冲突项，记录日志 | PL-* 无对应 SYS-* |
| 文件不可写 | 技能终止，提示权限 | KNOWLEDGE_INDEX.md 只读 |
| 输出目录不存在 | 自动创建目录 | knowledge/ 目录缺失 |

### 恢复策略

1. **部分成功**：已提取视角保留，失败视角标记
2. **幂等重试**：支持中断后从指定阶段继续
3. **备份机制**：更新索引前自动备份

---

## 常见问题

**Q: 提取结果不完整**
A: 检查主 Index Guide 是否可用；README.md / AGENTS.md 若缺失可跳过，确认参数配置完整。

**Q: MS-ID 生成不准确**
A: 确认宿主类存在，检查命名规则是否符合提取规则中的约定（SimpleName 去后缀）。

**Q: 跨视角对齐失败**
A: 检查 symmetry 配置，确保 ID 映射规则正确。BC/AGG 联动时须确保证据行存在。

**Q: 如何处理增量提取**
A: 使用 `--skip-existing true` 跳过已处理实体，仅提取新增或变更的实体。

---

## 最佳实践

### 提取优化

- **按需提取**：仅处理必要的视角（`--perspectives` 参数）
- **增量更新**：基于已有 JSON 进行增量更新
- **选择性加载**：仅打开相关的源代码片段

### 质量保证

- **证据链完整**：每个 ID 必有可验证来源
- **命名规范**：严格遵循前缀和命名规则
- **视角对齐**：确保跨视角引用一致（cross_references）
- **富结构完整**：各层级必须填写 full_id、description、parent_id 等 schema 2.1 要求的字段
- **metadata 完整**：每个 `*_knowledge.json` 尾部须包含 metadata（总数统计、提取依据、schema 备注）
