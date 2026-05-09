# sdx-prd 草稿

> **G{n}**：门禁步骤；**§n**：PRD 章号。编号见 [core-concepts.md](../references/core-concepts.md)。

**IDEA-ID**：`{IDEA-ID}`（= `ANALYSIS-{IDEA-ID}.md`） **N**：`{N}` → `MVP-Phase-{N}` / `PRD-{IDEA-ID}-{N}.md`  
**DOC_DIR**：`{DOC_DIR}` **--depth**：`quick | standard | deep` **门禁**：`11G | 精简6G` **spec 版本**：`1.0.0`

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

（可选；有 2 套及以上真实路径时填写：各路径业务命名、利弊、被选方案及理由。详见 [references/brainstorming-integration.md](../references/brainstorming-integration.md)。）

### Q-n / FR / US / BR（本门禁相关）

---

## 跨门禁一致性自检（轻量）

- [ ] 与 `ANALYSIS-{IDEA-ID}.md` 当前 MVP 范围、FR-n / BR-n 无未解释矛盾
- [ ] Q-n 已关闭或已标注推迟理由

---

## 用户总确认

本人确认：本 spec 可作为生成 `PRD-{IDEA-ID}-{N}.md` 的唯一素材来源。

- 确认人：`$HOME` 末级目录名（本机用户名；勿填昵称/占位）
- 日期：YYYY-MM-DD

<!-- sdx-prd-gate: PENDING -->

总确认：`PENDING`→`CONFIRMED`（与 `validate-prd.sh --gate-check` 字面一致）。正文至少一次完整 **`PRD-{IDEA-ID}-{N}.md`**。
