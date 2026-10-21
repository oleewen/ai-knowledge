---
name: docs-indexing
description: >
  创建或更新九章 INDEX-GUIDE.md 文档地图，支持全量、增量与文内时间锚点。
  用于 /docs-indexing、建索引、更新索引指南或仓库 Onboarding 地图。
  实体提取及第四章视角导航由 docs-build 负责；OKF index.md 由 docs-okf 负责。
---

# docs-indexing

把已核实的仓库内容整理成可导航的九章地图。当前单元是一个 `INDEX-GUIDE.md`，增量锚点位于同一文件内。

## 执行

1. 读 [workflow.md](references/workflow.md) 与 [gates.md](references/gates.md)，收口范围、参数和增量基线；已明确的参数不重复询问。
2. 按 [scan-spec.md](references/scan-spec.md) 读取证据；incremental 同时核实变更集合与基线，无有效基线时按 [参数规范](references/scan-config-onboarding.md#2-增量基线) 重新决策。
3. 写前完成意图澄清；按 [九章规范](references/nine-chapter-spec.md) 更新正文，原样保留 `docs-build:entity-index:begin/end` 块。仅已读内容可写成已核实事实，阅读缺口列入第八章。
4. 按 [质量标准](references/quality-standards.md) 验证；指南成功后按 [锚点规范](references/indexing-log-spec.md) 写入完成时间，烤干收敛后等待用户动作。

## 脚本职责

`scripts/indexing.sh` 只枚举候选文件和统计数量，不阅读正文，也不计算 Git 增量集合。默认与 `--dry-run` 都只读；`--rewrite` 只刷新 `docs-indexing:begin/end` 运行块。完成锚点由 Agent 在指南成功后显式调用 `indexing_log.py write-anchor`。

从目标仓库运行本技能目录下的脚本，路径随安装位置解析；CLI 详见 `--help`。脚本依赖 Bash 5+、Python 3.9+ 及随 Agent 树安装的共享配置库。配置不满足时报告原因，可在已确认范围内由 Agent 直接只读检查，不代改全局配置。

本技能不生成独立 `INDEXING-LOG.md` 或 `changelogs/`，不自动改写实体、overview、SDD、README、AGENTS 或 OKF 产物。

## 按需读取

| 场景 | 资源 |
| --- | --- |
| 参数缺口、输出路径、时间展示 | [scan-config-onboarding.md](references/scan-config-onboarding.md) |
| 新建指南 | [index-guide-template.md](assets/index-guide-template.md) |
| 读者与表达取舍 | [audience-and-language.md](references/audience-and-language.md) |
| 失败或结果异常 | [gotchas.md](gotchas.md) |
| 维护技能、验证行为 | [evals.json](evals/evals.json)、[grader.md](agents/grader.md)、[tests/run.sh](tests/run.sh) |
