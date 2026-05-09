# sdx-prd 门禁

流程见 [workflow.md](workflow.md)。

## 核心门禁

**总确认前禁止写入** `{DOC_DIR}/requirements/**/PRD-*.md`。例外须在对话留痕：

1. 用户明示跳过、仅草稿或紧急直写终稿。  
2. `SDX_PRD_ALLOW_PRD_WRITE=1`。

## 会话 spec

- 文末：`<!-- sdx-prd-gate: PENDING -->` → 总确认后 **`CONFIRMED`**。  
- 正文至少一次 **`PRD-{IDEA-ID}-{N}.md`**（与 IDEA-ID、`N` 一致）。

## 与独立 `/brainstorming` 的关系

本会话终态为 **`...-sdx-prd.md`** + **`PRD-*.md`**，不以独立 brainstorming 的 `*-design.md` + writing-plans 为默认。见 [brainstorming-integration.md](brainstorming-integration.md)。

## 交互（C / M / S / F）

```
C：确认下一步    M：修改（"M 旧 - 新"）
S：跳过本门禁    F：跳全部门禁拟稿/终稿
```

**F** 写终稿须符合上文「例外」。

## Qclose-1

> 是否同意以当前草稿为唯一素材生成 `PRD-{IDEA-ID}-{N}.md`？

- **C / S**：`CONFIRMED` → 阶段三。  
- **M**：回改。  
- **F**：直写草稿 → 须合法例外。

**确认人**：`$HOME` 末级目录名（本机用户名）。
