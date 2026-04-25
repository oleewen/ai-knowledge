---
name: docs-build
description: >
  从工程代码与文档中按四视角（技术→数据→业务→产品）提取链上实体 ID，生成 *_knowledge.json（schema 2.1），
  刷新各视角 README 索引表，归并更新 {DOC_DIR}/knowledge/KNOWLEDGE_INDEX.md。
  只要用户提到以下任意场景，就应立即使用本技能，不要等用户明确说"/docs-build"：
  初始化知识库、同步知识库、提取实体、更新知识索引、代码重构后对齐实体 ID、
  补全四视角知识资产、下游 docs-indexing 需要知识实体输入、
  "帮我把代码里的实体整理一下"、"知识库和代码对不上了"、"更新一下 KNOWLEDGE_INDEX"。
---

# 知识实体提取（docs-build）

**术语**：**应用知识库**指 `DOC_DIR`（见 `.docsconfig`）对应的目录，路径前缀 `{DOC_DIR}/`。

## 快速定向

| 需要做什么 | 去读 | 何时打开 |
|-----------|------|---------|
| 工作流职责、输入输出、参数 | 本文件（继续往下读） | 每次执行前 |
| 内置配置、设计原则、错误处理 | [reference/builtin-config.md](reference/builtin-config.md) | 初始化阶段；遇到配置或错误处理问题时 |
| 四视角提取规则（含 TOC） | [reference/extraction-rules.md](reference/extraction-rules.md) | 阶段 2 提取时；规则不确定时 |
| 各视角 README 填充列映射 | [reference/readme-fill-spec.md](reference/readme-fill-spec.md) | 阶段 3 填充 README 时 |
| 归并算法与验证规则 | [reference/consolidation-spec.md](reference/consolidation-spec.md) | 阶段 4 归并时 |
| 质量验证清单 | [reference/quality-checklist.md](reference/quality-checklist.md) | 阶段 4 完成后自查时 |
| Knowledge JSON 输出模板 | [assets/knowledge-schema-template.json](assets/knowledge-schema-template.json) | 生成 JSON 时 |
| KNOWLEDGE_INDEX 输出模板 | [assets/knowledge-index-template.md](assets/knowledge-index-template.md) | 生成主索引时 |
| 常见陷阱与防错 | [gotchas.md](gotchas.md) | 遇到视角顺序、ID 生成、API 覆盖相关问题时 |
| 提取结果验证脚本 | [scripts/validate-extraction.sh](scripts/validate-extraction.sh) | 阶段 4 自动验证时 |

## 与相近技能的分工

| 场景 | 优先技能 |
|------|----------|
| 生成或更新根目录 `INDEX_GUIDE.md` | `docs-indexing` |
| 从代码与四视角链提取实体 ID、刷新 `KNOWLEDGE_INDEX` | **本技能** |
| 将 overview 知识归档到架构视角表各章节 | `docs-archive` |
| 将应用知识蒸馏上行到系统库 | `docs-distill` |
| 从任意文件按关键词提炼业务知识写入 overview | `docs-extract` |

---

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 主 Index Guide（必须可用，否则终止并提示先运行 `/docs-indexing`） |
| 可选输入 | README.md、AGENTS.md、PRD 文档、源代码 |
| 固定输出 | `{DOC_DIR}/knowledge/{perspective}/{perspective}_knowledge.json`；各视角 `README.md`（索引表刷新）；`{DOC_DIR}/knowledge/KNOWLEDGE_INDEX.md` |
| 可选输出 | `{DOC_DIR}/knowledge/{perspective}/extraction_report.md`（仅 `--emit-report` 时） |
| 不产出 | 锚点文档、CHANGELOG、目录树 |

## 参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--perspectives` | `technical,data,business,product` | 提取视角（逗号分隔） |
| `--skip-existing` | `true` | 跳过已处理实体；变更文件涉及的实体仍强制重提取 |
| `--confidence-threshold` | `medium` | 最低置信度（high/medium/low） |
| `--emit-report` | `false` | 生成提取报告 |

---

## 工作流（四阶段）

**预检策略**：直接采用默认参数，不逐项追问。仅在以下情况才暂停澄清（一次只问一个点）：用户显式指定参数或视角子集；`DOC_DIR` 路径有歧义；校验失败需选择处理方式；遇到 `extraction-rules.md` 未覆盖的边界。

| 阶段 | 名称 | 摘要 | 详见 |
|------|------|------|------|
| 1 | 初始化 | 验证主 Index Guide 可用；验证输出目录可写；加载内置配置 | [reference/builtin-config.md](reference/builtin-config.md) |
| 2 | 提取 | 按固定顺序独立执行四视角；后续视角引用前序 ID，不修改前序输出 | [reference/extraction-rules.md](reference/extraction-rules.md) |
| 3 | README 填充 | 先读目标 README 既有版式，再从 JSON 映射列值刷新数据行；保留固定段 | [reference/readme-fill-spec.md](reference/readme-fill-spec.md) |
| 4 | 归并 | 读取四视角 JSON → 前缀验证 → 对称性检查 → 证据链验证 → 更新 KNOWLEDGE_INDEX；运行验证脚本 | [reference/consolidation-spec.md](reference/consolidation-spec.md) |

### 阶段 2 视角提取顺序

按固定顺序独立执行，后续视角引用前序 ID，不修改前序输出：

| 顺序 | 视角 | 层级 | 主要输入源 |
|------|------|------|-----------|
| 1 | 技术 | SYS / APP / MS / API | 主 INDEX、源代码、启动类、接口定义 |
| 2 | 数据 | DS / ENT | 主 INDEX、多数据源配置、实体类、MyBatis XML |
| 3 | 业务 | BD / BSD / BC / AGG / AB | 主 INDEX、包结构 FQCN、技术视角 MS-* |
| 4 | 产品 | PL / PM / FT / UC | 主 INDEX、README、PRD、技术+业务已提取 ID |

API 层级须覆盖四类入口：Dubbo、HTTP、MQ Consumer、Job，每条标注 `api_type`。

### 阶段 4 验证命令

```bash
scripts/validate-extraction.sh
```

---

## 命令示例

```bash
/docs-build
/docs-build --perspectives technical,data
/docs-build --skip-existing false
/docs-build --confidence-threshold high --emit-report
```

---

## 核心约束

| 约束 | 说明 |
|------|------|
| 证据优先 | 每个实体 ID 必须有可验证的证据来源 |
| 零幻觉 | 只从已读文件提取 ID，禁止编造 |
| 前缀唯一 | 层级+ID、层级+别名全知识库唯一 |
| 视角对称 | `KNOWLEDGE_INDEX.md` §1～§4 同轮维护；各视角 README 与 JSON 同源 |
| 幂等可重试 | 支持中断后从指定阶段继续；已提取视角保留，失败视角标记 |
| API 四类覆盖 | Dubbo、HTTP、MQ Consumer、Job 全覆盖，每条标注 `api_type` |
| 边界清晰 | 只负责提取、README 刷新与主索引归并；不生成锚点文档或 CHANGELOG |

---

## 依赖关系

| 类型 | 技能 | 说明 |
|------|------|------|
| 必须上游 | `docs-indexing` | 生成主 Index Guide |
| 可选上游 | `agent-guide` | 维护 AGENTS.md |
| 可选下游 | `docs-distill` | 将提取结果蒸馏上行到系统库 |
| 可选下游 | `docs-archive` | 将知识归档到架构视角表 |
