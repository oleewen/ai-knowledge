# sdx-design 门禁规则

[SKILL.md](../SKILL.md) 为主干；流程与阶段见 [workflow.md](workflow.md)。

---

## 核心门禁

- **总确认前，禁止写入** `{DOC_DIR}/requirements/**/DSD-*.md`（正式路径下的详细设计终稿）。
- 合法例外**仅**在以下情形，且须在对话中留下明确依据：
  1. 用户在同一轮对话中明示可跳过门禁、仅要草稿、或紧急直写终稿。
  2. 环境变量 `SDX_DESIGN_ALLOW_DSD_WRITE=1`。

除以上两项外，一律按门禁执行。

---

## 门禁标记与 spec 约束

- Spec 文末使用 `<!-- sdx-design-gate: PENDING -->`；总确认后改为 `<!-- sdx-design-gate: CONFIRMED -->`。
- Spec 正文须至少出现一次目标文件名形态：`DSD-{IDEA-ID}-{N}.md`（与所选 IDEA-ID、阶段号一致）。

---

## 规约与 DSD 同期

应用全量场景下，**`{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`** 与 **DSD** 在总确认后同期落盘；与 DSD §2 互指与终检见 `workflow.md` 阶段三、[quality-checklist.md](quality-checklist.md)。

---

## 与独立 `/brainstorming` 的关系

本会话默认主产物为 `...-sdx-design.md` 与 **`DSD-*.md`**，**不以**独立 brainstorming 常见的 `*-design.md` + `writing-plans` 作为默认终态。嵌入节奏见 [brainstorming-integration.md](brainstorming-integration.md)。

---

## 交互选项（C / M / S / F）

阶段二各门禁末尾及 Qclose-1 均附标准四选项：

```
C：确认，进入下一步
M：修改，格式 "M 旧内容 - 新内容"
S：跳过本门禁，按默认值推进
F：跳过全部门禁，直接拟定草稿、撰写终稿
```

- **F** 直写终稿时仍须满足上文「合法例外」之一，否则违规。

---

## 总确认（Qclose-1）

全部门禁收口后：

> 是否同意以当前草稿为唯一素材生成 `DSD-{IDEA-ID}-{N}.md`？（附标准四选项）

- **C / S**：将 `PENDING` 改为 `CONFIRMED`，进入阶段三。
- **M**：返回修订 spec。
- **F**：不经总确认直写草稿（须符合「合法例外」）。

**确认人**：填写 `$HOME` 路径末级目录名（本机用户名），勿填显示名或占位词。
