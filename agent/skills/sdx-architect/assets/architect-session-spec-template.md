# sdx-architect 草稿（中间稿）

> **说明**：门禁 **Ga{n}** 为流程步骤编号；ASD **§1.3 关键设计决策**表中的 **DD-n** 等为设计条目编号，勿与 Ga{n} 混读。

**IDEA-ID**：`{IDEA-ID}`（与 PRD / 同目录命名一致）  
**目标 ASD 文件**：`ASD-{IDEA-ID}-{N}.md`（须与落盘路径一致，供钩子与 `validate-asd.sh --gate-check` 匹配）  
**DOC_DIR**（自 `.docsconfig`）：`{DOC_DIR}`  
**KNOWLEDGE_TYPE**（自 `.docsconfig`，可选）：`application | system | company | （未设置）` — `system`/`company` 时见 [knowledge-type-modes.md](../reference/knowledge-type-modes.md)。  
**--depth**：`quick | standard | deep`  
**门禁粒度**：建议 **Ga1–Ga2**（对应 ASD §1–§2）  
**spec 版本**：`1.0.0`

---

## 门禁进度

| 门禁 | 覆盖模板 | 状态 | 备注 |
|------|----------|------|------|
| [Ga1](./architect-session-spec-template.md#Ga1) | [§1 设计概述](./architect-session-spec-template.md#Ga1) | 草案/已确认 | 示例行；按需复制为 Ga2 |

---

## Ga1 …

### 本门禁结论

（技术表述，可粘贴至 ASD §1）

### 方案取舍（本门禁内若存在多套可选）

（可选；见 [reference/brainstorming-integration.md](../../sdx-design/reference/brainstorming-integration.md) — 与 sdx-design 共用细则时读该文件。）

### Q-n / DD-n（本门禁相关）

---

## Ga2 …

### 本门禁结论

（可粘贴至 ASD §2）

---

## 跨门禁一致性自检（轻量）

- [ ] DD-n 与 PRD 的 US-n / FR-n 追溯无未解释矛盾
- [ ] 与下游 **DSD**（`/sdx-design`）范围无未说明冲突

---

## 用户总确认

本人确认：本 spec 可作为生成目标 `ASD-{IDEA-ID}-{N}.md` 的唯一素材来源。

- 确认人：`$HOME` 路径末级目录名
- 日期：YYYY-MM-DD

<!-- sdx-architect-gate: PENDING -->

总确认后，将上一行中的 `PENDING` 改为 `CONFIRMED`。本 spec 正文须至少出现一次完整文件名 `ASD-{IDEA-ID}-{N}.md`。
