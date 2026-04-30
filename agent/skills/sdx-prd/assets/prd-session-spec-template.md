# sdx-prd 草稿（中间稿）

> **说明**：门禁 **G{n}** 为流程步骤编号；模板 **§n** 为 PRD 章节号；**US-n / UC-n / FR-n** 等编号见 [reference/core-concepts.md](../reference/core-concepts.md)。

**IDEA-ID**：`{IDEA-ID}`（与上游 `ANALYSIS-{IDEA-ID}.md` 一致）  
**MVP 阶段 N**：`{N}`（对应目录 `MVP-Phase-{N}` 与终稿文件名 `PRD-{IDEA-ID}-{N}.md`）  
**DOC_DIR**（自 `.docsconfig`）：`{DOC_DIR}`  
**--depth**：`quick | standard | deep`  
**门禁粒度**：`11 门禁（G1–G11）| 精简 6 门禁`  
**spec 版本**：`1.0.0`

---

## 门禁进度

| 门禁 | 覆盖模板 | 状态 | 备注 |
|------|----------|------|------|
| [G{n}](#g{n}-XX) | [§{n} XX](#g{n}-XX) | 草案/已确认 | 示例行；按需复制为 G{n+1} |

---

## G1 …（按所选门禁续写）

### 本门禁结论

（需求表述，可粘贴至 PRD 对应节）

### 方案取舍（本门禁内若存在多套可选）

（可选；有 2 套及以上真实路径时填写：各路径业务命名、利弊、被选方案及理由。详见 [reference/brainstorming-integration.md](../reference/brainstorming-integration.md)。）

### Q-n / FR / US / BR（本门禁相关）

---

## 跨门禁一致性自检（轻量）

- [ ] 与 `ANALYSIS-{IDEA-ID}.md` 当前 MVP 范围、FR-n / BR-n 无未解释矛盾
- [ ] Q-n 已关闭或已标注推迟理由

---

## 用户总确认

本人确认：本 spec 可作为生成 `PRD-{IDEA-ID}-{N}.md` 的唯一素材来源。

- 确认人：`$HOME` 路径的**末级目录名**（即本机登录用户名；例：`/Users/alice` → `alice`；勿填显示名或占位词）
- 日期：YYYY-MM-DD

<!-- sdx-prd-gate: PENDING -->

总确认后，将上一行中的 `PENDING` 改为 `CONFIRMED`（供钩子与 `validate-prd.sh --gate-check` 识别）。本 spec 正文须至少出现一次完整文件名 `PRD-{IDEA-ID}-{N}.md`。
