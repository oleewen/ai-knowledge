---
name: docs-publish
description: >
  按四层 DESIGN.md 版本规则发布知识库版本：自动计算 YYYY.MMdd.patch，记录 docs-publish commit，
  rebase main、提交、推送、快进合并 main，并创建下一 feature 分支。
  用户提到 /docs-publish、发布知识库版本、提交并推送版本、合并 main 时使用本技能。
---

# docs-publish

## 版本规则

- 四层 `DESIGN.md` 使用统一 `version: YYYY.MMdd.patch`。
- 当前日期生成 `YYYY.MMdd`；同日从四层当前 patch 加一，否则 patch 为 `0`。
- 旧格式 `YY.MM.DD` 首次直接迁移为当天 `.0`。
- commit subject 固定为 `docs-publish: version YYYY.MMdd.patch`。
- body 记录旧版本、新版本和发布文件，后续升级从 Git log 识别发布点。

## 流程

默认执行完整流程：检查工作区、更新四层版本、rebase 最新 `main`、提交、推送 feature、快进合并并推送 `main`，最后创建并切换 `feature-YYYY.MMdd.patch`。网络、认证、分支保护或非快进状态失败立即中止并保留现场。`--dry-run` 只展示版本和 diff。

允许发布清单：四层 `DESIGN.md` 与本任务已登记的 `TODO-LIST.md`；其他改动硬停。

```bash
bash agent/skills/docs-publish/scripts/docs-publish.sh --dry-run
bash agent/skills/docs-publish/scripts/docs-publish.sh
```

## Git 版本识别

共享解析实现位于 `agent/scripts/lib/version.sh`，提供版本规范化、比较、commit 查找和最新版本识别。`docs-upgrade` 使用 `docs-publish` commit 作为版本边界，并按两个发布点之间的 Git diff 执行现有升级流程。

## 评测

`evals/evals.json` 与 `tests/run.sh` 覆盖版本计算、旧格式迁移、脏改动硬停、commit 标记与 dry-run。
