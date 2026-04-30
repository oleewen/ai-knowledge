# sdx-architect 草稿（中间稿）

> **说明**：门禁 **G{n}** 为流程步骤编号；ASD **§1.3 关键设计决策**表中的 **DD-n** 等为设计条目编号，勿与 G{n} 混读。

**IDEA-ID**：`{IDEA-ID}`（与 PRD / 同目录命名一致）  
**目标 ASD 文件**：`ASD-{IDEA-ID}-{N}.md`（须与落盘路径一致，供钩子与 `validate-asd.sh --Gte-check` 匹配）  
**DOC_DIR**（自 `.docsconfig`）：`{DOC_DIR}`  
**KNOWLEDGE_TYPE**（自 `.docsconfig`，可选）：`application | system | company | （未设置）` — `system`/`company` 时见 [knowledge-type-modes.md](../reference/knowledge-type-modes.md)。  
**--depth**：`quick | standard | deep`  
**门禁粒度**：建议 **G1–G3**（对应 ASD §1–§3）  
**spec 版本**：`1.0.0`

---

## 门禁进度

| 门禁 | 覆盖模板 | 状态 | 备注 |
|------|----------|------|------|
| [G{n}](#g{n}-XX) | [§{n} XX](#g{n}-XX) | 草案/已确认 | 示例行；按需复制为 G{n+1} |

---

## G1 …

### 本门禁结论

（技术表述，可粘贴至 ASD §1）

### 方案取舍（本门禁内若存在多套可选）

（可选；见 [reference/brainstorming-integration.md](../../sdx-design/reference/brainstorming-integration.md) — 与 sdx-design 共用细则时读该文件。）

### Q-n / DD-n（本门禁相关）

---

## G2 …

### 本门禁结论

（可粘贴至 ASD §2）

---

## G3 …

### 本门禁结论

（可粘贴至 ASD **§3 需求规约**表：**负责服务 / 能力 / 核心参数 / 关键步骤 / 返回结果**；每行可追溯到 §2 服务或 PRD FR-n）

---

## 跨门禁一致性自检（轻量）

- [ ] DD-n 与 PRD 的 US-n / FR-n 追溯无未解释矛盾
- [ ] 与下游 **DSD**（`/sdx-design`）范围无未说明冲突
- [ ] **§3** 表中规划之 `specs/` 路径、应用 ID 与 KNOWLEDGE_INDEX / MS-* 无未解释的缺口

---

## 用户总确认

本人确认：本 spec 可作为生成目标 `ASD-{IDEA-ID}-{N}.md` 的唯一素材来源。

- 确认人：`$HOME` 路径末级目录名
- 日期：YYYY-MM-DD

<!-- sdx-architect-Gte: PENDING -->

总确认后，将上一行中的 `PENDING` 改为 `CONFIRMED`。本 spec 正文须至少出现一次完整文件名 `ASD-{IDEA-ID}-{N}.md`。
