# 会话 spec 路径契约

## 合法路径

`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-<阶段后缀>.md`

- **DOC_DIR / 文档根**：与 INDEX 一致的一级目录，如 `application`、`system`、`company`。
- **中间目录**：固定为 **`superpowers/specs/`**（会话闸门中间稿；通常被 `.gitignore` 忽略，不入库）。
- **阶段后缀**：见 [CONVENTIONS.md](../rules/CONVENTIONS.md#artifact-gates) 总表（如 `-sdx-prd.md`、`-docs-indexing.md`）。

示例：

- `{DOC_DIR}/superpowers/specs/2026-06-02-order-prd-sdx-prd.md`
- `{DOC_DIR}/superpowers/specs/2026-06-02-index-refresh-docs-indexing.md`
- `{DOC_DIR}/superpowers/specs/2026-06-02-billing-distill-docs-distill.md`

## 实现判定（与 hooks 一致）

仓库根相对路径须同时满足：

1. 路径形如 `{docroot}/superpowers/specs/...`（`docroot` 须为 `application`、`system` 或 `company`）。
2. 路径中**不含** `/requirements/`。
3. 以 `.md` 结尾。

因此 `{docroot}/specs/` 下旧式会话闸门稿、`{docroot}/superpower/specs/` 旧式路径（已废弃）、`{docroot}/superpowers/` 扁平路径（缺 `specs/` 子目录）、以及 `application/requirements/.../MVP-Phase-*/specs/` **均不**视为合法会话 spec。

## 禁止

会话闸门 spec **仅**允许 `{application|system|company}/superpowers/specs/`；不得写在仓库根 `docs/` 下冒充闸门 spec。`docs/superpowers/specs/` 可用于 brainstorming 设计备忘（不入 gate 判定）。另禁止引用 `ideas/**`。

## 迁移（自 `superpower` 更名）

已有本地会话 spec 目录时：

```bash
mv application/superpower application/superpowers   # system/、company/ 同理
```

## 会话权威

当次会话维护的 spec 由 `sdx_session_state.session_specs` 记录；`sdx_gate_common` **优先**只检查这些文件，再回退全仓合法 `{docroot}/superpowers/specs/`。

## 与 spec-asd / docs-push 区分

| 类型 | 路径示例 | 用途 |
|------|----------|------|
| 会话闸门 spec | `{DOC_DIR}/superpowers/specs/2026-05-18-x-sdx-prd.md` | 用户总确认、`CONFIRMED`、钩子证据 |
| 规约 spec-asd | `application/requirements/…/specs/spec-asd-*.md` 或 `{DOC_DIR}/specs/spec-asd-*.md` | 架构规约，由 docs-push 推送 |
| legacy spec | `application/specs/spec-{yyMMdd}-*.md` | docs-push legacy |
