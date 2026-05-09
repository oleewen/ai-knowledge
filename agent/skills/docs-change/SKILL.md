---
name: docs-change
description: >
  从 Git、`CHANGELOG*`、本地修改时间三源采集变更，写入 `{output_dir}/CHANGE-LOG.md`，文末以 `<!-- docs-change:baseline_time_ms=... -->` 保留增量基线。
  `/docs-change`、生成或更新变更聚合、下游索引/实体需变更输入，或用户说「记录改动」「变更日志」「最近改了什么」时触发。
  用户明确要求仅 `docs-indexing`、`docs-build`、`docs-archive`、`docs-upgrade` 为主路径时，分流至对应技能。
---

# docs-change：变更聚合

调度器：先判定是否由本技能处理，再按 `references/` 多源采集并更新 `CHANGE-LOG.md`，供下游读基线做增量。

## 边界

| 负责 | 不负责 |
|------|--------|
| `CHANGE-LOG.md` 多源聚合、时间统一、倒序插入、文末基线 | `INDEX_GUIDE`、`KNOWLEDGE_INDEX`、overview 归档、全库术语替换 |
| | 对应 **docs-indexing**、**docs-build**、**docs-archive**、**docs-upgrade** |

仅要文档地图时以 **docs-indexing** 为主；变更列表与索引协作，不互相替代。

## 输入与输出

| 项 | 说明 |
|----|------|
| 硬输入 | 仓库根目录 |
| 可选 | `--since`、`--output`；基线读已有文末注释 |
| 输出 | `{output_dir}/CHANGE-LOG.md`（Markdown + 文末基线） |
| 不产出 | INDEX_GUIDE、知识实体、`README`/`AGENTS` 批量改写 |

**参数**

| 参数 | 必需 | 默认 | 说明 |
|------|------|------|------|
| `--since` | 否 | 见下 | `yyyy-MM-dd HH:mm:ss.SSS` 或 epoch ms |
| `--output` | 否 | `./changelogs/` | 优先级：用户指定 > `./changelogs/` > `./{DOC_DIR}/changelogs/` |

时间：`--since` > 文末 `baseline_time_ms` > `2020-01-01`。

## 前置确认

时间基准不清、输出目录多解、或用户声明**仅采某一来源**时先确认；否则按 [references/gates.md](references/gates.md)、[references/workflow.md](references/workflow.md) 执行。细则见 gates「前置确认与歧义处理」。

## 执行顺序（先读后写）

1. [gates.md](references/gates.md) — 边界与歧义
2. [workflow.md](references/workflow.md) — 五步与脚本
3. [collection-rules.md](references/collection-rules.md) — 输出目录与三源
4. [core-concepts.md](references/core-concepts.md) — baseline / cutoff（不确定时）
5. [design-principles.md](references/design-principles.md) — 对齐粒度
6. [anti-patterns.md](references/anti-patterns.md) — 收敛方案前
7. [quality-checklist.md](references/quality-checklist.md) — 落盘验证
8. [gotchas.md](gotchas.md) — 时间/增量/来源陷阱
9. [references/README.md](references/README.md) — 全目录索引
10. [assets/changes-index-template.md](assets/changes-index-template.md) — CHANGE-LOG 结构（JSON 模板按需）

## 门禁

无 SDD 式 HTML gate；**有歧义须确认**。禁止宣称本流程已更新 INDEX_GUIDE 或知识实体。

## 校验

结构见 `assets/changes-index-template.md`；核对 [quality-checklist.md](references/quality-checklist.md)，时间/排除目录见 gotchas。

## 评测

- 样本：[evals/evals.json](evals/evals.json)
- 元模板：[evals/eval-metadata-template.json](evals/eval-metadata-template.json)
- 评分：[agents/grader.md](agents/grader.md)
- 失败分析：[agents/analyzer.md](agents/analyzer.md)

## 脚本

[scripts/change-indexing.sh](scripts/change-indexing.sh) 写原始数据至 `{output_dir}/.raw/`。本仓库未注册 `docs-change` 的 `preToolUse` 钩子。

## 下游

| 技能 | 关系 |
|------|------|
| docs-indexing | 可消费本轮 `CHANGE-LOG.md` |
| docs-build | 可按变更列表做增量提取 |

## 五步索引

| 步 | 摘要 | 详见 |
|----|------|------|
| 1 | 环境、Git、候选文件、歧义 | workflow |
| 2 | 时间基准 | workflow + core-concepts |
| 3 | 三源采集（可跑脚本） | workflow + collection-rules |
| 4 | 合并、排序、写入、更新基线 | workflow |
| 5 | 验证 | quality-checklist |
