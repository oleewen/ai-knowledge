---
name: docs-change
description: >
  生成可追溯的文档变更索引（changes-index.json + changes-index.md），支持增量模式与审计。
  从 git commit、CHANGELOG 文件、本地文件修改时间三个维度采集变更，按时间阈值过滤后输出结构化双格式产物。
  当用户执行 /docs-change、需要生成变更索引、追踪文档改动、做增量文档更新、或下游 docs-indexing/docs-build 需要变更输入时，务必使用本技能。
  即使用户只说"记录一下最近的改动"、"生成变更日志"、"哪些文件改了"，也应触发本技能。
---

# 文档变更索引（docs-change）

多源融合的文档变更追踪工具：从 Git 提交、CHANGELOG 条目、本地文件修改时间三个维度采集变更，输出机器可读 JSON 与人类可读 Markdown 双格式索引。

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 代码库根目录 |
| 可选输入 | `--since` 时间基准、`--output` 输出目录、已有 `changes-index.json`（增量模式） |
| 固定输出 | `{output_dir}/changes-index.json`、`{output_dir}/changes-index.md` |
| 不产出 | 不生成 INDEX_GUIDE、不修改知识实体、不更新 README/AGENTS |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--since` | 否 | 自动 | 变更起始时间（`yyyy-MM-dd HH:mm:ss.SSS` 或 epoch ms） |
| `--output` | 否 | `./changelogs/` | 输出目录（优先级：用户指定 > `./changelogs/` > 系统知识库根目录下 `./application/changelogs/`） |

时间基准优先级：`--since` 参数 > 已有 JSON 的 `baseline_time` > 默认值 `2020-01-01`。

## 工作流（五步）

### 步骤 1：环境准备

定位输出目录并确认可写；检测 Git 可用性（不可用则跳过 git 来源，不终止流程）；扫描 CHANGELOG 文件。

### 步骤 2：时间基准计算

```
baseline_time = --since 参数 | 已有 JSON.metadata.baseline_time | "2020-01-01 00:00:00.000"
cutoff_time   = max(baseline_time, latest_git_commit_time)   # Git 不可用时 = baseline_time
```

这两个值不同：Git 来源用 `baseline_time` 过滤，CHANGELOG 和本地文件用 `cutoff_time` 过滤。混淆会导致冗余条目，详见 [gotchas.md](gotchas.md)。

### 步骤 3：数据采集

三源并行采集，可使用辅助脚本完成原始数据收集：

```bash
scripts/change-indexing.sh --since "2026-03-20 00:00:00.000" --output ./changelogs/
```

脚本输出原始数据后，由 Agent 解析并生成最终 JSON/MD 产物。各源采集规则与排除列表见 [reference/execution-spec.md](reference/execution-spec.md)。

### 步骤 4：数据处理与输出

1. 三源数据各自标记 `source` 字段（`git` / `changelog` / `local`）
2. 统一时间格式：字符串 `yyyy-MM-dd HH:mm:ss.SSS` + 13 位毫秒戳（`*_ms` 字段）
3. 按 `time_ms` 倒序排列
4. 按模板生成双格式产物（见 [assets/](assets/)）
5. 增量模式：将新变更**追加**到已有 `changes` 数组，更新 `metadata`，不清空历史

### 步骤 5：验证

```bash
jq empty changes-index.json  # JSON 格式有效性
```

完整验证清单见 [reference/execution-spec.md](reference/execution-spec.md)，核心检查项：
- `metadata`、`statistics`、`changes` 三个顶层字段存在
- JSON `statistics.total_changes` == MD 中"总变更数"
- 所有 `changes[].time_ms > metadata.cutoff_time_ms`

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
| 下游 | `docs-indexing` | 消费 `changes-index.json` 驱动增量索引 |
| 下游 | `docs-build` | 基于变更文件列表执行增量提取 |

## 参考

| 资源 | 路径 | 何时读 |
|------|------|--------|
| 执行规范与验证清单 | [reference/execution-spec.md](reference/execution-spec.md) | 采集规则不确定、验证失败时 |
| JSON 输出模板 | [assets/changes-index-template.json](assets/changes-index-template.json) | 生成 JSON 时 |
| Markdown 输出模板 | [assets/changes-index-template.md](assets/changes-index-template.md) | 生成 MD 时 |
| 常见陷阱与防错规则 | [gotchas.md](gotchas.md) | 遇到时间/增量/来源相关问题时 |
| 辅助脚本 | [scripts/change-indexing.sh](scripts/change-indexing.sh) | 执行原始数据采集时 |
