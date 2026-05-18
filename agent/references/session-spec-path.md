# 会话 spec 路径契约

## 合法路径

`{文档根}/specs/YYYY-MM-DD-<topic>-<阶段后缀>.md`

- **文档根**：与 INDEX 一致的一级目录，如 `application`、`system`、`company`。
- **阶段后缀**：见 [CONVENTIONS.md](../rules/CONVENTIONS.md#artifact-gates) 总表（如 `-sdx-prd.md`、`-docs-indexing.md`）。

## 实现判定（与 hooks 一致）

仓库根相对路径须同时满足：

1. 路径形如 `{docroot}/specs/...`（恰好一个分段后为 `specs/`）。
2. 路径中**不含** `/requirements/`。
3. 以 `.md` 结尾。

因此 `docs/superpowers/specs/*.md` **不**视为合法会话 spec；`application/requirements/.../MVP-Phase-*/specs/` **不**参与闸门枚举。

## 禁止

技能正文、模板、会话产出不得引用或链接 `docs/superpowers/**`、`ideas/**`。

## 会话权威

当次会话维护的 spec 由 `sdx_session_state.session_specs` 记录；`sdx_gate_common` **优先**只检查这些文件，再回退全仓合法 `*/specs/`。

## 与 spec-asd / docs-push 区分

| 类型 | 路径示例 | 用途 |
|------|----------|------|
| 会话闸门 spec | `application/specs/2026-05-18-x-sdx-prd.md` | 用户总确认、`CONFIRMED`、钩子证据 |
| 规约 spec-asd | `application/requirements/…/specs/spec-asd-*.md` | 架构规约，由 docs-push 推送 |
| legacy spec | `application/specs/spec-{yyMMdd}-*.md` | docs-push legacy |
