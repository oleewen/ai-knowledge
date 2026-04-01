---
name: knowledge-build
description: >
  从代码库中按四视角（技术/数据/业务/产品）提取链上实体 ID，
  生成 *_knowledge.json（schema 2.1）；再按各视角 README 既有版式填充 README.md，
  最后归并生成 system/knowledge/KNOWLEDGE_INDEX.md。
  在用户执行 /knowledge-build、知识库初始化、代码重构后同步 ID 时使用。
---

# 知识实体提取（knowledge-build）

从工程代码与文档中按四视角（技术→数据→业务→产品）提取链上实体，生成 `*_knowledge.json`（schema 2.1）；**随后**按各视角目录下 **现有 `README.md` 的表格与章节结构**，用 JSON 实体行替换索引表；**最后**归并更新 `system/knowledge/KNOWLEDGE_INDEX.md`。技术视角 API 层级统一覆盖四类入口：**Dubbo 接口、HTTP 接口、MQ 消息监听、定时任务（Job）**。

> **路径约定**：本仓库应用知识库根为 `system/knowledge/`（与 `system/knowledge/README.md` 一致）；`{doc_root}` 为文档根时，输出写在 `{doc_root}/system/knowledge/`。

## 输入与输出

**输入**：代码库 + 主 Index Guide + 可选 README.md / AGENTS.md  
**输出**：四视角 `*_knowledge.json`（schema 2.1）、各视角更新后的 `README.md`、`system/knowledge/KNOWLEDGE_INDEX.md`

| 类型 | 内容 |
|------|------|
| 硬输入 | 主 Index Guide（必须可用） |
| 可选输入 | README.md、AGENTS.md、PRD 文档、源代码 |
| 固定输出 | `system/knowledge/{perspective}/{perspective}_knowledge.json`；`system/knowledge/{perspective}/README.md`（按该视角既有格式填充索引表）；`system/knowledge/KNOWLEDGE_INDEX.md` |
| 可选输出 | `system/knowledge/{perspective}/extraction_report.md`（仅 `--emit-report` 时） |
| 不产出 | 锚点文档、CHANGELOG、目录树 |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--perspectives` | 否 | `technical,data,business,product` | 提取视角（逗号分隔） |
| `--doc-root` | 否 | `.` | 文档根目录 |
| `--skip-existing` | 否 | `true` | 跳过已处理实体 |
| `--confidence-threshold` | 否 | `medium` | 最低置信度（high/medium/low） |
| `--emit-report` | 否 | `false` | 生成提取报告 |

## 工作流（四阶段）

### 阶段 1：初始化

- 验证主 Index Guide 可用（不可用则终止，提示先运行 `/document-indexing`）
- 验证输出目录可写（含 `system/knowledge/` 及各视角子目录）
- 加载内置配置（见 [reference/builtin-config.md](reference/builtin-config.md)）

### 阶段 2：提取

按固定顺序独立执行四视角提取：**技术 → 数据 → 业务 → 产品**。后续视角引用前序视角已提取的 ID，不修改前序输出。

| 视角 | 层级 | 主要输入源 |
|------|------|-----------|
| 技术 | SYS / APP / MS / API | 主 INDEX、源代码、启动类、接口定义 |
| 数据 | DS / ENT | 主 INDEX、多数据源配置、实体类、MyBatis XML |
| 业务 | BD / BSD / BC / AGG / AB | 主 INDEX、包结构 FQCN、技术视角 MS-* |
| 产品 | PL / PM / FT / UC | 主 INDEX、README、PRD、技术+业务已提取 ID |

各视角的详细提取规则见 [reference/extraction-rules.md](reference/extraction-rules.md)。

### 阶段 3：各视角 README 填充

在对应视角的 `*_knowledge.json` 已生成后，**按该视角 `README.md` 既有版式**（表头、章节标题、静态说明段）更新「索引表」数据行：

- **先读** 目标文件：`system/knowledge/technical/README.md`、`data/README.md`、`business/README.md`、`product/README.md`，不臆造表结构。
- **再写**：从同名 `*_knowledge.json` 映射列值，替换示例行或刷新已有数据行；保留「层级结构」「关键字段」「与其他视角的映射」等固定段。
- 列与 JSON 字段对应关系、顺序约束见 [reference/readme-fill-spec.md](reference/readme-fill-spec.md)。

### 阶段 4：归并（KNOWLEDGE_INDEX）

1. 读取四视角中间 JSON → 前缀验证 → 跨视角对称性检查 → 证据链验证 → 更新 `system/knowledge/KNOWLEDGE_INDEX.md`（对齐 [assets/knowledge-index-template.md](assets/knowledge-index-template.md) 与各节表头规范）。

归并算法与验证规则见 [reference/consolidation-spec.md](reference/consolidation-spec.md)。**执行顺序**：阶段 3（README）完成后再执行本阶段，保证 README、JSON、主索引一致。

按 [reference/quality-checklist.md](reference/quality-checklist.md) 执行质量自查。可用辅助脚本验证：

```bash
scripts/validate-extraction.sh --doc-root .
```

## 核心约束

| 约束 | 说明 |
|------|------|
| 证据优先 | 每个实体 ID 必须有可验证的证据来源 |
| 零幻觉 | 只从已读文件提取 ID，禁止编造 |
| 前缀唯一 | 层级+ID、层级+别名全知识库唯一 |
| 视角对称 | `KNOWLEDGE_INDEX.md` §1～§4 同轮维护；各视角 README 索引表与 JSON 同源 |
| 幂等重试 | 支持中断后从指定阶段继续；已提取视角保留，失败视角标记 |
| API 四类覆盖 | Dubbo、HTTP、MQ Consumer、Job 四类入口全覆盖，每条标注 `api_type` |
| 边界清晰 | 负责 ID 提取、各视角 README 索引表更新与主索引归并；不生成锚点文档或 CHANGELOG |

设计原则、内置配置与错误处理见 [reference/builtin-config.md](reference/builtin-config.md)。

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游 | `document-indexing` | 生成主 Index Guide |
| 上游（可选） | `agent-guide` | 维护 AGENTS.md 文档 |

### 文件依赖

```
必需文件：
└── {doc_root}/INDEX_GUIDE.md（或 {doc_root}/system/INDEX_GUIDE.md）

写入前建议已存在（作为 README 版式参考）：
├── {doc_root}/system/knowledge/technical/README.md
├── {doc_root}/system/knowledge/data/README.md
├── {doc_root}/system/knowledge/business/README.md
└── {doc_root}/system/knowledge/product/README.md

可选文件：
├── {doc_root}/README.md
├── {doc_root}/AGENTS.md
├── {doc_root}/system/knowledge/constitution/standards/naming-conventions.md
└── {doc_root}/pom.xml（Maven 项目）
```

## 参考

| 资源 | 路径 |
|------|------|
| 内置配置与设计原则 | [reference/builtin-config.md](reference/builtin-config.md) |
| 四视角提取规则 | [reference/extraction-rules.md](reference/extraction-rules.md) |
| 各视角 README 填充（列映射与顺序） | [reference/readme-fill-spec.md](reference/readme-fill-spec.md) |
| 归并算法与验证规则 | [reference/consolidation-spec.md](reference/consolidation-spec.md) |
| 质量验证清单 | [reference/quality-checklist.md](reference/quality-checklist.md) |
| Knowledge JSON 输出模板 | [assets/knowledge-schema-template.json](assets/knowledge-schema-template.json) |
| KNOWLEDGE_INDEX 输出模板 | [assets/knowledge-index-template.md](assets/knowledge-index-template.md) |
| 常见陷阱与防错 | [gotchas.md](gotchas.md) |
| 提取结果验证脚本 | [scripts/validate-extraction.sh](scripts/validate-extraction.sh) |
| 上游：文档索引 | `.ai/skills/docs-indexing/SKILL.md` |
| 上游：Agent 指引 | `.ai/skills/agent-guide/SKILL.md` |
