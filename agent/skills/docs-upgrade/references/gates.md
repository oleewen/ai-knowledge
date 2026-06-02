# 门禁与分流

路径契约：[session-spec-path.md](../../../references/session-spec-path.md)（会话 spec 落在 `{DOC_DIR}/superpowers/`，排除 `requirements/**/specs/`）。
流程：[workflow.md](workflow.md)；预检：[brainstorming-integration.md](brainstorming-integration.md)；实操：[gotchas.md](../gotchas.md)。

## 边界（摘要）

本技能：定向改文 + 默认链式（引用 + 关键词）；简写 `a - b` / `a > b` / `a 2 b`。  
**不作为主路径**：CHANGE-LOG 聚合（docs-change）、INDEX 重建（docs-indexing）、overview 行归档（docs-archive）、实体索引（docs-build），除非用户明说附加。

## HARD-GATE（范围确认书）

**写入前**须有会话内确认，用户 **C** / **S** / **M**（改范围后重确认）。

- **必触发**：多文件、大目录替换、意图不清。  
- **快路径**：单文件、路径+改动已明 → 一句话复述「改 X：Y」，用户 OK 即可。  
- **禁止**：未 **C**/**S** 即**批量**多文件写入；范围未界就开步骤 3 大海捞针。

模板：[../assets/docs-upgrade-scope-ack-template.md](../assets/docs-upgrade-scope-ack-template.md)。

```
即将执行 /docs-upgrade，范围如下：
- 主目标文件: <路径>
- 改动摘要: <…>
- 关联同步范围: <引用链约 N / 关键词约 N / 仅本文件>

C 确认执行 / M 改范围 / S 跳过关联仅改主文件
```

**S** = 只主文件，不做步骤 3 扩展。

## 与其它关系

- ≠ 独立 brainstorming 全套「先 design spec 再实现」；嵌入节奏见 brainstorming-integration。  
- **无** `preToolUse` 钩子；靠执行模型守 HARD-GATE。
