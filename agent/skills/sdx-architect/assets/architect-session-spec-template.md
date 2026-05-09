# sdx-architect 草稿（中间稿）

> **G{n}**：流程门禁编号。ASD **§1.3** 表内 **DD-n** 为设计条目编号，勿与 G{n} 混淆。

**IDEA-ID**：`{IDEA-ID}`  
**目标 ASD 文件**：`ASD-{IDEA-ID}-{N}.md`（须与落盘一致，供 `--gate-check`）  
**DOC_DIR**：`{DOC_DIR}`  
**KNOWLEDGE_TYPE**：`application | system | company | （未设置）` — system/company 见 [knowledge-type-modes.md](../references/knowledge-type-modes.md)  
**--depth**：`quick | standard | deep`  
**门禁**：建议 G1–G3（对应 ASD §1–§3）  
**spec 版本**：`1.0.0`

---

## 门禁进度

| 门禁 | 覆盖 | 状态 | 备注 |
|------|------|------|------|
| [G{n}](#g{n}-xx) | [§{n}](#g{n}-xx) | 草案/已确认 | 按需复制扩展 |

---

## G1 …

### 本门禁结论

（可粘贴至 ASD §1）

### 方案取舍（本门禁内多方案时）

（可选；与 sdx-design 共用的头脑风暴细则见 [brainstorming-integration.md](../../sdx-design/references/brainstorming-integration.md)）

### Q-n / DD-n（本门禁相关）

---

## G2 …

### 本门禁结论

（可粘贴至 ASD §2）

---

## G3 …

### 本门禁结论

（可粘贴至 ASD **§3 需求规约**表：**负责服务 / 能力 / 核心参数 / 关键步骤 / 返回结果**；行级可追溯 §2 或 PRD FR-n）

---

## 跨门禁自检

- [ ] DD-n 与 PRD（US/FR）无未解释矛盾  
- [ ] 与 `/sdx-design` 范围无未说明冲突  
- [ ] §3 规划的 `specs/` 路径、应用 ID 与 KNOWLEDGE_INDEX / MS-* 一致  

---

## 用户总确认

本人确认：本 spec 可作为生成 `ASD-{IDEA-ID}-{N}.md` 的唯一素材来源。

- 确认人：`$HOME` 末级目录名  
- 日期：YYYY-MM-DD  

`<!-- sdx-architect-gate: PENDING -->`  
总确认后改为 `<!-- sdx-architect-gate: CONFIRMED -->`（字符串须与 [validate-asd.sh](../scripts/validate-asd.sh) 一致）。正文至少出现一次完整文件名 `ASD-{IDEA-ID}-{N}.md`。
