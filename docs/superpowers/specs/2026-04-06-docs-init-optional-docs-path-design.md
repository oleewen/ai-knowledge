# docs-init：`scope` 为 s/r/rs 时可选工程文档目录

**日期**: 2026-04-06  
**状态**: 待审阅  
**范围**: `scripts/docs-init.sh`，必要时 `scripts/README.md`、`scripts/docs-config.sh`（清单文案）。

---

## 1. 背景

当前 `docs-init` 将 **`<目标工程文档目录>`** 作为必选位置参数；`_validate_docs_and_target` 在无参数时直接 `usage` 退出。

用户诉求：**当 `--scope` 为 `skills(s)`、`rules(r)` 或 `rs` 时**，不要求传入工程文档目录；**仅在需要同步文档（`system/` → 文档树）或依赖「模式」落中央登记等逻辑时**，才要求该参数。

---

## 2. 何时必须提供 `<目标工程文档目录>`

| 条件 | 是否必须 | 理由 |
|------|----------|------|
| `scope` 为 `all` 或 `knowledge` | **是** | `install_system_to_docs` 需要 `CFG[docs_abs]` 作为拷贝目标根 |
| `mode` 为 `central` | **是** | `install_central` 依赖 `CFG[target_dir]`（工程根）、`CFG[docs_abs]`（登记与 manifest 语境）、`docs_rel_to_git_root`；`_central_knowledge_ready` 检查 `${docs_abs}/knowledge` |
| `scope` 为 `skills` / `rules` / `rs` **且** `mode` 为 `standalone`（默认） | **否** | 仅执行 `install_agent_*`，Agent 已改到 `$HOME` 下；不落地工程内文档 |

**说明**：「需要同步文档」对应 `all` / `knowledge`；「与 mode 相关」在本设计中明确为 **`central` 必须带文档目录**；`standalone` 下的 s/r/rs 可不传。

---

## 3. 未提供文档目录时的派生量（`docs_slash`）

Agent 树仍会执行 `_rewrite_agent_file`：将字面量 `system/` 替换为 `SDX_DOCS_SLASH`（即 `CFG[docs_slash]`）。无工程路径时无法计算「相对工程根的文档前缀」。

### 方案对比

| 方案 | 做法 | 优点 | 缺点 |
|------|------|------|------|
| **A（推荐）** | 未传文档目录时固定 `CFG[docs_slash]='system/'` | 与仓库模板常用前缀一致，实现简单 | 与用户真实工程目录名不一致时，技能内链接需后续手动改或使用带路径的再跑一遍 |
| **B** | 新增 `--docs-prefix=` 仅在 s/r/rs 无路径时生效 | 可一次指定 `docs/` 等 | 多一个选项与文档成本 |
| **C** | 要求环境变量 `SDX_DOCS_SLASH` | 自动化友好 | 隐式、易忘 |

**推荐**：**方案 A**，并在日志中 **warn 一次**：未指定工程文档目录，`system/` → 替换前缀默认为 `system/`，若需与真实文档树一致请传入 `<目标工程文档目录>` 或使用后续文档中的可选参数（若将来增加 B）。

---

## 4. 行为细节

### 4.1 校验顺序

`main` 中应先完成 **`_validate_sync_scope`**、**`_validate_mode`**（及 `_init_repo_root`），再调用 **按条件执行的文档路径校验**：

- 若 **`_requires_engine_docs_path`** 为真：行为与现 `_validate_docs_and_target` 一致（规范化 `docs_abs`、`target_dir`、`-r` 创建工程根等）。
- 若为假：`CFG[docs_abs]`、`CFG[target_dir]` 保持空字符串；不创建工程根。

### 4.2 `_compute_derived_paths`

- 若 `CFG[docs_abs]` 非空：现有逻辑 `CFG[docs_slash]="$(compute_docs_rel_slash "${CFG[target_dir]}" "${CFG[docs_abs]}")"`。
- 若为空：`CFG[docs_slash]='system/'`（或带尾斜杠形式与现 `compute_docs_rel_slash` 输出风格一致，建议统一为 `system/`）。

### 4.3 `central` 与无路径组合

在 **`mode=central` 且未提供文档目录** 时：**报错退出**，明确提示：central 模式必须指定 `<目标工程文档目录>`。（不在此引入「无路径 central」的复杂语义。）

### 4.4 `_print_checklist` / `sdx_post_init_checklist`

- 当未指定 `docs_abs`：完成横幅可写 `目标: （未指定工程文档目录，仅更新用户主目录 Agent 配置）`；`sdx_post_init_checklist` 传入空或占位时，由 `docs-config.sh` 内函数处理——**建议**传入字面 `-` 或保留调用但首行说明「本次未落地工程文档，以下清单项仅部分适用」，避免误导。最小实现：`_print_checklist` 分支打印不同横幅；`sdx_post_init_checklist` 仍可用 `"<未指定工程文档目录>"` 作占位，与现有函数签名兼容。

### 4.5 `usage` 与示例

- 说明位置参数在 **standalone + scope 为 s/r/rs** 时可省略。
- 示例增加：`docs-init --scope=skills`、`docs-init --scope=rs`（无路径）。

### 4.6 与 `--dry-run` 的关系

无路径时行为一致：仅预览 Agent 安装到 `$HOME` 的步骤，不依赖工程目录存在。

---

## 5. 错误处理与测试要点

- `scope=all|knowledge` 且无路径 → 报错并 `usage`。
- `mode=central` 且无路径 → 报错（明确与 standalone s/r/rs 区分）。
- `scope=skills` 且无路径 → 成功，`docs_slash` 为默认 `system/`，有一条 warn（推荐）。

---

## 6. 自检

- 与既有「Agent 安装在 `$HOME`」行为兼容，不冲突。
- 无 TBD：默认前缀取 `system/`。
- 单实现批次可完成。

---

## 7. 实现后

用户审阅通过后，用 **writing-plans** 拆任务并改 `docs-init.sh` / 文档。
