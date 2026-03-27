---
name: knowledge-extract
description: >
  从代码库中结构化提取四视角（技术/数据/业务/产品）链上实体ID，
  生成JSON中间文件并归并到KNOWLEDGE_INDEX.md。
  在用户执行 /knowledge-extract、知识库初始化、代码重构后同步ID、或跨项目对齐实体定义时使用。
---

# 知识实体提取（knowledge-extract）

从工程代码与文档中按四视角（技术→数据→业务→产品）提取链上实体，生成 `*_knowledge.json`（schema 2.1）富结构中间文件并归并到 `knowledge/KNOWLEDGE_INDEX.md`。

## 输入与输出

**输入**：代码库 + 主 Index Guide + 可选 README.md / AGENTS.md
**输出**：四视角 `*_knowledge.json`（schema 2.1）、更新后的 `knowledge/KNOWLEDGE_INDEX.md`

| 类型 | 内容 |
|------|------|
| 硬输入 | 主 Index Guide（必须可用） |
| 可选输入 | README.md、AGENTS.md、PRD 文档、源代码 |
| 固定输出 | `knowledge/{perspective}/{perspective}_knowledge.json`、`knowledge/KNOWLEDGE_INDEX.md` |
| 可选输出 | `knowledge/{perspective}/extraction_report.md`（仅 `--emit-report` 时生成） |
| 不产出 | 锚点文档、CHANGELOG、目录树 |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--perspectives` | 否 | `technical,data,business,product` | 提取视角（逗号分隔） |
| `--doc-root` | 否 | `.` | 文档根目录 |
| `--skip-existing` | 否 | `true` | 是否跳过已处理实体 |
| `--confidence-threshold` | 否 | `medium` | 最低置信度（high/medium/low） |
| `--emit-report` | 否 | `false` | 是否生成提取报告 |

## 工作流（三阶段）

### 阶段 1：初始化

1. 验证文档根目录存在、主 Index Guide 可用、输出目录可写
2. 加载内置配置（表头约定、ID 前缀、证据规则、对称规则）

内置配置详情见 [reference/design-principles.md](reference/design-principles.md)。

### 阶段 2：提取

按固定顺序独立执行四视角提取：**技术 → 数据 → 业务 → 产品**。

| 视角 | 层级 | 主要输入源 | 输出 |
|------|------|-----------|------|
| 技术 | SYS / APP / MS / API | 主 INDEX、源代码、启动类 | `technical_knowledge.json` |
| 数据 | DS / ENT | 主 INDEX、多数据源配置、@Table 实体、MyBatis XML | `data_knowledge.json` |
| 业务 | BD / BSD / BC / AGG / AB | 主 INDEX、包结构 FQCN、技术视角 MS-* | `business_knowledge.json` |
| 产品 | PL / PM / FT / UC | 主 INDEX、README、PRD、技术+业务已提取 ID | `product_knowledge.json` |

各视角的详细提取规则见 [reference/extraction-rules.md](reference/extraction-rules.md)。

### 阶段 3：归并

1. 读取四视角中间 JSON 文件
2. 前缀验证（仅接受内置 `contains_prefixes` 所列前缀）
3. 跨视角对称性检查（遵守内置 `symmetry.rules`）
4. 证据链验证
5. 更新 `knowledge/KNOWLEDGE_INDEX.md`

归并算法与 JSON Schema 见 [reference/consolidation-spec.md](reference/consolidation-spec.md)。输出模板见 [assets/](assets/)。

可使用辅助脚本验证提取结果：

```bash
scripts/validate-extraction.sh --doc-root .
```

## 核心约束

| 约束 | 说明 |
|------|------|
| 证据优先 | 每个实体 ID 必须有可验证的证据来源 |
| 零幻觉 | 只从已读文件提取 ID，禁止编造 |
| 前缀唯一 | 层级+ID、层级+别名 全知识库唯一 |
| 视角对称 | KNOWLEDGE_INDEX §1～§4 同轮维护 |
| 幂等重试 | 支持中断后从指定阶段继续；已提取视角保留，失败视角标记 |
| 边界清晰 | 仅负责 ID 提取和归并，不生成锚点文档或 CHANGELOG |

设计原则与反模式完整版见 [reference/design-principles.md](reference/design-principles.md)。

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游 | `document-indexing` | 生成主 Index Guide |
| 上游（可选） | `agent-guide` | 维护 AGENTS.md 文档 |

### 文件依赖

```
必需文件：
└── {doc_root}/@docs/INDEX_GUIDE.md

可选文件：
├── {doc_root}/README.md
├── {doc_root}/AGENTS.md
├── {doc_root}/knowledge/constitution/standards/NAMING-CONVENTIONS.md
└── {doc_root}/pom.xml（Maven 项目）
```

## 参考

| 资源 | 路径 |
|------|------|
| 内置配置与设计原则 | [reference/design-principles.md](reference/design-principles.md) |
| 四视角提取规则详解 | [reference/extraction-rules.md](reference/extraction-rules.md) |
| 归并算法与 JSON Schema | [reference/consolidation-spec.md](reference/consolidation-spec.md) |
| Knowledge JSON 输出模板 | [assets/knowledge-schema-template.json](assets/knowledge-schema-template.json) |
| KNOWLEDGE_INDEX 输出模板 | [assets/knowledge-index-template.md](assets/knowledge-index-template.md) |
| 提取结果验证脚本 | [scripts/validate-extraction.sh](scripts/validate-extraction.sh) |
| 上游：文档索引 | `.cursor/skills/document-indexing/SKILL.md` |
| 上游：Agent 指引 | `.cursor/skills/agent-guide/SKILL.md` |
