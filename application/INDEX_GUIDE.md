# ai-knowledge 索引指南

> 最后更新：2026-04-05T10:56:57Z
> 文档定位：由 docs-indexing 自动生成的九章索引（mode=full, depth=3）

## 一、项目概览（Project Overview）

- 项目名称：`ai-knowledge`
- 扫描模式：`full`
- 扫描深度：`3`
- 索引文件总数：`166`
- 输出路径：`./application/INDEX_GUIDE.md`

## 二、架构视图（Architecture View）

### 2.1 顶层目录

- `./applications`
- `./scripts`
- `./system`

### 2.2 主要文件（样本）

- `./.agent/README.md`
- `./.agent/rules/CONVENTIONS.md`
- `./.agent/rules/coding/git-guidelines.md`
- `./.agent/rules/coding/java-guidelines.md`
- `./.agent/rules/coding/maven-guidelines.md`
- `./.agent/rules/coding/project-structure.md`
- `./.agent/rules/design/design-guidelines.md`
- `./.agent/rules/document/document-guidelines.md`
- `./.agent/rules/testing/testing-guidelines.md`
- `./.agent/skills/README.md`
- `./.agent/skills/agent-guide/SKILL.md`
- `./.agent/skills/agent-guide/assets/agents-skeleton.md`
- `./.agent/skills/agent-guide/assets/readme-skeleton.md`
- `./.agent/skills/agent-guide/gotchas.md`
- `./.agent/skills/agent-guide/reference/execution-spec.md`
- `./.agent/skills/agent-guide/reference/quality-standards.md`
- `./.agent/skills/agent-guide/reference/three-file-spec.md`
- `./.agent/skills/agent-guide/scripts/validate-guide.sh`
- `./.agent/skills/docs-archive/SKILL.md`
- `./.agent/skills/docs-build/SKILL.md`

## 三、接口清单（Interface Catalog）

- 本仓库为文档与脚本仓库，未检测到应用运行时 API 接口清单。

## 四、核心流程（Core Flows）

- docs-indexing 扫描仓库文件并生成 `INDEX_GUIDE.md`
- 结果写入 `application/changelogs/indexing-log.jsonl` 以支持增量基线

## 五、配置与环境（Config & Environment）

- `--mode`: `full` / `incremental`
- `--depth`: `1` / `2` / `3`
- `--output`: 输出文件路径（默认 `./application/INDEX_GUIDE.md`）
- `--since`: 增量扫描起始时间戳（epoch ms）

## 六、未索引区域声明（Unindexed Scope）

- 仅索引可读取文件，不推断未读取内容。
- 当前未进行语义抽取，仅提供结构化路径与统计。

## 七、质量与边界（Quality & Boundaries）

- 路径均为仓库根相对路径
- 输出具有幂等性（相同输入得到相同结构）
- 增量模式在无有效基线时自动降级为全量

## 八、日志与追溯（Traceability）

- 执行日志：`./application/changelogs/indexing-log.jsonl`
- 变更基线：`./application/changelogs/changes-index.json`

## 九、附录（Appendix）

- 生成器：`.agent/skills/docs-indexing/scripts/indexing.sh`
- 规范参考：`.agent/skills/docs-indexing/reference/scan-spec.md`

## 十、中央知识库接入工程

本节用于在本仓库（中央知识库）登记各目标工程的接入信息，便于追溯与映射。由 `scripts/docs-init.sh --mode=central` 维护本表。

| APP ID | 工程路径（Git 或绝对路径） | 文档目录 |
|--------|---------------------------|----------|
| APP-TEST | /private/tmp/test-central | /private/tmp/test-central/docs |