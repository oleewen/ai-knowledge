---
name: document-indexing
description: >
  为代码库生成结构化文档索引（INDEX_GUIDE.md），支持全量/增量扫描与三级深度（拓扑/结构/精读）。
  产出标准化九章文档索引，为 Agent 导航与 RAG 上下文提供权威文档地图。
  在用户执行 /document-indexing、需要生成或更新项目索引文档、或进行项目 Onboarding 时使用。
---

# 文档索引生成器（document-indexing）

将代码库解析为结构化、可检索的文档索引 INDEX_GUIDE.md，作为 Agent 与开发者的系统全景导航。

## 输入与输出

**输入**：扫描模式 + 扫描深度 + 代码库
**输出**：`{Doc Root}/INDEX_GUIDE.md`（九章结构）、`changelogs/indexing-log.jsonl`（操作日志）

| 类型 | 内容 |
|------|------|
| 硬输入 | 代码库根目录、扫描模式（full/incremental）、扫描深度（1/2/3） |
| 可选输入 | 输出路径、增量起始时间、`changes-index.json`（增量模式） |
| 固定输出 | `{Doc Root}/INDEX_GUIDE.md`、`changelogs/indexing-log.jsonl` |
| 不产出 | 不生成知识实体 ID、不修改 README/AGENTS、不产出 CHANGELOG |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--mode` | 是 | - | `f`/`full`（全量）或 `i`/`incremental`（增量） |
| `--depth` | 是 | - | `1`（拓扑）、`2`（结构）、`3`（精读） |
| `--output` | 否 | `./system/INDEX_GUIDE.md` | 输出路径 |
| `--since` | 否 | 自动 | 增量起始时间（epoch ms，自动从日志获取） |

深度级别与模式的详细定义见 [reference/scan-spec.md](reference/scan-spec.md)。

## 工作流（六步）

### 步骤 1：环境准备

- 读取历史日志 `changelogs/indexing-log.jsonl`
- 无历史记录时强制 full 模式
- 验证输出路径可写

### 步骤 2：扫描配置

- 获取用户确认：mode + depth
- 增量模式下从 `indexing-log.jsonl` 读取基线时间戳

### 步骤 3：变更分析

- 调用 `document-change` 技能生成变更索引
- 解析变更文件列表，建立扫描路径集
- 全量模式下跳过变更过滤

### 步骤 4：执行扫描

按深度级别扫描代码库。扫描规则（文件过滤、深度控制、路径解析）见 [reference/scan-spec.md](reference/scan-spec.md)。可使用辅助脚本：

```bash
scripts/indexing.sh --mode full --depth 3
```

### 步骤 5：质量验证

按 [reference/quality-standards.md](reference/quality-standards.md) 执行验证：结构完整性、信息密度、准确度、交叉引用。

### 步骤 6：输出生成

- 按九章规范（详见 [reference/nine-chapter-spec.md](reference/nine-chapter-spec.md)）生成文档
- 输出模板骨架参见 [assets/index-guide-template.md](assets/index-guide-template.md)
- 追加日志到 `changelogs/indexing-log.jsonl`（日志格式见 [reference/scan-spec.md](reference/scan-spec.md)）
- 清理临时文件

## 核心约束

| 约束 | 说明 |
|------|------|
| 零幻觉 | 只索引实际读取的内容，禁止臆测 |
| 路径精确 | 使用项目根相对路径 |
| 幂等性 | 相同输入产出一致结果 |
| 增量一致性 | 增量索引保持与全量索引结构一致 |
| MECE 原则 | 分类互斥穷尽，避免重复索引 |
| 版本追溯 | 每次索引记录完整元数据到日志 |

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 前置 | `document-change` | 生成变更索引 `changes-index.json` |
| 下游 | `knowledge-extract` | 以主 INDEX 作为提取证据来源 |
| 关联 | `agent-guide` | 维护 README.md / AGENTS.md 与 INDEX 交叉引用 |

## 参考

| 资源 | 路径 |
|------|------|
| 扫描执行规范（深度/模式/过滤/日志/错误处理） | [reference/scan-spec.md](reference/scan-spec.md) |
| 九章文档结构规范 | [reference/nine-chapter-spec.md](reference/nine-chapter-spec.md) |
| 质量验证清单 | [reference/quality-standards.md](reference/quality-standards.md) |
| INDEX_GUIDE 输出模板 | [assets/index-guide-template.md](assets/index-guide-template.md) |
| 常见陷阱与防错规则 | [gotchas.md](gotchas.md) |
| 辅助脚本 | [scripts/indexing.sh](scripts/indexing.sh) |
