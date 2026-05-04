# sdx-analysis 门禁规则

[SKILL.md](../SKILL.md) 为主干；流程与阶段见 [workflow.md](workflow.md)。

---

## 核心门禁

- **总确认前，禁止写入** `{DOC_DIR}/analysis/ANALYSIS-*.md`（正式路径下的需求分析终稿）。
- 合法例外**仅**在以下情形，且须在对话中留下明确依据：
  1. 用户在同一轮对话中明示可跳过门禁、仅要草稿、或紧急直写终稿。
  2. 环境变量 `SDX_ANALYSIS_ALLOW_ANALYSIS_WRITE=1`。

除以上两项外，一律按门禁执行。

---

## 门禁标记与 spec 约束

- Spec 文末使用 `<!-- sdx-analysis-gate: PENDING -->`；总确认后改为 `<!-- sdx-analysis-gate: CONFIRMED -->`。
- Spec 正文须至少出现一次目标文件名形态：`ANALYSIS-{IDEA-ID}.md`（与所选 IDEA-ID 一致）。

---

## 与独立 `/brainstorming` 的关系

本会话默认主产物为 `...-sdx-analysis.md` 与 `ANALYSIS-*.md`，**不以**独立 brainstorming 常见的 `*-design.md` + `writing-plans` 作为默认终态。嵌入节奏见 [brainstorming-integration.md](brainstorming-integration.md)。

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

> 是否同意以当前草稿为唯一素材生成 `ANALYSIS-{IDEA-ID}.md`？（附标准四选项）

- **C / S**：将 `PENDING` 改为 `CONFIRMED`，进入阶段三。
- **M**：返回修订 spec。
- **F**：不经总确认直写草稿（须符合「合法例外」）。

**确认人**：填写 `$HOME` 路径末级目录名（本机用户名），勿填显示名或占位词。
