# sdx-design 门禁

流程见 [workflow.md](workflow.md)。

## 核心门禁

**总确认前禁止写入** `{DOC_DIR}/requirements/**/DSD-*.md`**。例外须在对话留痕：

1. 用户明示跳过门禁、仅草稿或紧急直写终稿。  
2. `SDX_DESIGN_ALLOW_DSD_WRITE=1`。

## 会话 spec

- 路径：符合 `{DOC_DIR}/superpowers/`（见 [session-spec-path.md](../../../references/session-spec-path.md)）。

- 文末：`<!-- sdx-design-gate: PENDING -->` → 总确认后 **`CONFIRMED`**。  
- 正文至少一次出现 **`DSD-{IDEA-ID}-{N}.md`**（与所选 IDEA-ID、阶段一致）。

## DSD 落盘时机

总确认通过后，**仅写 DSD**。实现级内容与 PRD / ASD §3（或 **`spec-asd-*`**）的追溯在 **DSD §2** 表达。终检见 [quality-checklist.md](quality-checklist.md)。

## 与独立 `/brainstorming` 的关系

本会话默认终态为 **`...-sdx-design.md`** + **`DSD-*.md`**，不以独立 brainstorming 的 `*-design.md` + `writing-plans` 为默认。嵌入节奏见 [brainstorming-integration.md](brainstorming-integration.md)。

## 交互选项（C / M / S / F）

```
C：确认进入下一步    M：修改（"M 旧 - 新"）
S：跳过本门禁默认值  F：跳全部门禁拟草稿/终稿
```

**F** 直写终稿仍须符合上文「例外」其一。

## Qclose-1

全部门禁收口后：

> 是否同意以当前草稿为唯一素材生成 `DSD-{IDEA-ID}-{N}.md`？

- **C / S**：`CONFIRMED` → 阶段三。  
- **M**：回修订。  
- **F**：不经总确认直写 → 须合法例外。

**确认人**：`$HOME` 末级目录名（本机用户名）。
