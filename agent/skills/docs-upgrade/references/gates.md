# 门禁与分流

流程：[workflow.md](workflow.md)；预检：[brainstorming-integration.md](brainstorming-integration.md)；实操：[gotchas.md](../gotchas.md)。

## 边界（摘要）

本技能：定向改文 + 默认链式（引用 + 关键词）；简写 `a - b` / `a > b` / `a 2 b`。  
**不作为主路径**：CHANGE-LOG 聚合（docs-change）、INDEX 重建（docs-indexing）、overview 行归档（docs-archive）、实体索引（docs-build），除非用户明说附加。

## 范围确认

写入前须先收口以下内容：

- 主目标文件
- 改动摘要
- 是否允许关联扩展
- 用户是否限定“只改本文件 / 不要关联 / 不要全库搜”

满足任一时，先澄清再写：

- 多文件或大目录替换
- 术语边界不清
- 是否扩展关联未说明
- 意图不清，可能越过 docs-upgrade 边界

## 风险与动作

以下情况属于语义性问题，必须先给出结论、推荐方案与动作选项，再等待用户确认：

- 是否把术语替换扩展到引用链和关键词链
- 是否只改当前主文件
- 术语或表述是否跨越业务语义边界
- 关联文件是否应按同一口径统一

推荐会话格式：

```text
即将执行 /docs-upgrade，当前范围如下：
- 主目标文件: <路径>
- 改动摘要: <...>
- 当前单元: <主文件|关联批次>
- 关联同步范围: <仅本文件|引用链约 N|关键词约 N|待确认>

C 确认当前单元 / M 改范围 / S 仅主文件 / G 继续深挖 / F 补齐剩余关联批次
```

**S** = 仅主文件，不做关联扩展。

## 默认授权边界

- 已收口范围下，可直接执行**非语义性修订**：错别字、编号、排版、链接修补
- 涉及术语边界、是否扩展、是否批量替换，按语义性处理

## 与其它关系

- ≠ 独立 brainstorming 全套「先 design spec 再实现」；嵌入节奏见 brainstorming-integration。  
- **无** `preToolUse` 钩子；靠执行模型守范围确认与语义确认。
- 模板：[../assets/docs-upgrade-scope-ack-template.md](../assets/docs-upgrade-scope-ack-template.md)。
