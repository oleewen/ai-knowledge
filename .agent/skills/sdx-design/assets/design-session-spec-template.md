# sdx-design 草稿（中间稿）

> **说明**：门禁 **G{n}** 为流程步骤编号；ADD 模板 **§1.3 关键设计决策**表中的 **DD-n**、**§3** 中的 **API-n / LOGIC-n** 等为设计条目编号，勿与 G{n} 混读。

**IDEA-ID**：`{IDEA-ID}`（与 PRD / 同目录命名一致）  
**目标 ADD 文件**：`ADD-{IDEA-ID}-{N}.md`（须与落盘路径一致，供钩子与 `--gate-check` 匹配）  
**DOC_DIR**（自 `.docsconfig`）：`{DOC_DIR}`  
**--depth**：`quick | standard | deep`  
**门禁粒度**：`5 门禁（G1–G5）| 精简 3 门禁`  
**spec 版本**：`1.0.0`

---

## 门禁进度

| 门禁 | 覆盖模板（add-template） | 状态 | 备注 |
|------|-------------------------|------|------|
|      |                         | 草案/已确认 |      |

---

## G1 …（按所选门禁续写）

### 本门禁结论

（技术表述，可粘贴至 ADD 对应节）

### 方案取舍（本门禁内若存在多套可选）

（可选；有 2 套及以上真实路径时填写：各路径命名、利弊、被选方案及理由。详见 [reference/brainstorming-integration.md](../reference/brainstorming-integration.md)。）

### Q-n / DD-n / API-n（本门禁相关）

---

## 跨门禁一致性自检（轻量）

- [ ] DD-n / API-n 与 PRD 的 US-n / FR-n 追溯无未解释矛盾
- [ ] Q-n 已关闭或已标注推迟理由

---

## 用户总确认

本人确认：本 spec 可作为生成目标 `ADD-{IDEA-ID}-{N}.md` 的唯一素材来源。

- 确认人：`$HOME` 路径的**末级目录名**（即本机登录用户名；例：`/Users/alice` → `alice`；勿填显示名或占位词）
- 日期：YYYY-MM-DD

<!-- sdx-design-gate: PENDING -->

总确认后，将上一行中的 `PENDING` 改为 `CONFIRMED`（供钩子与 `validate-design.sh --gate-check` 识别）。本 spec 正文须至少出现一次完整文件名 `ADD-{IDEA-ID}-{N}.md`（与「目标 ADD 文件」一致）。
