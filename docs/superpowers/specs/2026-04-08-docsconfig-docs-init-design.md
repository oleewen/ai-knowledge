# `.docsconfig` 与 `docs-init` 整合设计（方案甲）

**日期**: 2026-04-08  
**状态**: 待实施  
**范围**: 将原 `.agent/scripts/sdx-doc-root.sh` 的文档根推断合并入 `scripts/docs-init.sh`；在目标工程仓库根落盘 `.docsconfig`；运行时各 `validate-*.sh` 仅从 `.docsconfig` 读取 `REPO_ROOT` 与 `DOC_ROOT`；删除 `sdx-doc-root.sh` 与 `sdx-validate-bootstrap.sh`；缺失配置时采用策略 **D**（提示并确认执行仅写配置的 `docs-init`）。

---

## 1. 背景与目标

### 1.1 现状

- **`.agent/scripts/sdx-doc-root.sh`**：解析文档树首段并输出 **`sdx_resolve_repo_doc_root`**（等价于既有变量 **`REPO_DOC_ROOT`** 的绝对路径语义）。
- **`.agent/scripts/sdx-validate-bootstrap.sh`**：为各 skill 的 `validate-*.sh` 加载上述逻辑；缺失时提供极简兜底。
- **`scripts/docs-init.sh`**：向目标工程同步模板时已知 **`CFG[docs_abs]`**（目标文档目录）与 **`git_root_path`** 等，但**未**将「文档根 / 仓库根」持久化为目标工程侧配置文件。

### 1.2 目标

1. **单一运行时事实源**：目标工程仓库根下的 **`.docsconfig`**，供 validate、链接校验等读取，避免在运行时重复分散推断。
2. **推断写入合并进 `docs-init`**：实现放在 **`scripts/`** 侧（方案甲），由 `docs-init` 在适当时机调用并写入；删除 `.agent` 下两脚本。
3. **策略 D**：若运行时缺少 `.docsconfig`，**提示用户**并**确认**是否执行 `docs-init` 的「仅写 `.docsconfig`」模式；非交互环境打印可复制的命令并失败退出。
4. **语义确认（已采纳）**：
   - **`DOC_ROOT`** 由 §3.2 推断链确定；**`<目标工程文档目录>`** 仅作为 **`probe_base`**（目录探测），**不**强制等于最终 `DOC_ROOT`。
   - 新增 **`--scope=config`**（缩写 **`c`**，与 `all|knowledge|skills|rules|rs` 并列）：**仅**初始化/更新 `.docsconfig`，不拷贝模板、不安装 Agent skills/rules。

### 1.3 非目标

- 不改变 `docs-init` 对 **模板仓库根**（现 **`CFG[repo_root]`**，指向 ai-knowledge 克隆）的职责；本设计在叙述中用 **「模板仓库根」** 与 **「目标工程 REPO_ROOT」** 区分，避免混淆。
- 不在本规格中规定下游 Python/其他语言的重写，仅约定 **`.docsconfig` 文件内字段**与导出变量语义一致。
- **运行时**（`validate-*.sh`、`.docsconfig` 引导逻辑）**不支持**通过**显式环境变量**指定「`.docsconfig` 路径」或「目标仓库根」——必须以 §4.1 的算法从 **`$PWD` / `$SCRIPT_DIR` / 向上查找** 解析，避免与「文件即 SSOT」双轨并存。**`docs-init` 写入**时的推断顺序见 §3.2（**不再**依赖 `REPO_DOC_ROOT` / `SDX_DOC_ROOT` / `.sdx-doc-root`；改由 **CLI → 既有 `.docsconfig` → 目录探测 → 默认 `docs`**）。

---

## 2. `.docsconfig` 格式与字段

### 2.1 位置

- **路径**：`$TARGET_REPO_ROOT/.docsconfig`，其中 **`TARGET_REPO_ROOT`** 为**目标工程**的 Git 仓库根目录（见 §3.3）。

### 2.2 语法

- **推荐**：每行 `KEY=value`，`#` 行首为注释；使用 UTF-8。
- **必填键**：
  - **`REPO_ROOT`**：目标工程仓库根绝对路径（与现各 `validate-*.sh` 中 `git rev-parse --show-toplevel` 语义对齐）。
  - **`DOC_ROOT`**：文档树根目录绝对路径；**语义等同于**既有 **`REPO_DOC_ROOT`**（脚本可继续 `export REPO_DOC_ROOT="$DOC_ROOT"` 以兼容现有代码）。

### 2.3 写入与更新策略

- **`docs-init` 在同时满足以下条件时写入或覆盖 `.docsconfig`**（非 dry-run）：
  - 本次调用提供了 **`<目标工程文档目录>`**（即 **`CFG[docs_abs]`** 非空）；且
  - **`--scope`** 为 **`config`**（或 **`c`**），或 **`all` / `knowledge`** 等会落地工程文档的 scope（与「本次安装的文档根」保持一致）。
- **仅 **`--scope=skills` / `rules` / `rs`** 且未提供 `<目标工程文档目录>`**：**不写** `.docsconfig`（与现逻辑一致：无稳定文档根）。
- **`--dry-run`**：**不写** `.docsconfig`。

---

## 3. `docs-init` 行为扩展

### 3.1 新增 `--scope=config`

- **CLI**：**`--scope=config`** 与 **`--scope=c`** 等价（`c` 仅表示 **config**，与其它 scope 首字母不冲突）。
- **含义**：只执行 **§3.2** 的推断与 **`.docsconfig` 落盘**，不执行 `install_system_to_docs`、`install_agent_skills`、`install_agent_rules`、`install_central`。
- **参数要求**：必须提供 **`<目标工程文档目录>`**（作为 **`probe_base`**）。
- **与 central / type**：`--scope=config` 下**不**要求完成 central 登记或 `knowledge/` 存在性等；若与 `--mode=central` 等同场传入，以「仅写配置」为优先，**不**执行登记（建议在实现中拒绝组合或明确文档说明，推荐 **拒绝非法组合** 以免误读）。

### 3.2 推断顺序（写入 `.docsconfig` 时）

在已按 §3.3 得到 **`TARGET_REPO_ROOT`** 的前提下，确定本次落盘的 **`REPO_ROOT`** 与 **`DOC_ROOT`**（均为绝对路径；**`REPO_ROOT`** 与 **`TARGET_REPO_ROOT`** 应一致）：

1. **CLI `--doc-root=`**（**须**在 `docs-init` 中新增）：若指定，则按首段规范化后得到文档树首段 **`seg`**，令 **`REPO_ROOT=$TARGET_REPO_ROOT`**，**`DOC_ROOT=$TARGET_REPO_ROOT/$seg`**（路径规范化）；**不再**执行下列 2–4。
2. **既有 `$TARGET_REPO_ROOT/.docsconfig`**：若 **未** 使用步骤 1，且该文件**已存在**、可解析，则读取其中的 **`REPO_ROOT`**、**`DOC_ROOT`**；二者均合法时**直接采用**为本次推断结果，**不再**执行下列 3–4。若文件内 **`REPO_ROOT`** 与 §3.3 的 **`TARGET_REPO_ROOT`** 不一致，**推荐**落盘时以 **`TARGET_REPO_ROOT`** 为准校正 `REPO_ROOT` 字段。
3. **`probe_doc_segment(probe_base)`**（目录探测）；**`probe_base`** 为规范化后的 **`<目标工程文档目录>`**。得到首段 **`seg`** 后：**`REPO_ROOT=$TARGET_REPO_ROOT`**，**`DOC_ROOT=$TARGET_REPO_ROOT/$seg`**（规范化）。
4. **默认首段 `docs`**：在步骤 3 中若需回退默认首段，则 **`seg=docs`**，同上拼接得 **`DOC_ROOT`**。

**摘要**：**`--doc-root` > 既有 `.docsconfig` 内 `REPO_ROOT`/`DOC_ROOT` > 目录探测 > 默认 `docs`**。

**说明**：旧版 **`REPO_DOC_ROOT` / `SDX_DOC_ROOT` / `.sdx-doc-root`** 不再参与本链；迁移依赖 **步骤 2** 的既有 **`.docsconfig`**，或 **`--doc-root`**，或重新执行 **`docs-init`** 生成新文件。

### 3.3 `REPO_ROOT`（目标工程）解析

- **默认**：`TARGET_REPO_ROOT="$(git -C "<目标工程文档目录>" rev-parse --show-toplevel 2>/dev/null)"`。
- **若不在 Git 仓库内或命令失败**：规范可二选一并在实现中写死：**(a)** 失败并提示；或 **(b)** 回退为 **`dirname` 链**至含 `.docsconfig` 预定位置——**推荐 (a)**，与「仓库根」定义一致。

### 3.4 实现位置（方案甲）

- **推断与探测**：实现为 **`scripts/docs-config.sh` 内的函数**（如 `sdx_normalize_doc_root_segment`、`probe_doc_segment`、`sdx_resolve_repo_doc_root` 等，命名以实现为准），与既有配置/校验函数同文件维护；**不**另建 `sdx-doc-root-resolve.sh` 等平行文件；**不**留在 `.agent/scripts/`。**`docs-init.sh`** 已 `source docs-config.sh`，写入 `.docsconfig` 时直接调用上述函数。
- **`.agent`**：仅保留「**读取** `.docsconfig`」的薄封装（见 §4），不再保留完整推断链。

---

## 4. 运行时读取与 `validate-*` 改造

### 4.1 正常路径

#### 4.1.1 解析 `TARGET_REPO_ROOT`（多宿主 `.agent`）

技能脚本可能位于 **`REPO_ROOT/.agent/skills/...`**（仓内），也可能位于 **`~/.../skills/...`**（用户目录安装）。**不得**仅用 `git -C "$SCRIPT_DIR"` 取顶：装在 `~/` 时常不在业务仓库内，须以**工作区**为主。

**不支持**通过环境变量（如 `DOCS_CONFIG_FILE`、`DOCS_CONFIG_ROOT` 等）显式指定路径或仓库根。

**建议解析顺序**（实现须与此等价）：

1. **`git -C "${PWD}" rev-parse --show-toplevel 2>/dev/null`** — Agent 执行 Skill 时 **`$PWD` 多为工作区根**，与「技能装在 `~/`」场景一致。
2. **`git -C "${SCRIPT_DIR}" rev-parse --show-toplevel 2>/dev/null`** — 技能在 **`REPO_ROOT/.agent/...`** 时通常有效。
3. **自 `$PWD` 向上**（逐层父目录，上限 N 层）查找 **`/.docsconfig`**，命中则所在目录即为 **`TARGET_REPO_ROOT`**。
4. 仍无法确定 → **§4.2** 策略 D。

得到 **`TARGET_REPO_ROOT`** 后：**若存在 `$TARGET_REPO_ROOT/.docsconfig`**：source 或逐行解析，导出 **`REPO_ROOT`**、**`DOC_ROOT`**（并 **`export REPO_DOC_ROOT="$DOC_ROOT"`** 以兼容 Python 与旧注释）。文件内 **`REPO_ROOT`** 可与步骤 1–3 解析结果交叉校验（不一致时以实现约定为准：或警告、或以文件为准，须在实现 PR 中写死一种）。

### 4.2 缺失 `.docsconfig`（策略 D）

| 场景 | 行为 |
|------|------|
| **交互式 TTY** | 打印说明：缺少 `.docsconfig`，建议运行 `docs-init --scope=config <目标工程文档目录>`（或 **`--scope=c`**）；询问是否**立即执行**。用户确认后，以非 dry-run 调用上述命令（需能定位 `docs-init.sh`：相对模板仓库、`PATH` 或文档约定）。**不得**在无人确认时静默写盘。 |
| **非交互（无 TTY / CI）** | 打印**完整可复制**的 `docs-init` 示例命令（含 `config` / `c`）；**退出非 0**；不等待输入。 |

### 4.3 替换已删除脚本

- **删除**：**`.agent/scripts/sdx-doc-root.sh`**、**`.agent/scripts/sdx-validate-bootstrap.sh`**。
- **新增**：**`.agent/scripts/sdx-docsconfig-bootstrap.sh`**（名称可调整）：仅负责 **定位 `.docsconfig`**、**导出变量**、**§4.2 的 D 流程**；**不含** `sdx_resolve_repo_doc_root` 的完整推断实现。
- **`sdx_find_repo_root_from_path`**：不再以「存在 `sdx-doc-root.sh`」为锚；改为向上查找 **`.docsconfig`**，或 **`.git` + 仓库根**（与各 validate 默认一致）。具体锚点以**实现 PR** 为准，但须在 **§6** 自检清单中列明。

### 4.4 `validate-agent-md-links.sh`

- 先按 §4.1 加载 **`REPO_ROOT`**、**`DOC_ROOT`/`REPO_DOC_ROOT`**；缺失则 §4.2。
- 跨 `.agent` 链接判定逻辑不变，仅变量来源改为 **`.docsconfig`**。

---

## 5. 文档与引用更新

- **`scripts/README.md`**：`doc_root` 章节改为描述 **`.docsconfig`** 与 **`docs-init --scope=config`**；删除对已删脚本的「单一事实来源」表述。
- **`.agent/README.md`**：更新 `.agent/scripts/` 说明。
- **`docs/superpowers/specs/2026-04-07-agent-external-refs-path-resolution-design.md`**：在后续 PR 中增加「已由 `.docsconfig`  supersede 运行时推断」的指向段，避免长期双轨叙述冲突。
- **各 skill `validate-*.sh` 注释**：指向新 bootstrap 文件与 `.docsconfig`。

---

## 6. 实施自检（占位符与一致性）

- [ ] `.docsconfig` 键名与 `export REPO_DOC_ROOT` 兼容路径已全部核对。
- [ ] `docs-init` 中模板 **`CFG[repo_root]`** 与目标 **`REPO_ROOT`** 变量命名在代码中无混用。
- [ ] `--scope=config` 与 `--mode=central` / `install_central` 组合行为已定义。
- [ ] 非交互失败码与 CI 文档一致。
- [ ] 删除脚本后无残留 `source` 路径。
- [ ] 运行时解析 `.docsconfig` 未引入「显式环境变量覆盖路径」能力；与 §4.1.1 一致。

---

## 7. 参考

- 现行推断实现：`.agent/scripts/sdx-doc-root.sh`（实施时迁移至 `scripts/` 后删除）。
- 初始化入口：`scripts/docs-init.sh`、`scripts/docs-config.sh`。
- 相关历史规格：`docs/superpowers/specs/2026-04-07-agent-external-refs-path-resolution-design.md`。
