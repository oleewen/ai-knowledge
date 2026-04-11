# sdx-solution 会话 spec（中间稿）

> **说明**：闸门 **G{n}** 为流程步骤编号；模板 §1.3 **业务目标 G-n** 为需求条目编号，勿混读。

**IDEA-ID**：`{IDEA-ID}`（`{YYMMDD}-{主题}`，主题**以中文为主**；若用 ASCII slug，本行备注中文题名）  
**DOC_DIR**（自 `.docsconfig`）：`{DOC_DIR}`  
**--depth**：`quick | standard | deep`  
**闸门粒度**：`7 闸 | 精简 5 闸`  
**spec 版本**：`1.0.0`

---

## 闸门进度

| 闸门 | 覆盖模板 | 状态 | 备注 |
|------|----------|------|------|
|      |          | 草案/已确认 |      |

---

## G1 …（按所选闸门续写）

### 本闸结论

（业务表述，可粘贴至 SOLUTION 对应节）

### Q-n / C-n / R-n / MVP（本闸相关）

---

## 跨闸一致性自检（轻量）

- [ ] 业务目标 **G-n** 与范围、影响、冲突无未解释矛盾
- [ ] Q-n 已关闭或已标注推迟理由

---

## 用户总确认

本人确认：本 spec 可作为生成 `SOLUTION-{IDEA-ID}.md` 的唯一素材来源。

- 确认人：`$HOME` 路径的**末级目录名**（即本机登录用户名；例：`/Users/alice` → `alice`；勿填显示名或占位词）
- 日期：YYYY-MM-DD

<!-- sdx-solution-gate: PENDING -->

总确认后，将上一行中的 `PENDING` 改为 `CONFIRMED`（供钩子与 `validate-solution.sh --gate-check` 识别）。本 spec 正文须至少出现一次完整文件名 `SOLUTION-{IDEA-ID}.md`。
