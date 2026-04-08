# `.docsconfig` 与 `docs-init` 整合设计（方案甲）

**日期**: 2026-04-08  
**状态**: 待实施  
**范围**: 将 **`REPO_ROOT`** / **`DOC_DIR`** 从 **`DOC_ROOT`** 的推算写入合并入 `scripts/docs-init.sh`（**`DOC_ROOT`** 仅初始化显式指定，见 §1.2）；在目标工程仓库根落盘 `.docsconfig`；运行时各 `validate-*.sh` 从 `.docsconfig` 读取 **`DOC_ROOT`**、**`REPO_ROOT`**（由 **`DOC_ROOT`** 推算）、**`DOC_DIR`**；删除 `sdx-doc-root.sh` 与 `sdx-validate-bootstrap.sh`；**运行时**缺失 `.docsconfig` 时采用策略 **D**（见 §4.2）；**`docs-init.sh` 执行时**若缺少 `.docsconfig`，在符合写入条件时**直接**落盘，**无须**用户确认（见 §3.0）。

---

## 1. 背景与目标

### 1.1 现状

- `**.agent/scripts/sdx-doc-root.sh`**：解析文档树首段并输出 `**sdx_resolve_repo_doc_root**`（等价于既有变量 `**REPO_DOC_ROOT**` 的绝对路径语义）。
- `**.agent/scripts/sdx-validate-bootstrap.sh**`：为各 skill 的 `validate-*.sh` 加载上述逻辑；缺失时提供极简兜底。
- `**scripts/docs-init.sh**`：向目标工程同步模板时已知 `**CFG[docs_abs]**`（目标文档目录）与 `**git_root_path**` 等，但**未**将「文档根 / 仓库根」持久化为目标工程侧配置文件。

### 1.2 目标

1. **单一运行时事实源**：目标工程仓库根下的 `**.docsconfig`**，供 validate、链接校验等读取，避免在运行时重复分散推断。
2. **推断写入合并进 `docs-init`**：实现放在 `**scripts/**` 侧（方案甲），由 `docs-init` 在适当时机调用并写入；删除 `.agent` 下两脚本。
3. **策略 D（仅 `validate-*` / 运行时 bootstrap）**：若缺少 `.docsconfig`，**提示用户**并**确认**是否代为执行 `docs-init` 的「仅写 `.docsconfig`」模式；非交互环境打印可复制的命令并失败退出（§4.2）。
4. `**docs-init.sh` 与确认**：执行 `**docs-init.sh`** 时，若目标工程侧**尚无** `.docsconfig`，只要本次调用满足 §2.3 的写入条件（非 dry-run、已提供 `<目标工程文档目录>` 等），则按 §3.2 **直接**推断并写入，**无须**用户二次确认；**不**适用策略 D 的交互确认条款。
5. **语义确认（已采纳）**：
  - **`DOC_ROOT`**：**仅在初始化时指定**，**不支持推断**。来源仅限：**(a)** **`docs-init.sh`** 调用时显式传入的 **`<目标工程文档目录>`**（规范化后的绝对路径）；或 **(b)** **`--doc-root=`** 与 §3.2 步骤 1 组合得到的绝对路径（**不再**等于未用 `(b)` 时的传入路径本身）。**禁止**目录探测、默认 `docs` 路径、环境变量等推断 **`DOC_ROOT`**。语义上对应历史上的 **`REPO_DOC_ROOT`**。运行时（`validate-*` 等）**只读** **`.docsconfig`** 中已写入的 **`DOC_ROOT`**，**不**重新推断。**禁止** **`export REPO_DOC_ROOT`** / **`export DOC_ROOT`**；见 §2.2.2。
  - **`REPO_ROOT`**：**在 `DOC_ROOT` 之后确定**，由 **`DOC_ROOT`** **推算**得到的**目标工程 Git 仓库根**绝对路径（典型：`git -C "$DOC_ROOT" rev-parse --show-toplevel`）；与 **`.docsconfig` 文件所在仓库根**一致。
  - **`DOC_DIR`**：由 **`DOC_ROOT`** 与已确定的 **`REPO_ROOT`** **推算**——满足 **`REPO_ROOT` + `DOC_DIR` = `DOC_ROOT`**（路径语义：`realpath "$REPO_ROOT/$DOC_DIR"` = `realpath "$DOC_ROOT"`）。POSIX 相对段、**无**前导 `/`（如 `docs`、`application`）。用于模板「相对工程根」前缀（如原 `docs_slash`）时以 **`DOC_DIR`**（及约定尾斜杠）为准。
  - **`<目标工程文档目录>`**（`CFG[docs_abs]`）经规范化即为落盘之 **`DOC_ROOT`**（除非 §3.2 步骤 1 **`--doc-root`** 覆盖）。**废弃** **`probe_base`** 与 **`probe_doc_segment`** 目录探测。
  - 新增 **`--scope=config`**（缩写 **`c`**，与 `all|knowledge|skills|rules|rs` 并列）：**仅**初始化/更新 `.docsconfig`，不拷贝模板、不安装 Agent skills/rules。

### 1.3 非目标

- 不改变 `docs-init` 对 **模板仓库根**（现 `**CFG[repo_root]`**，指向 ai-knowledge 克隆）的职责；本设计在叙述中用 **「模板仓库根」** 与 **「目标工程 REPO_ROOT」** 区分，避免混淆。
- 不在本规格中规定下游 Python/其他语言的重写，仅约定 **`.docsconfig` 文件内字段语义**与 §2.2.2 的传参约定。
- **运行时**（`validate-*.sh`、`.docsconfig` 引导逻辑）**不支持**通过**显式环境变量**指定「`.docsconfig` 路径」或「目标仓库根」——必须以 §4.1 的算法从 **`$PWD` / `$SCRIPT_DIR` / 向上查找** 解析，避免与「文件即 SSOT」双轨并存。**`docs-init` 写入**见 §3.2：**`DOC_ROOT`** 仅初始化显式指定（**无**默认推断）；**`REPO_ROOT`** / **`DOC_DIR`** 由 **`DOC_ROOT`** 推算；**不再**依赖 `REPO_DOC_ROOT` / `SDX_DOC_ROOT` / `.sdx-doc-root`；**无** `probe_base` / **`probe_doc_segment`**。

---

## 2. `.docsconfig` 格式与字段

### 2.1 位置

- **路径**：`$TARGET_REPO_ROOT/.docsconfig`，其中 `**TARGET_REPO_ROOT`** 为**目标工程**的 Git 仓库根目录（见 §3.3）。

### 2.2 语法

- **推荐**：每行 `KEY=value`，`#` 行首为注释；使用 UTF-8。
- **必填键**（逻辑顺序：**先 `DOC_ROOT`，再由此推算 `REPO_ROOT` 与 `DOC_DIR`**）：
  - **`DOC_ROOT`**：仅来自初始化时显式指定（**`CFG[docs_abs]`** 或 **`--doc-root`** + §3.2 步骤 1），**不**经推断；见 §1.2。
  - **`REPO_ROOT`**：由 **`DOC_ROOT`** 推算的**仓库根**绝对路径（与 `git -C "$DOC_ROOT" rev-parse --show-toplevel` 语义对齐）。
  - **`DOC_DIR`**：由 **`DOC_ROOT`** 与 **`REPO_ROOT`** 推算，使 **`REPO_ROOT` + `DOC_DIR` = `DOC_ROOT`**（`realpath "$REPO_ROOT/$DOC_DIR"` 与 `realpath "$DOC_ROOT"` 一致）。相对路径、无前导 `/`。若知识库根与仓库根重合（少见），**`DOC_DIR`** 为 **`.`**（实现须统一，禁止与空字符串混用）。

### 2.2.1 三者关系

- **推导顺序**：**`DOC_ROOT`**（**仅**初始化显式给定，见 §1.2）→ **`REPO_ROOT`** = 由 **`DOC_ROOT`** 解析 Git 顶层 → **`DOC_DIR`** 由二者推算，满足 **`REPO_ROOT` + `DOC_DIR` = `DOC_ROOT`**。
- 写入 `.docsconfig` 时：按 §3.2 先定 **`DOC_ROOT`**，再算 **`REPO_ROOT`**、**`DOC_DIR`** 并一并落盘（避免手填不一致）。

### 2.2.2 禁止使用 `export`（避免多仓库环境串扰）

- **不**将 **`REPO_ROOT`** / **`DOC_ROOT`** / **`DOC_DIR`**（及历史上的 **`REPO_DOC_ROOT`** 别名）通过 **`export`** 写入继承给交互式 Shell 或跨会话全局环境。
- **允许**：在**当前脚本进程**内使用普通赋值；调用子进程（如 `python3`）时使用**单次命令前缀**（建议顺序 **`DOC_ROOT`**、**`REPO_ROOT`**、**`DOC_DIR`**）：`DOC_ROOT=... REPO_ROOT=... DOC_DIR=... python3 ...`，或让子进程**自行读取** `.docsconfig`。
- **迁移**：既有脚本若仍出现符号 **`REPO_DOC_ROOT`**，应在实现中逐步改为读取 **`DOC_ROOT`** 字段或上述前缀传参，**不**再依赖已 export 的环境变量。

### 2.3 写入与更新策略

- `**docs-init` 在同时满足以下条件时写入或覆盖 `.docsconfig**`（非 dry-run）：
  - 本次调用提供了 `**<目标工程文档目录>**`（即 `**CFG[docs_abs]**` 非空）；且
  - `**--scope**` 为 `**config**`（或 `**c**`），或 `**all` / `knowledge**` 等会落地工程文档的 scope（与「本次安装的文档根」保持一致）。
- **仅 `--scope=skills` / `rules` / `rs` 且未提供 `<目标工程文档目录>`**：**不写** `.docsconfig`（与现逻辑一致：无稳定文档根）。
- `**--dry-run`**：**不写** `.docsconfig`。

---

## 3. `docs-init` 行为扩展

### 3.0 缺少 `.docsconfig` 时的执行策略

- 与 §4.2 **策略 D**（运行时缺文件、依赖用户确认是否调 `docs-init`）**不同**：用户**已主动执行** `docs-init.sh` 时，视为授权写入；若 **`$TARGET_REPO_ROOT/.docsconfig`** 尚不存在，在满足 §2.3 时**默认**执行 §3.2 **写入**并**创建/落盘**（**`DOC_ROOT`** 仍须按 §3.2 **显式**来源，**不**推断），**不**再弹出「是否创建 `.docsconfig`」类确认（`--dry-run` 仍只预览、不写盘）。

### 3.1 新增 `--scope=config`

- **CLI**：`**--scope=config`** 与 `**--scope=c**` 等价（`c` 仅表示 **config**，与其它 scope 首字母不冲突）。
- **含义**：只执行 **§3.2** 的 **`DOC_ROOT`** 显式写入与 **`.docsconfig` 落盘**，不执行 `install_system_to_docs`、`install_agent_skills`、`install_agent_rules`、`install_central`。
- **参数要求**：必须提供 **`<目标工程文档目录>`**（规范化后为文档树根绝对路径，与 **`DOC_ROOT`** 对齐；见 §3.2）。
- **与 central / type**：`--scope=config` 下**不**要求完成 central 登记或 `knowledge/` 存在性等；若与 `--mode=central` 等同场传入，以「仅写配置」为优先，**不**执行登记（建议在实现中拒绝组合或明确文档说明，推荐 **拒绝非法组合** 以免误读）。

### 3.2 写入顺序（写入 `.docsconfig` 时）

**`DOC_ROOT`** **仅**由下列步骤 **(1)(3)** **显式**得到，或步骤 **(2)** 从已落盘文件**读取**（非推断）；**禁止**无参默认、`docs` 兜底或其它推断 **`DOC_ROOT`**。

先确定 **`DOC_ROOT`**（如上），再由 §3.3 用 **`DOC_ROOT`** 解析 **`TARGET_REPO_ROOT`**，并令落盘 **`REPO_ROOT`** = **`TARGET_REPO_ROOT`**。最后按 §2.2.1 算 **`DOC_DIR`**。细节：

1. **CLI `--doc-root=`**（**须**在 `docs-init` 中新增）：若指定，须**同时**提供 **`<目标工程文档目录>`** 以解析 **`TARGET_REPO_ROOT`**（`git -C "<路径>"`），再按首段规范化得 **`seg`**，令 **`DOC_ROOT=$TARGET_REPO_ROOT/$seg`**（规范化）；再 **`REPO_ROOT="$(git -C "$DOC_ROOT" rev-parse --show-toplevel 2>/dev/null)"`**；**`DOC_DIR`** 由 §2.2.1；**不再**执行下列 2–3。
2. **既有 `$TARGET_REPO_ROOT/.docsconfig`**：若 **未** 使用步骤 1，且该文件**已存在**、可解析，则**读取**已初始化的 **`DOC_ROOT`**、**`REPO_ROOT`**、**`DOC_DIR`**（若缺 **`DOC_DIR`** 则由 **`REPO_ROOT`**+**`DOC_ROOT`** 补算）。三者与 §2.2.1 一致时**直接采用**；**不再**执行步骤 3。若文件内 **`REPO_ROOT`** 与 **`git -C "$DOC_ROOT" …`** 不一致，**推荐**以 **由 `DOC_ROOT` 重算的 Git 顶层**为准校正 **`REPO_ROOT`** 并**重算** **`DOC_DIR`**。
3. **否则**（首次写入且无步骤 1）：将规范化后的 **`<目标工程文档目录>`** **直接作为** **`DOC_ROOT`**；再 **`REPO_ROOT="$(git -C "$DOC_ROOT" rev-parse --show-toplevel 2>/dev/null)"`**。再按 §2.2.1 计算 **`DOC_DIR`**。若本次**未**提供 `<目标工程文档目录>`，**不得**写入 **`DOC_ROOT`**（**不**使用默认 `docs`、**不**推断）。**不**使用 **`probe_base`** / **`probe_doc_segment`**。

**摘要**：**`DOC_ROOT`** = **`--doc-root` 显式组合** 或 **读取既有 `.docsconfig`** 或 **用户传入路径**；**无**默认推断；**`REPO_ROOT`** / **`DOC_DIR`** 由 **`DOC_ROOT`** 推算。

**与模板替换**：相对工程根的知识库前缀以 **`DOC_DIR`** 为准（实现可导出为带尾斜杠形式，如 `docs/`，与 **`docs_slash`** 一类变量对齐）。

**说明**：旧版 **`REPO_DOC_ROOT` / `SDX_DOC_ROOT` / `.sdx-doc-root`** 不再参与本链；迁移依赖 **步骤 2** 的既有 **`.docsconfig`**，或 **`--doc-root`**，或重新执行 **`docs-init`** 生成新文件。

### 3.3 `REPO_ROOT`（目标工程）解析

- **默认**：在 **`DOC_ROOT`** 已确定后，由 **`DOC_ROOT`** 推算仓库根：`TARGET_REPO_ROOT="$(git -C "$DOC_ROOT" rev-parse --show-toplevel 2>/dev/null)"`；落盘 **`REPO_ROOT`** = **`TARGET_REPO_ROOT`**。（等价地，亦可先规范化传入的 **`<目标工程文档目录>`** 为 **`DOC_ROOT`**，再执行同上 `git -C`。）
- **若不在 Git 仓库内或命令失败**：规范可二选一并在实现中写死：**(a)** 失败并提示；或 **(b)** 回退为 **`dirname` 链**至含 `.docsconfig` 预定位置——**推荐 (a)**，与「仓库根」定义一致。

### 3.4 实现位置（方案甲）

- **推断**：实现为 **`scripts/docs-config.sh` 内的函数**（如首段规范化、`sdx_resolve_repo_doc_root` 中与 **`--doc-root`** 拼接相关的逻辑等；**不再**将 **`probe_doc_segment`** 纳入写入链，该函数可删除或仅保留给遗留脚本直至移除），与既有配置/校验函数同文件维护；**不**另建 `sdx-doc-root-resolve.sh` 等平行文件；**不**留在 `.agent/scripts/`。**`docs-init.sh`** 已 `source docs-config.sh`，写入 `.docsconfig` 时直接调用上述函数。
- `**.agent**`：仅保留「**读取** `.docsconfig`」的薄封装（见 §4），不再保留完整推断链。

---

## 4. 运行时读取与 `validate-*` 改造

### 4.1 正常路径

#### 4.1.1 解析 `TARGET_REPO_ROOT`（多宿主 `.agent`）

技能脚本可能位于 `**REPO_ROOT/.agent/skills/...`**（仓内），也可能位于 `**~/.../skills/...**`（用户目录安装）。**不得**仅用 `git -C "$SCRIPT_DIR"` 取顶：装在 `~/` 时常不在业务仓库内，须以**工作区**为主。

**不支持**通过环境变量（如 `DOCS_CONFIG_FILE`、`DOCS_CONFIG_ROOT` 等）显式指定路径或仓库根。

**建议解析顺序**（实现须与此等价）：

1. `**git -C "${PWD}" rev-parse --show-toplevel 2>/dev/null`** — Agent 执行 Skill 时 `**$PWD` 多为工作区根**，与「技能装在 `~/`」场景一致。
2. `**git -C "${SCRIPT_DIR}" rev-parse --show-toplevel 2>/dev/null`** — 技能在 `**REPO_ROOT/.agent/...**` 时通常有效。
3. **自 `$PWD` 向上**（逐层父目录，上限 N 层）查找 `**/.docsconfig`**，命中则所在目录即为 `**TARGET_REPO_ROOT**`。
4. 仍无法确定 → **§4.2** 策略 D。

得到 **`TARGET_REPO_ROOT`** 后：**若存在 `$TARGET_REPO_ROOT/.docsconfig`**：source 或逐行解析，在**当前脚本**内赋值 **`DOC_ROOT`**、**`REPO_ROOT`**、**`DOC_DIR`**（**不** `export`，见 §2.2.2；语义顺序与 §2.2.1 一致）。若文件缺 **`DOC_DIR`**，由 **`REPO_ROOT`** 与 **`DOC_ROOT`** 按 §2.2.1 补算。文件内 **`REPO_ROOT`** 可与 **`git -C "$DOC_ROOT" …`** 交叉校验（不一致时以实现约定为准）。

### 4.2 缺失 `.docsconfig`（策略 D，仅运行时）

适用于 **`validate-*.sh` 等未直接调用 `docs-init` 的路径**。用户**自行执行 `docs-init.sh`** 时见 **§3.0**，**不**走本表确认流程。

| 场景 | 行为 |
|------|------|
| **交互式 TTY** | 打印说明：缺少 `.docsconfig`，建议运行 `docs-init --scope=config <目标工程文档目录>`（或 **`--scope=c`**）；询问是否**立即代为执行**该命令。用户确认后，以非 dry-run 调用（需能定位 `docs-init.sh`：相对模板仓库、`PATH` 或文档约定）。**不得**在无人确认时由 bootstrap **代为**写盘。 |
| **非交互（无 TTY / CI）** | 打印**完整可复制**的 `docs-init` 示例命令（含 `config` / `c`）；**退出非 0**；不等待输入。 |


### 4.3 替换已删除脚本

- **删除**：`**.agent/scripts/sdx-doc-root.sh`**、`**.agent/scripts/sdx-validate-bootstrap.sh**`。
- **新增**：`**.agent/scripts/sdx-docsconfig-bootstrap.sh`**（名称可调整）：仅负责 **定位 `.docsconfig`**、**加载变量（不 export）**、**§4.2 的 D 流程**；**不含** `sdx_resolve_repo_doc_root` 的完整推断实现。
- `**sdx_find_repo_root_from_path`**：不再以「存在 `sdx-doc-root.sh`」为锚；改为向上查找 `**.docsconfig**`，或 `**.git` + 仓库根**（与各 validate 默认一致）。具体锚点以**实现 PR** 为准，但须在 **§6** 自检清单中列明。

### 4.4 `validate-agent-md-links.sh`

- 先按 §4.1 加载 **`DOC_ROOT`**、**`REPO_ROOT`**、**`DOC_DIR`**（**不** `export`）；缺失则 §4.2。Python 段使用 §2.2.2 的**前缀赋值**或读文件传入路径。
- 跨 `.agent` 链接判定逻辑不变，仅变量来源改为 `**.docsconfig**`。

---

## 5. 文档与引用更新

- `**scripts/README.md**`：`doc_root` 章节改为描述 `**.docsconfig**` 与 `**docs-init --scope=config**`；删除对已删脚本的「单一事实来源」表述。
- `**.agent/README.md**`：更新 `.agent/scripts/` 说明。
- `**docs/superpowers/specs/2026-04-07-agent-external-refs-path-resolution-design.md**`：在后续 PR 中增加「已由 `.docsconfig`  supersede 运行时推断」的指向段，避免长期双轨叙述冲突。
- **各 skill `validate-*.sh` 注释**：指向新 bootstrap 文件与 `.docsconfig`。

---

## 6. 实施自检（占位符与一致性）

- `.docsconfig` 中 **`DOC_ROOT`** / **`REPO_ROOT`** / **`DOC_DIR`** 与 §2.2.1 一致（**`REPO_ROOT`** 须可由 **`DOC_ROOT`** 推算）；**`DOC_ROOT`** 无默认推断，与 §1.2 / §3.2 一致；运行时**无** `export` 泄漏，与 §2.2.2 一致。
- `docs-init` 中模板 `**CFG[repo_root]`** 与目标 `**REPO_ROOT**` 变量命名在代码中无混用。
- `--scope=config` 与 `--mode=central` / `install_central` 组合行为已定义。
- 非交互失败码与 CI 文档一致。
- 删除脚本后无残留 `source` 路径。
- 运行时解析 `.docsconfig` 未引入「显式环境变量覆盖路径」能力；与 §4.1.1 一致。

---

## 7. 参考

- 现行推断实现：`.agent/scripts/sdx-doc-root.sh`（实施时迁移至 `scripts/` 后删除）。
- 初始化入口：`scripts/docs-init.sh`、`scripts/docs-config.sh`。
- 相关历史规格：`docs/superpowers/specs/2026-04-07-agent-external-refs-path-resolution-design.md`。

