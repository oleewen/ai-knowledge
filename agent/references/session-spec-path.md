# 会话 spec 路径契约

## 合法路径

`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-<阶段后缀>.md`

- **DOC_DIR**：**优先**从目标工程仓库根 **`.docsconfig`** 的 `DOC_DIR=` 读取（与 [config-bootstrap.sh](../scripts/config-bootstrap.sh) / `validate_bootstrap_docsconfig` 一致）。
- **未找到 `.docsconfig` 或其中无有效 `DOC_DIR`**：默认为 **`docs`**。
- **`application` / `system` / `company` 仅当为 `.docsconfig` 中声明的 `DOC_DIR` 时才合法**；不得在未声明的文档根下创建会话 spec。
- **中间目录**：固定为 **`superpowers/specs/`**（会话中间稿；通常被 `.gitignore` 忽略，不入库）。
- **阶段后缀**：见 [CONVENTIONS.md](../rules/CONVENTIONS.md#artifact-gates) 总表（如 `-sdx-prd.md`、`-docs-indexing.md`、`-design.md`）。

### 统一落点

**闸门 spec**（用户总确认、`CONFIRMED`、钩子证据）与 **brainstorming 设计备忘**（`-design.md`）均落在 **`{DOC_DIR}/superpowers/specs/`**（`DOC_DIR` 按上表解析）。

示例（`.docsconfig` 中 `DOC_DIR=docs`）：

- `docs/superpowers/specs/2026-06-02-order-prd-sdx-prd.md`

示例（中央库 **无** `.docsconfig`，或 `DOC_DIR` 无效时默认 `docs`）：

- `docs/superpowers/specs/2026-06-15-index-p1-fix-docs-indexing.md`（可一次列出 `INDEX_GUIDE.md`、`system/INDEX_GUIDE.md` 等多条写入路径）
- `docs/superpowers/specs/2026-06-15-session-spec-path-design.md`（brainstorming 设计备忘）

## DOC_DIR 解析（与 hooks 一致）

| 条件 | 有效 `{DOC_DIR}` |
| --- | --- |
| 存在 `.docsconfig` 且 `DOC_DIR=application`（或 `system` / `company` / `docs`） | **配置值**（首段路径；`.` 或空视为无效） |
| 无 `.docsconfig`，或缺少 / 无效 `DOC_DIR` | **`docs`** |

**跨域写入**：当有效 `{DOC_DIR}` 为 `docs` 时，会话 spec 仍可在 §3 **写入路径清单**中列出任意仓库根相对终稿路径（如 `system/INDEX_GUIDE.md`）；spec 文件本身须落在 `docs/superpowers/specs/`。

## 实现判定（与 hooks 一致）

仓库根相对路径须同时满足：

1. 路径形如 `{docroot}/superpowers/specs/...`，且 `{docroot}` **等于**当前仓库 **`resolve_session_spec_doc_dir(repo)`**。
2. 路径中**不含** `/requirements/`。
3. 以 `.md` 结尾。

因此未在 `.docsconfig` 声明的 `application/`、`system/`、`company/` 下 `superpowers/specs/` **不合法**；`{docroot}/specs/`、`superpower/specs/`、requirements 内 `specs/` 亦均不合法。

## 禁止

- 不得将 `{DOC_DIR}/specs/`（无 `superpowers/` 段）、`{docroot}/superpower/specs/` 或 requirements 内 `specs/` 当作会话闸门 spec。
- 另禁止引用 `ideas/**`。

## 迁移

```bash
mv application/superpower application/superpowers   # 各 DOC_DIR 同理
```

- 无 `.docsconfig` 时：将会话 spec 迁至 **`docs/superpowers/specs/`**（含原 `application/` / `system/` 下仅用于放行的 spec）。
- 有 `.docsconfig` 时：spec 须与 **`DOC_DIR=`** 对齐（如 `DOC_DIR=system` → `system/superpowers/specs/`）。

## 会话权威

当次会话维护的 spec 由 `sdx_session_state.session_specs` 记录；`sdx_gate_common` **优先**只检查这些文件，再回退 **`iter_session_spec_files(repo)`**（仅扫描有效 `{DOC_DIR}/superpowers/specs/`）。

## 与 spec-asd / docs-push 区分

| 类型 | 路径示例 | 用途 |
|------|----------|------|
| 会话 spec（闸门 / 设计备忘） | `{DOC_DIR}/superpowers/specs/2026-05-18-x-sdx-prd.md` | 用户总确认、`CONFIRMED`、钩子证据；或 brainstorming `-design.md` |
| 规约 spec-asd | `application/requirements/…/specs/spec-asd-*.md` 或 `{DOC_DIR}/specs/spec-asd-*.md` | 架构规约，由 docs-push 推送 |
| legacy spec | `application/specs/spec-{yyMMdd}-*.md` | docs-push legacy |
