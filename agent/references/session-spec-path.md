# 会话 spec 路径契约

## 合法路径

`{DOC_DIR}/superpowers/YYYY-MM-DD-<topic>-<阶段后缀>.md`

- **DOC_DIR / 文档根**：与 INDEX 一致的一级目录，如 `application`、`system`、`company`。
- **中间目录**：固定为 **`superpowers/`**（会话闸门中间稿；通常被 `.gitignore` 忽略，不入库）。
- **阶段后缀**：见 [CONVENTIONS.md](../rules/CONVENTIONS.md#artifact-gates) 总表（如 `-sdx-prd.md`、`-docs-indexing.md`）。

示例：

- `application/superpowers/2026-06-02-order-prd-sdx-prd.md`
- `system/superpowers/2026-06-02-billing-docs-distill.md`

## 实现判定（与 hooks 一致）

仓库根相对路径须同时满足：

1. 路径形如 `{docroot}/superpowers/...`（`docroot` 须为 `application`、`system` 或 `company`）。
2. 路径中**不含** `/requirements/`。
3. 以 `.md` 结尾。

`{docroot}/specs/` **不再**作为会话闸门 spec 目录；`application/requirements/.../MVP-Phase-*/specs/` **不**参与闸门枚举。

## 禁止

技能正文、模板、会话产出不得引用或链接仓库根下 `docs/superpowers/**`、`ideas/**`（与 `{DOC_DIR}/superpowers/` 无关）。

## 会话权威

当次会话维护的 spec 由 `sdx_session_state.session_specs` 记录；`sdx_gate_common` **优先**只检查这些文件，再回退全仓合法 `*/superpowers/`。

## 与 spec-asd / docs-push 区分

| 类型 | 路径示例 | 用途 |
|------|----------|------|
| 会话闸门 spec | `{DOC_DIR}/superpowers/2026-05-18-x-sdx-design.md` | 用户总确认、`CONFIRMED`、钩子证据 |
| 规约 spec-asd | `{DOC_DIR}/specs/spec-asd-*.md` 或 `requirements/…/specs/spec-asd-*.md` | 架构规约，由 `/sdx-architect` 与 docs-push 管理 |
| legacy spec | `{DOC_DIR}/specs/spec-{yyMMdd}-*.md` | docs-push legacy |
