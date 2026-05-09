# sdx-analysis 草稿（中间稿）

> **说明**：门禁 **G{n}** 为流程步骤编号；模板 §1.2 **需求目标**表中的 **G-n** 为与上游对齐的目标条目编号；§2 **FR-n** 为功能需求编号，勿混读。

**IDEA-ID**：`{IDEA-ID}`（`{YYMMDD}-{主题}`，主题**以中文为主**；若用 ASCII slug，本行备注中文题名）  
**DOC_DIR**（自 `.docsconfig`）：`{DOC_DIR}`  
**--depth**：`quick | standard | deep`  
**门禁粒度**：`6 门禁（G1–G6）| 精简 4 门禁`  
**spec 版本**：`1.0.0`

---

## 门禁进度

| 门禁 | 覆盖模板 | 状态 | 备注 |
|------|----------|------|------|
| [G{n}](#g{n}-XX) | [§{n} XX](#g{n}-XX) | 草案/已确认 | 示例行；按需复制为 G{n+1} |

---

## G1 …（按所选门禁续写）

### 本门禁结论

（需求表述，可粘贴至 ANALYSIS 对应节）

### 方案取舍（本门禁内若存在多套可选）

（可选；≥2 条路径时：业务命名、利弊、选中理由。见 [brainstorming-integration.md](../references/brainstorming-integration.md)。）

### Q-n / FR / MVP / R-n（本门禁相关）

---

## 跨门禁一致性自检（轻量）

- [ ] 需求目标 **G-n**（§1.2）、**FR-n** 与范围、MVP、依赖、风险无未解释矛盾
- [ ] Q-n 已关闭或已标注推迟理由

---

## 用户总确认

本人确认：本 spec 可作为生成 `ANALYSIS-{IDEA-ID}.md` 的唯一素材来源。

- 确认人：`$HOME` 路径的**末级目录名**（即本机登录用户名；例：`/Users/alice` → `alice`；勿填显示名或占位词）
- 日期：YYYY-MM-DD

<!-- sdx-analysis-gate: PENDING -->

总确认后：`PENDING`→`CONFIRMED`（钩子与 `validate-analysis.sh --gate-check`）。正文须至少出现一次 `ANALYSIS-{IDEA-ID}.md`。
