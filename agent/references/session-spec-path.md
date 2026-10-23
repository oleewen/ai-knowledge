# 会话工作稿路径契约（Agent SSOT）

> **定位**：`{DOC_DIR}/superpowers/specs/` 的路径解析、合法落点与库外引用隔离。  
> **本文职责**：可选工作稿与 brainstorming 备忘的路径规则；非默认推进协议。正式产物推进见 [CONVENTIONS.md](../rules/CONVENTIONS.md#artifact-gates)，不要求 HTML gate / `CONFIRMED` / 写前 hook；旧目标工程配置迁移见 [agent-install](../skills/agent-install/SKILL.md)。

**最后更新**: 2026-10-23

---

## 合法路径与 DOC_DIR

模式：`{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-<阶段后缀>.md`

| 条件 | 有效 `{DOC_DIR}` |
| --- | --- |
| `.docsconfig` 可读，`DOC_DIR` 通过通用字段校验 | 配置值；支持 `solution`、`team/manual` 等仓库相对子路径 |
| 无 `.docsconfig` | **`docs`** |
| 配置不可读，或 `DOC_DIR` 缺失 / 无效 | 停止落盘，说明问题并收口有效配置；不静默回退 |

- **DOC_DIR**：读取目标工程 **`.docsconfig`**，字段合法性复用 [docsconfig.sh](../scripts/lib/docsconfig.sh) 的 `docsconfig_validate_doc_dir`，不按知识层名称另设枚举。本文不补写配置；依赖完整配置的脚本仍执行自己的预检，无配置默认值不替代脚本配置。
- **中间目录**：固定 **`superpowers/specs/`**（通常 `.gitignore`，不入库）。  
- **阶段后缀**：可选（如 `-sdx-prd.md`、`-docs-indexing.md`、`-design.md`）；非闸门凭证。  
- **跨域写入**：有效根为 `docs` 时，工作稿清单可列任意仓库根相对终稿路径；工作稿文件本身仍落在 `docs/superpowers/specs/`。  
- 正式产物的输出根由各技能参数和通用配置解析决定；本文只定义会话稿落点。

| 用途 | 说明 |
| --- | --- |
| 可选工作稿 | 会话暂存、路径清单草稿；**不**替代写前意图澄清或用户 `C` |
| brainstorming 备忘 | 如 `-design.md`；非正式 SSOT |

示例（`DOC_DIR=docs` 或无配置默认）：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-indexing.md`、`…-design.md`。

---

## 合法性与禁止

工作稿的仓库根相对落点须同时满足：

1. 形如 `{docroot}/superpowers/specs/...`，且 `{docroot}` 等于当前解析的 `DOC_DIR`。  
2. 不含 `/requirements/`。  
3. 以 `.md` 结尾。
4. 写入前核实实际落点仍在目标仓库内，已有软链不得绕过边界。

与当前有效 `DOC_DIR` 不一致的根、`{docroot}/specs/`、`superpower/specs/`、requirements 内 `specs/` **均不合法**。这些是落点契约；引用扫描器不代替落点校验。

禁止：

- 不得将无 `superpowers/` 段的 `{DOC_DIR}/specs/`、拼写错误的 `superpower/specs/`，或 requirements 内 `specs/`，当作本契约下的会话工作稿根。  
- 禁止引用 `ideas/**`。  
- **库外不得引用具名 superpowers 文件**：除任意 `superpowers/` 目录内部外，全仓不得指向 `…/superpowers/(specs|plans)/YYYY-MM-DD-*.md`，不按根名区分。内部引用豁免不代表该目录是合法落点。见 [CONVENTIONS.md](../rules/CONVENTIONS.md#superpowers-ref-isolation)。

---

## 与架构规约区分

| 类型 | 路径示例 | 用途 |
| --- | --- | --- |
| 会话工作稿 / 设计备忘 | `{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-*.md` | 可选暂存；非正式 SSOT |
| 规约 spec-asd | `application/requirements/…/specs/spec-asd-*.md` 或 `{DOC_DIR}/specs/spec-asd-*.md` | 架构规约；[sdx-design 只读消费](../skills/sdx-design/references/central-spec-source.md) |
| legacy spec | `application/specs/spec-{yyMMdd}-*.md` | 历史规约输入；不再自动跨仓复制 |

---

## 迁移（目录名）

```bash
mv application/superpower application/superpowers   # 各 DOC_DIR 同理
```

无 `.docsconfig` 时，迁移目标为 **`docs/superpowers/specs/`**；有配置时先验证 `DOC_DIR`，再对齐落点。迁移前核对引用和已有文件，本文不授权自动搬移。
