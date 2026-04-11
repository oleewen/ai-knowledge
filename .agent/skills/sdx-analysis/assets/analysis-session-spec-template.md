# sdx-analysis 会话 spec（中间稿）

> **说明**：闸门 **G{n}** 为流程步骤编号；模板 §1.2 **需求目标 G-n**、§2 **FR-n** 等为需求条目编号，勿混读。

**IDEA-ID**：`{IDEA-ID}`  
**DOC_DIR**（自 `.docsconfig`）：`{DOC_DIR}`  
**--depth**：`quick | standard | deep`  
**--solution**：`SOLUTION-{IDEA-ID}.md`（上游）  
**闸门粒度**：`6 闸（G1–G6）| 精简 4 闸`（见 [../SKILL.md](../SKILL.md) 与解决方案文档中的闸章映射表）  
**spec 版本**：`1.0.0`

---

## 闸门进度

| 闸门 | 覆盖模板（analysis-template） | 状态 | 备注 |
|------|--------------------------------|------|------|
|      |                                | 草案/已确认 |      |

---

## G1 …（按所选闸门续写）

### 本闸结论

（需求表述，可粘贴至 ANALYSIS 对应节）

### Q-n / FR 草案 / MVP / R-n（本闸相关）

---

## 跨闸一致性自检（轻量）

- [ ] 需求目标 **G-n**、**FR-n** 与范围、依赖、风险无未解释矛盾
- [ ] Q-n 已关闭或已标注推迟理由

---

## 用户总确认

本人确认：本 spec 可作为生成 `ANALYSIS-{IDEA-ID}.md` 的唯一素材来源。

- 确认人：
- 日期：YYYY-MM-DD

<!-- sdx-analysis-gate: PENDING -->

总确认后，将上一行中的 `PENDING` 改为 `CONFIRMED`（供钩子与 `validate-analysis.sh --gate-check` 识别）。本 spec 正文须至少出现一次完整文件名 `ANALYSIS-{IDEA-ID}.md`。
