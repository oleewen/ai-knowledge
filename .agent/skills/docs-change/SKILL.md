---
name: docs-change
description: >
  生成可追溯的文档变更聚合，落盘为 Markdown：`CHANGE-LOG.md`（文末 HTML 注释承载增量基线）。
  从 git commit、CHANGELOG/CHANGE-LOG、本地文件修改时间三个维度采集变更，按时间阈值过滤后写入同一日志文件。
  当用户执行 /docs-change、需要生成变更索引、追踪文档改动、做增量文档更新、或下游 docs-indexing/docs-build 需要变更输入时，务必使用本技能。
  即使用户只说"记录一下最近的改动"、"生成变更日志"、"哪些文件改了"，也应触发本技能。
---

# 文档变更索引（docs-change）

多源融合的文档变更追踪：从 Git 提交、`CHANGELOG*` / `CHANGE-LOG.md` 条目、本地文件修改时间三个维度采集变更，**以 Markdown 为主产物**写入 `{output_dir}/CHANGE-LOG.md`，并在文末保留 `<!-- docs-change:baseline_time_ms=... -->` 供下次增量采集。

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 代码库根目录 |
| 可选输入 | `--since` 时间基准、`--output` 输出目录；增量基线取自已有 `CHANGE-LOG.md` 文末注释（见 [scripts/change-indexing.sh](scripts/change-indexing.sh)） |
| 固定输出 | `{output_dir}/CHANGE-LOG.md`（Markdown；人类可读 + 文末基线注释） |
| 不产出 | 不生成 INDEX_GUIDE、不修改知识实体、不更新 README/AGENTS |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--since` | 否 | 自动 | 变更起始时间（`yyyy-MM-dd HH:mm:ss.SSS` 或 epoch ms） |
| `--output` | 否 | `./changelogs/` | 输出目录（优先级：用户指定 > `./changelogs/` > 应用知识库下 `./{DOC_DIR}/changelogs/`） |

时间基准优先级：`--since` 参数 > `CHANGE-LOG.md` 文末 `baseline_time_ms` > 默认值 `2020-01-01`。

## 工作流（五步）

### 步骤 1：环境准备

定位输出目录并确认可写；检测 Git 可用性（不可用则跳过 git 来源，不终止流程）；扫描 `CHANGELOG*` / `CHANGE-LOG.md` / `changes*` 文件。

### 步骤 2：时间基准计算

```
baseline_time = --since 参数 | CHANGE-LOG.md 文末注释 | "2020-01-01 00:00:00.000"
cutoff_time   = max(baseline_time, latest_git_commit_time)   # Git 不可用时 = baseline_time
```

这两个值不同：Git 来源用 `baseline_time` 过滤，CHANGELOG 和本地文件用 `cutoff_time` 过滤。混淆会导致冗余条目，详见 [gotchas.md](gotchas.md)。

### 步骤 3：数据采集

三源并行采集，可使用辅助脚本完成原始数据收集：

```bash
scripts/change-indexing.sh --since "2026-03-20 00:00:00.000" --output ./changelogs/
```

脚本输出原始数据后，由 Agent 解析并**整理写入 `CHANGE-LOG.md`**（可用表格、分级标题）。各源采集规则与排除列表见 [reference/execution-spec.md](reference/execution-spec.md)。

### 步骤 4：数据处理与输出

1. 三源数据各自标记 `source` 字段（`git` / `changelog` / `local`）
2. 统一时间格式：字符串 `yyyy-MM-dd HH:mm:ss.SSS` + 13 位毫秒戳（`*_ms` 字段）
3. 按 `time_ms` 倒序排列
4. 将本轮摘要与条目写入 `CHANGE-LOG.md`（结构可参考 [assets/changes-index-template.md](assets/changes-index-template.md)，不必再生成独立 `changes-index.*`）
5. 增量模式：**追加**新条目，更新文末 `<!-- docs-change:baseline_time_ms=... -->`，勿删除历史小节

### 步骤 5：验证

- `CHANGE-LOG.md` 存在且为有效 Markdown
- 文末基线注释与本轮最新 `baseline_time_ms` 一致

完整验证清单见 [reference/execution-spec.md](reference/execution-spec.md)。

## 核心约束

| 约束 | 说明 |
|------|------|
| 零幻觉 | 只收录实际可验证的变更数据 |
| 时间精确 | 统一 ms 精度；基线写入 HTML 注释便于脚本解析 |
| 增量一致性 | 同一文件内追加历史，不覆盖既有条目语义 |
| 幂等性 | 相同输入与基线下结果一致 |
| 优雅降级 | Git/CHANGELOG 不可用时跳过对应来源，不终止流程 |

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 下游 | `docs-indexing` | 增量索引前宜完成本轮聚合；扫描范围由变更列表驱动 |
| 下游 | `docs-build` | 基于变更文件列表执行增量提取 |

## 参考

| 资源 | 路径 | 何时读 |
|------|------|--------|
| 执行规范与验证清单 | [reference/execution-spec.md](reference/execution-spec.md) | 采集规则不确定、验证失败时 |
| 结构参考（可选） | [assets/changes-index-template.md](assets/changes-index-template.md) | 组织 CHANGE-LOG 章节时 |
| 常见陷阱与防错规则 | [gotchas.md](gotchas.md) | 遇到时间/增量/来源相关问题时 |
| 辅助脚本 | [scripts/change-indexing.sh](scripts/change-indexing.sh) | 执行原始数据采集时 |
