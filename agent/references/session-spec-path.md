# 会话工作稿路径契约（Agent SSOT）

> **定位**：`{DOC_DIR}/superpowers/specs/` 的路径解析、合法落点与库外引用隔离。  
> **主线**：文档产出走参数向导 + `澄清 → 生成 → 烤干` 直写终稿（见 [CONVENTIONS.md](../rules/CONVENTIONS.md#artifact-gates)）；**不要求** HTML gate / `CONFIRMED` / 写前 hook。  
> **本文职责**：可选工作稿与 brainstorming 备忘的路径规则；非默认推进协议。  
> **遗留**：`gate_*` 与写前 hook 脚本已删；`agent/hooks.json` 的 `preToolUse` 为空。旧目标工程配置见 [agent-install](../skills/agent-install/SKILL.md)。技能 anti-patterns 仍禁止退回该主线。

**最后更新**: 2026-09-15

---

## 合法路径与 DOC_DIR

模式：`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-<阶段后缀>.md`

| 条件 | 有效 `{DOC_DIR}` |
| --- | --- |
| `.docsconfig` 且 `DOC_DIR=` 为 `application` / `system` / `company` / `docs` | 配置值（`.` 或空无效） |
| 无配置或 `DOC_DIR` 无效 | **`docs`** |

- **DOC_DIR**：优先读目标工程 **`.docsconfig`**（与 [docsconfig.sh](../scripts/lib/docsconfig.sh) 一致）。  
- **`application` / `system` / `company`** 仅当已声明为 `DOC_DIR` 时合法。  
- **中间目录**：固定 **`superpowers/specs/`**（通常 `.gitignore`，不入库）。  
- **阶段后缀**：可选（如 `-sdx-prd.md`、`-docs-indexing.md`、`-design.md`）；非闸门凭证。  
- **跨域写入**：有效根为 `docs` 时，工作稿清单可列任意仓库根相对终稿路径；工作稿文件本身仍落在 `docs/superpowers/specs/`。  
- 参数向导与当前单元确认的**输出根**亦按上表解析（与 [docs-indexing/gates.md](../skills/docs-indexing/references/gates.md) 一致）。

| 用途 | 说明 |
| --- | --- |
| 可选工作稿 | 会话暂存、路径清单草稿；**不**替代写前意图澄清或用户 `C` |
| brainstorming 备忘 | 如 `-design.md`；非正式 SSOT |

示例（`DOC_DIR=docs` 或无配置默认）：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-indexing.md`、`…-design.md`。

---

## 合法性与禁止

工具扫描时，仓库根相对路径须同时满足：

1. 形如 `{docroot}/superpowers/specs/...`，且 `{docroot}` 等于当前解析的 `DOC_DIR`。  
2. 不含 `/requirements/`。  
3. 以 `.md` 结尾。

未声明的 `application|system|company/superpowers/specs/`、`{docroot}/specs/`、`superpower/specs/`、requirements 内 `specs/` **均不合法**。

禁止：

- 不得将无 `superpowers/` 段的 `{DOC_DIR}/specs/`、拼写错误的 `superpower/specs/`，或 requirements 内 `specs/`，当作本契约下的会话工作稿根。  
- 禁止引用 `ideas/**`。  
- **库外不得引用具名 superpowers 文件**：除 `{docroot}/superpowers/**` 内部外，全仓不得指向 `…/superpowers/(specs|plans)/YYYY-MM-DD-*.md`。见 [CONVENTIONS.md](../rules/CONVENTIONS.md#superpowers-ref-isolation)。

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

无 `.docsconfig` 时，将会话工作稿迁至 **`docs/superpowers/specs/`**。有配置时与 **`DOC_DIR=`** 对齐。
