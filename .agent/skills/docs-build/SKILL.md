---
name: docs-build
description: >
  从代码库按四视角（技术→数据→业务→产品）提取链上实体 ID，生成 *_knowledge.json（schema 2.1）；
  按各视角 README 既有版式填充索引表；归并生成系统知识库根目录 application/knowledge/KNOWLEDGE_INDEX.md。
  当用户执行 /docs-build、需要初始化或同步知识库、代码重构后更新实体 ID、
  需要生成四视角知识索引、或下游 docs-indexing 需要知识实体输入时，务必使用本技能。
  即使用户只说"同步一下知识库"、"提取一下实体"、"更新知识索引"，也应触发本技能。
---

# 知识实体提取（docs-build）

**术语**：**系统知识库根目录**指路径前缀 `application/`（与 doc_root 首段一致时）。

从工程代码与文档中按四视角（技术→数据→业务→产品）提取链上实体，生成 `*_knowledge.json`（schema 2.1）；按各视角 `README.md` 既有版式填充索引表；归并更新系统知识库根目录下 `application/knowledge/KNOWLEDGE_INDEX.md`。

> 路径约定：四视角与主索引落在系统知识库根目录 `application/knowledge/`；`{doc_root}` 指定时写入 `{doc_root}/application/knowledge/`。

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 主 Index Guide（必须可用） |
| 可选输入 | README.md、AGENTS.md、PRD 文档、源代码 |
| 固定输出 | 系统知识库根目录下 `application/knowledge/{perspective}/{perspective}_knowledge.json`；各视角 `README.md`（索引表刷新）；`application/knowledge/KNOWLEDGE_INDEX.md` |
| 可选输出 | 系统知识库根目录下 `application/knowledge/{perspective}/extraction_report.md`（仅 `--emit-report` 时） |
| 不产出 | 锚点文档、CHANGELOG、目录树 |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--perspectives` | 否 | `technical,data,business,product` | 提取视角（逗号分隔） |
| `--doc-root` | 否 | `.` | 文档根目录 |
| `--skip-existing` | 否 | `true` | 跳过已处理实体（变更文件涉及的实体仍强制重提取） |
| `--confidence-threshold` | 否 | `medium` | 最低置信度（high/medium/low） |
| `--emit-report` | 否 | `false` | 生成提取报告 |

## 工作流（四阶段）

### 阶段 1：初始化

验证主 Index Guide 可用（不可用则终止，提示先运行 `/docs-indexing`）；验证输出目录可写；加载内置配置（见 [reference/builtin-config.md](reference/builtin-config.md)）。

### 阶段 2：提取

按固定顺序独立执行四视角提取：**技术 → 数据 → 业务 → 产品**。后续视角引用前序视角已提取的 ID，不修改前序输出。

| 视角 | 层级 | 主要输入源 |
|------|------|-----------|
| 技术 | SYS / APP / MS / API | 主 INDEX、源代码、启动类、接口定义 |
| 数据 | DS / ENT | 主 INDEX、多数据源配置、实体类、MyBatis XML |
| 业务 | BD / BSD / BC / AGG / AB | 主 INDEX、包结构 FQCN、技术视角 MS-* |
| 产品 | PL / PM / FT / UC | 主 INDEX、README、PRD、技术+业务已提取 ID |

各视角详细提取规则见 [reference/extraction-rules.md](reference/extraction-rules.md)。

技术视角 API 层级覆盖四类入口：**Dubbo 接口、HTTP 接口、MQ 消息监听、定时任务（Job）**，每条标注 `api_type`。

### 阶段 3：各视角 README 填充

`*_knowledge.json` 生成后，**先读**目标 `README.md` 既有版式（表头、章节标题、静态说明段），**再写**：从 JSON 映射列值，替换示例行或刷新数据行；保留「层级结构」「关键字段」「跨视角映射」等固定段。

列与 JSON 字段对应关系见 [reference/readme-fill-spec.md](reference/readme-fill-spec.md)。

### 阶段 4：归并（KNOWLEDGE_INDEX）

读取四视角 JSON → 前缀验证 → 跨视角对称性检查 → 证据链验证 → 更新系统知识库根目录下 `application/knowledge/KNOWLEDGE_INDEX.md`。

**执行顺序**：阶段 3 完成后再执行本阶段，保证 README、JSON、主索引三者一致。

归并算法与验证规则见 [reference/consolidation-spec.md](reference/consolidation-spec.md)。

验证：

```bash
scripts/validate-extraction.sh --doc-root .
```

完整质量清单见 [reference/quality-checklist.md](reference/quality-checklist.md)。

## 核心约束

| 约束 | 说明 |
|------|------|
| 证据优先 | 每个实体 ID 必须有可验证的证据来源 |
| 零幻觉 | 只从已读文件提取 ID，禁止编造 |
| 前缀唯一 | 层级+ID、层级+别名全知识库唯一 |
| 视角对称 | `KNOWLEDGE_INDEX.md` §1～§4 同轮维护；各视角 README 与 JSON 同源 |
| 幂等重试 | 支持中断后从指定阶段继续；已提取视角保留，失败视角标记 |
| API 四类覆盖 | Dubbo、HTTP、MQ Consumer、Job 四类入口全覆盖，每条标注 `api_type` |
| 边界清晰 | 负责 ID 提取、README 索引表更新与主索引归并；不生成锚点文档或 CHANGELOG |

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游 | `docs-indexing` | 生成主 Index Guide |
| 上游（可选） | `agent-guide` | 维护 AGENTS.md |

## 参考

| 资源 | 路径 | 何时读 |
|------|------|--------|
| 内置配置、设计原则、错误处理 | [reference/builtin-config.md](reference/builtin-config.md) | 初始化阶段、遇到配置/错误处理问题时 |
| 四视角提取规则 | [reference/extraction-rules.md](reference/extraction-rules.md) | 阶段 2 提取时，规则不确定时 |
| 各视角 README 填充（列映射） | [reference/readme-fill-spec.md](reference/readme-fill-spec.md) | 阶段 3 填充 README 时 |
| 归并算法与验证规则 | [reference/consolidation-spec.md](reference/consolidation-spec.md) | 阶段 4 归并时 |
| 质量验证清单 | [reference/quality-checklist.md](reference/quality-checklist.md) | 阶段 4 完成后自查时 |
| Knowledge JSON 输出模板 | [assets/knowledge-schema-template.json](assets/knowledge-schema-template.json) | 生成 JSON 时 |
| KNOWLEDGE_INDEX 输出模板 | [assets/knowledge-index-template.md](assets/knowledge-index-template.md) | 生成主索引时 |
| 常见陷阱与防错 | [gotchas.md](gotchas.md) | 遇到视角顺序、ID 生成、API 覆盖相关问题时 |
| 提取结果验证脚本 | [scripts/validate-extraction.sh](scripts/validate-extraction.sh) | 阶段 4 自动验证时 |
