# 会话工作稿路径契约（Agent SSOT）

> **定位**：`{DOC_DIR}/superpowers/specs/` 的路径解析、合法落点与库外引用隔离。  
> **主线**：文档产出走参数向导 + `澄清 → 生成 → 烤干` 直写终稿（见 [CONVENTIONS.md](../rules/CONVENTIONS.md#artifact-gates)）；**不要求** HTML gate / `CONFIRMED` / 写前 hook。  
> **本文职责**：可选工作稿与 brainstorming 备忘的路径规则；非默认推进协议。

**最后更新**: 2026-07-18

---

## 合法路径

`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-<阶段后缀>.md`

- **DOC_DIR**：优先读目标工程 **`.docsconfig`** 的 `DOC_DIR=`（与 [config-bootstrap.sh](../scripts/config-bootstrap.sh) 一致）；无配置或无效时默认为 **`docs`**。
- **`application` / `system` / `company`** 仅当已在 `.docsconfig` 声明为 `DOC_DIR` 时合法。
- **中间目录**：固定 **`superpowers/specs/`**（通常 `.gitignore`，不入库）。
- **阶段后缀**：可选，便于区分主题（如 `-sdx-prd.md`、`-docs-indexing.md`、`-design.md`）；非闸门凭证。

### 用途（可选，非主线前置）

| 用途 | 说明 |
| --- | --- |
| 可选工作稿 | 会话暂存、路径清单草稿；**不**替代写前意图澄清或用户 `C` |
| brainstorming 备忘 | 如 `-design.md`；非正式 SSOT |

示例（`DOC_DIR=docs` 或无配置默认）：

- `docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-indexing.md`
- `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`

---

## DOC_DIR 解析

| 条件 | 有效 `{DOC_DIR}` |
| --- | --- |
| `.docsconfig` 且 `DOC_DIR=` 为 `application` / `system` / `company` / `docs` | 配置值（`.` 或空无效） |
| 无配置或 `DOC_DIR` 无效 | **`docs`** |

**跨域写入**：有效根为 `docs` 时，工作稿可在清单中列出任意仓库根相对终稿路径（如 `system/INDEX-GUIDE.md`）；工作稿文件本身仍落在 `docs/superpowers/specs/`。

参数向导与当前单元确认的**输出根**亦按上表解析（与 [docs-indexing/gates.md](../skills/docs-indexing/references/gates.md) 一致）。

---

## 路径合法性（实现侧）

若工具扫描该目录，仓库根相对路径须同时满足：

1. 形如 `{docroot}/superpowers/specs/...`，且 `{docroot}` 等于当前解析的 `DOC_DIR`。
2. 不含 `/requirements/`。
3. 以 `.md` 结尾。

未声明的 `application|system|company/superpowers/specs/`、`{docroot}/specs/`、`superpower/specs/`、requirements 内 `specs/` **均不合法**（会话工作稿语义下）。

---

## 禁止

- 不得将无 `superpowers/` 段的 `{DOC_DIR}/specs/`、拼写错误的 `superpower/specs/`，或 requirements 内 `specs/`，当作本契约下的会话工作稿根。
- 禁止引用 `ideas/**`。
- **库外不得引用具名 superpowers 文件**：除 `{docroot}/superpowers/**` 内部外，全仓不得指向 `…/superpowers/(specs|plans)/YYYY-MM-DD-*.md`。见 [CONVENTIONS.md](../rules/CONVENTIONS.md#superpowers-ref-isolation)。

---

## 遗留：HTML gate / hook（已移除）

历史上曾用会话 spec 的 `PENDING`/`CONFIRMED` 与 `sdx_gate_common` 作写前钩子证据。  
**脚本与测试已从本仓删除**；`agent/hooks.json` 的 `preToolUse` 为空。  
目标工程若仍引用旧 hook 路径，须刷新安装产物（见 [hooks/README.md](../hooks/README.md)）。  
技能 anti-patterns 仍禁止退回该主线。

---

## 与 spec-asd / docs-push 区分

| 类型 | 路径示例 | 用途 |
| --- | --- | --- |
| 会话工作稿 / 设计备忘 | `{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-*.md` | 可选暂存；非正式 SSOT |
| 规约 spec-asd | `application/requirements/…/specs/spec-asd-*.md` 或 `{DOC_DIR}/specs/spec-asd-*.md` | 架构规约；docs-push |
| legacy spec | `application/specs/spec-{yyMMdd}-*.md` | docs-push legacy |

---

## 迁移（目录名）

```bash
mv application/superpower application/superpowers   # 各 DOC_DIR 同理
```

无 `.docsconfig` 时，将会话工作稿迁至 **`docs/superpowers/specs/`**。  
有配置时与 **`DOC_DIR=`** 对齐。
