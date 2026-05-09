# sdx-architect 草稿

> **G{n}**：流程门禁。**DD-n**：ASD §1.3 设计条目 — 二者勿混。

**IDEA-ID**：`{IDEA-ID}`  
**目标 ASD**：`ASD-{IDEA-ID}-{N}.md`（与落盘一致；`--gate-check`）  
**DOC_DIR**：`{DOC_DIR}`  
**KNOWLEDGE_TYPE**：`application | system | company | 未设置` — system/company 见 [knowledge-type-modes.md](../references/knowledge-type-modes.md)  
**--depth**：`quick | standard | deep`  
**门禁**：G1–G3 ↔ ASD §1–§3  
**spec 版本**：`1.0.0`

---

## 门禁进度

| 门禁 | 覆盖 | 状态 | 备注 |
|------|------|------|------|
| [G{n}](#g{n}-xx) | [§{n}](#g{n}-xx) | 草案/已确认 | 按需扩行 |

---

## G1 …

### 本门禁结论

（可粘贴至 ASD §1）

### 方案取舍（本门禁内多方案时）

（可选；头脑风暴细则见 [brainstorming-integration.md](../../sdx-design/references/brainstorming-integration.md)）

### Q-n / DD-n（本门禁相关）

---

## G2 …

### 本门禁结论

（可粘贴至 ASD §2）

---

## G3 …

### 本门禁结论

（粘贴 §3 表：服务/能力/参数/步骤/返回；行可溯 §2 或 PRD FR-n）

---

## 跨门禁自检

- [ ] DD-n 与 PRD（US/FR）无未解释矛盾  
- [ ] 与 `/sdx-design` 范围无未说明冲突  
- [ ] §3 的 `specs/`、应用 ID 与 KNOWLEDGE_INDEX / MS-* 一致  

---

## 用户总确认

确认本 spec 为生成 `ASD-{IDEA-ID}-{N}.md` 的唯一素材。

- 确认人：`$HOME` 末级目录名  
- 日期：YYYY-MM-DD  

`<!-- sdx-architect-gate: PENDING -->` → 总确认后 `<!-- sdx-architect-gate: CONFIRMED -->`（字面量同 [validate-asd.sh](../scripts/validate-asd.sh)）。正文须含全名 `ASD-{IDEA-ID}-{N}.md`。
