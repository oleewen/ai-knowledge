# sdx-test 草稿（中间稿）

**IDEA-ID**：`{IDEA-ID}`（与 PRD/ADD 一致；规则见 [reference/core-concepts.md](../reference/core-concepts.md)）  
**DOC_DIR**（自 `.docsconfig`）：`{DOC_DIR}`  
**--depth**：`quick | standard | deep`  
**门禁粒度**：`6 门禁（G1–G6）| 精简 4 门禁`  
**spec 版本**：`1.0.0`

---

## 门禁进度

| 门禁 | 覆盖模板 | 状态 | 备注 |
|------|----------|------|------|
| [G1](./test-session-spec-template.md#G1) | [§1 概述](./test-session-spec-template.md#G1) | 草案/已确认 | 示例行；按需复制为 G2…G6 |

---

## G1 …（按所选门禁续写）

### 本门禁结论

（测试设计表述，可粘贴至 TDD 对应节）

### 方案取舍（本门禁内若存在多套可选）

（可选；有 2 套及以上真实路径时填写：各路径业务命名、利弊、被选方案及理由。详见 [reference/brainstorming-integration.md](../reference/brainstorming-integration.md)。）

### Q-n / TC / US / BR（本门禁相关）

---

## 跨门禁一致性自检（轻量）

- [ ] **TC-*** 与 US-n/BR-n/API 追溯无未解释矛盾
- [ ] Q-n 已关闭或已标注推迟理由

---

## 用户总确认

本人确认：本 spec 可作为生成 `TDD-{IDEA-ID}-{N}.md` 的唯一素材来源。

- 确认人：`$HOME` 路径的**末级目录名**（即本机登录用户名；例：`/Users/alice` → `alice`；勿填显示名或占位词）
- 日期：YYYY-MM-DD

<!-- sdx-test-gate: PENDING -->

总确认后，将上一行中的 `PENDING` 改为 `CONFIRMED`（供钩子与 `validate-test.sh --gate-check` 识别）。本 spec 正文须至少出现一次完整文件名 `TDD-{IDEA-ID}-{N}.md`（与目标落盘文件名一致）。
