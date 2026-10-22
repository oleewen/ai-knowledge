---
name: docs-merge
description: >
  将源文件或内联文本合入已存在 Markdown 的 H2/H3 章节。
  用于 /docs-merge、把材料合并进文档、合入指定章节及处理章节合并冲突。
  overview 第三列关键词提炼用 docs-extract；正文精简用 docs-simplify；术语替换用 docs-revise。
---

# docs-merge

将材料放进目标文档合适的章节，只写经过确认的增量。

## 输入与边界

`/docs-merge <source> <target> [--dry-run]`

`source` 为文件或内联文本，`target` 为一个已存在的 `.md`。明确的位置参数按顺序解析；缺参或语义冲突才询问。源只读；本技能不新建目标文件。

## 核心约束

- 先公布新增、更新和未落位清单，再逐项确认；每项给预览、推荐和选项，答完当前项才问下一项。冲突在该项内逐条解决。
- 正式写入须落位明确、写前 `C` 和逐项决议齐备；仅将已采纳项一次写回。完全重复的内容不算更新。
- `--dry-run` 只预览；转正式须重新取得正式写入的写前 `C`，不能沿用预览授权。两种模式均须烤干并停等用户动作。
- 写前复核源、目标与计划基线一致；有变化则重新核对受影响项，保留他人修改。

## 按需读取

| 时机 | 读取 |
| --- | --- |
| 开始执行 | [workflow.md](references/workflow.md)：顺序；[gates.md](references/gates.md)：授权与共享协议 |
| 切块、落位、清点、决策或写入 | [merge-spec.md](references/merge-spec.md)：合入规则唯一真源 |
| 目标属于四层业务 knowledge | [knowledge-governance.md](../../knowledge/knowledge-governance.md) 的「业务 knowledge 引用边界」 |
| 预览或写入后 | [quality-checklist.md](references/quality-checklist.md)、[audience-and-language.md](references/audience-and-language.md) |
| 排查误用或理解术语 | [参考索引](references/README.md)、[gotchas.md](gotchas.md) |
| 维护技能、运行评测 | [evaluation.md](references/evaluation.md)、[grader.md](agents/grader.md) |

## 交付

预览交付合入计划与变更清单；正式交付目标差异、采纳/跳过结果及验证证据。无增量时报告无变更。评测工具只用于验证技能，不代替语义落位和用户决策。
