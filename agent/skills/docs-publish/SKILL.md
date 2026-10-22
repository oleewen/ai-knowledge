---
name: docs-publish
description: >
  发布四层知识库版本：校验四层 DESIGN.md、计算 YYYY.MMdd.patch，并先输出可审阅的 dry-run；
  获用户明确确认后再执行 commit、rebase、push、快进合并和下一 feature 分支切换。
  仅用于版本发布；文档升级、内容改写和一般 Git 发布请转到对应技能。
---

# docs-publish

发布四层知识库版本时，统一更新 `application/`、`system/`、`solution/`、`company/` 下的
`DESIGN.md`。技能只负责版本发布与 Git 边界；文档正文升级走 `/docs-upgrade`，结构精简走
`/docs-simplify`。

## 必守不变量

- 四个 `DESIGN.md` 都必须存在，并且 `version` 解析后完全一致。
- 正式版本为 `YYYY.MMdd.patch`：同日 patch 加一，跨日归零；旧 `YY.MM.DD` 首次迁移为当天 `.0`。
- 发布提交 subject 固定为 `docs-publish: version YYYY.MMdd.patch`。
- 允许发布的文件只有四个 `DESIGN.md`；根级或四层目录内的 `TODO-LIST.md` 只有在本次 dry-run 列出并经确认时才可随发布提交。
- 版本发布提交是 `/docs-upgrade` 识别模板版本边界的依据；不要在其他技能中复制发布点规则。

## 执行闸门

默认先预览。写入版本、提交、rebase、推送、快进合并和切换下一分支都属于外部或不可逆 Git 操作，必须在 dry-run 结果明确且得到用户确认后执行。

```bash
# 预览：不改文件、不提交、不联网写入
bash agent/skills/docs-publish/scripts/docs-publish.sh --dry-run

# 用户确认同一预览结果后，才执行正式发布
bash agent/skills/docs-publish/scripts/docs-publish.sh --publish
```

正式执行按 [workflow.md](references/workflow.md) 的顺序进行。认证失败、分支保护、冲突、非快进或其他异常时立即停住并保留现场；不要自动重试、回滚或改写无关文件。

## 边界与分流

| 请求 | 处理 |
| --- | --- |
| 发布四层 `DESIGN.md` 版本 | 本技能；先 dry-run，再等确认 |
| 只改版本字段，不做发布 | 先确认是否真的是发布；否则转 `/docs-revise` |
| 已有知识库对齐模板 | `/docs-upgrade` |
| 精简或重组 Markdown | `/docs-simplify` |
| 一般分支发布、普通 Git 提交或推送 | 按项目 Git 约定处理，不套用本技能 |

## 按需查阅

- 版本计算、兼容格式与提交标记：[versioning.md](references/versioning.md)
- 预览、确认、发布、失败停顿与完成校核：[workflow.md](references/workflow.md)
- 常见阻塞与恢复边界：[gotchas.md](references/gotchas.md)
- 脚本回归：`bash agent/skills/docs-publish/tests/run.sh`
- 行为评测：[evals/evals.json](evals/evals.json)
