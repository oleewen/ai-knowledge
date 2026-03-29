---
name: document-change
description: >
  生成可追溯的文档变更索引，支持增量索引与审计。从 git commit、CHANGELOG 文件和文件修改时间三个维度收集变更信息，
  按时间阈值过滤后输出结构化 JSON 和可读 Markdown 两种格式。
  在用户执行 /document-change、需要生成变更索引、或进行增量文档更新时使用。
---

# 文档变更索引（document-change）

多源融合的文档变更追踪工具，从 Git 提交、CHANGELOG 条目、本地文件修改时间三个维度采集变更，输出机器可读 JSON 与人类可读 Markdown 双格式索引。

## 输入与输出

**输入**：时间基准 + 输出目录 + 代码库
**输出**：`{output_dir}/changes-index.json`（结构化数据）、`{output_dir}/changes-index.md`（可读摘要）

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--since` | 否 | 自动 | 变更起始时间（`yyyy-MM-dd HH:mm:ss.SSS` 或 epoch ms） |
| `--output` | 否 | `./changelogs/` | 输出目录（优先级：用户指定 > `./changelogs/` > `./docs/changelogs/`） |

### 时间基准优先级

1. 命令行 `--since` 参数
2. 已有 `changes-index.json` 中的 `baseline_time`
3. 默认值 `2020-01-01 00:00:00.000`

## 工作流（五步）

### 步骤 1：环境准备

- 定位输出目录，确认可写
- Git 可用性检测（不可用则跳过 git 来源）
- CHANGELOG 文件扫描

### 步骤 2：时间基准计算

- 读取或计算 `baseline_time`、`cutoff_time`
- `cutoff_time = max(baseline_time, latest_git_commit_time)`

### 步骤 3：数据采集

三源并行采集，各自按时间阈值过滤：

| 来源 | 过滤规则 | 采集内容 |
|------|----------|----------|
| Git 提交 | `commit_time > baseline_time` | hash、作者、信息、变更文件列表 |
| CHANGELOG | `entry_time > cutoff_time` | 版本号、日期、条目内容 |
| 本地文件 | `mtime > cutoff_time` | 文件路径、修改时间 |

可使用辅助脚本：

```bash
scripts/change-indexing.sh --since "2026-03-20 00:00:00.000" --output ./changelogs/
```

### 步骤 4：数据处理与输出

- 合并三源数据，统一时间格式（`yyyy-MM-dd HH:mm:ss.SSS` + 13 位 ms）
- 按时间倒序排列
- 按模板生成 JSON 和 Markdown（见 [.ai/skills/document-change/assets/](assets)）

### 步骤 5：验证

按 [.ai/skills/document-change/reference/execution-spec.md](reference/execution-spec.md) 中的验证清单执行：

- 文件存在性、JSON 格式有效性
- 必需字段完整性
- 时间一致性（所有变更 > cutoff_time）
- JSON 与 MD 统计数一致

## 核心约束

| 约束 | 说明 |
|------|------|
| 零幻觉 | 只收录实际可验证的变更数据 |
| 时间精确 | 统一 ms 精度，双格式（字符串 + 毫秒戳）|
| 增量一致性 | 增量产物与全量产物结构一致 |
| 幂等性 | 相同输入产出一致结果 |
| 优雅降级 | Git/CHANGELOG 不可用时跳过对应来源，不终止流程 |

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 下游 | `document-indexing` | 消费 `changes-index.json` 驱动增量索引 |
| 下游 | `knowledge-extract` | 基于变更文件列表执行增量提取 |

## 参考

| 资源 | 路径 |
|------|------|
| 执行规范与验证清单 | [.ai/skills/document-change/reference/execution-spec.md](reference/execution-spec.md) |
| JSON 输出模板 | [.ai/skills/document-change/assets/changes-index-template.json](assets/changes-index-template.json) |
| Markdown 输出模板 | [.ai/skills/document-change/assets/changes-index-template.md](assets/changes-index-template.md) |
| 辅助脚本 | [.ai/skills/document-change/scripts/change-indexing.sh](scripts/change-indexing.sh) |
