# `.docsconfig` 与 `docs-init` 整合设计（方案甲）

**日期**: 2026-04-08  
**状态**: 待实施  
**范围**: 将 `**REPO_ROOT`** / `**DOC_DIR**` 从 `**DOC_ROOT**` 的推算写入合并入 `scripts/docs-init.sh`（`**DOC_ROOT**` 仅初始化显式指定，见 §1.2）；在目标工程仓库根落盘 `.docsconfig`；运行时各 `validate-*.sh` 从 `.docsconfig` 读取 `**DOC_ROOT**`、`**REPO_ROOT**`（由 `**DOC_ROOT**` 推算）、`**DOC_DIR**`；删除 `sdx-doc-root.sh` 与 `sdx-validate-bootstrap.sh`；**运行时**缺失 `.docsconfig` 时采用策略 **D**（见 §4.2），**有文件但缺 `DOC_DIR`** 时见 **§4.2.1**（强制确认 `docs-init` 或退出）；`**docs-init.sh` 执行时**若缺少 `.docsconfig`，在符合写入条件时**直接**落盘，**无须**用户确认（见 §3.0）。

---

## 1. 背景与目标

### 1.1 现状

- **历史**：`**.agent/scripts/sdx-doc-root.sh**` / `**.agent/scripts/sdx-validate-bootstrap.sh**` 曾分别承担首段解析与 validate 引导；已由 **`.docsconfig`** + `**.agent/scripts/docsconfig-bootstrap.sh`** 取代，**两脚本已移除**。
- `**scripts/docs-init.sh**`：向目标工程同步模板时已知 `**CFG[docs_abs]**`（目标文档目录）与 `**git_root_path**` 等；**`.docsconfig`** 写入与 **`--scope=config`** 见本规格 §3。

### 1.2 目标

1. **单一运行时事实源**：目标工程仓库根下的 `**.docsconfig`**，供 validate、链接校验等读取，避免在运行时重复分散推断。
2. **推断写入合并进 `docs-init`**：实现放在 `**scripts/**` 侧（方案甲），由 `docs-init` 在适当时机调用并写入；删除 `.agent` 下两脚本。
3. **策略 D / §4.2.1（仅 `validate-*` / 运行时 bootstrap）**：若缺少 `.docsconfig`，**提示用户**并**确认**是否代为执行 `docs-init` 的「仅写 `.docsconfig`」模式（§4.2）；若**有文件但缺 `DOC_DIR`**，**强制**确认是否代为执行 `**docs-init.sh --scope=c`**，**拒绝则退出**，非交互打印命令并失败退出（§4.2.1）。
4. `**docs-init.sh` 与确认**：执行 `**docs-init.sh`** 时，若目标工程侧**尚无** `.docsconfig`，只要本次调用满足 §2.3 的写入条件（非 dry-run、已提供 `<目标工程文档目录>` 等），则按 §3.2 **直接**推断并写入，**无须**用户二次确认；**不**适用策略 D 的交互确认条款。
5. **语义确认（已采纳）**：
  - `**DOC_ROOT`**：**仅在初始化时指定**，**不支持推断**。来源仅限 `**docs-init.sh`** 调用时显式传入的 `**<目标工程文档目录>**`（规范化后的绝对路径，即既有 `**CFG[docs_abs]**`）。**禁止**目录探测、默认 `docs` 路径、环境变量等推断 `**DOC_ROOT`**。语义上即文档树根（旧版脚本曾用 **`REPO_DOC_ROOT`** 指同一路径）。运行时（`validate-*` 等）**只读** `**.docsconfig`** 中已写入的 `**DOC_ROOT**`，**不**重新推断。**禁止**对 `**DOC_ROOT**` / `**REPO_ROOT**` / `**DOC_DIR**` 使用 **`export`**；见 §2.2.2。
  - `**REPO_ROOT**`：**在 `DOC_ROOT` 之后确定**，由 `**DOC_ROOT`** **推算**得到的**目标工程 Git 仓库根**绝对路径（典型：`git -C "$DOC_ROOT" rev-parse --show-toplevel`）；与 `**.docsconfig` 文件所在仓库根**一致。
  - `**DOC_DIR`**：由 `**DOC_ROOT**` 与已确定的 `**REPO_ROOT**` **推算**——满足 `**REPO_ROOT` + `DOC_DIR` = `DOC_ROOT`**（路径语义：`realpath "$REPO_ROOT/$DOC_DIR"` = `realpath "$DOC_ROOT"`）。POSIX 相对段、**无**前导 `/`（如 `docs`、`application`）。用于模板「相对工程根」前缀（如原 `docs_slash`）时以 `**DOC_DIR`**（及约定尾斜杠）为准。
  - `**<目标工程文档目录>**`（`CFG[docs_abs]`）经规范化即为落盘之 `**DOC_ROOT**`。**废弃** `**probe_base`** 与 `**probe_doc_segment**` 目录探测。
  - 新增 `**--scope=config**`（缩写 `**c**`，与 `all|knowledge|skills|rules|rs` 并列）：**仅**初始化/更新 `.docsconfig`，不拷贝模板、不安装 Agent skills/rules。

### 1.3 非目标

- 不改变 `docs-init` 对 **模板仓库根**（现 `**CFG[repo_root]`**，指向 ai-knowledge 克隆）的职责；本设计在叙述中用 **「模板仓库根」** 与 **「目标工程 REPO_ROOT」** 区分，避免混淆。
- 不在本规格中规定下游 Python/其他语言的重写，仅约定 `**.docsconfig` 文件内字段语义**与 §2.2.2 的传参约定。
- **运行时**（`validate-*.sh`、`.docsconfig` 引导逻辑）**不支持**通过**显式环境变量**指定「`.docsconfig` 路径」或「目标仓库根」——必须以 §4.1 的算法从 `**$PWD` / `$SCRIPT_DIR` / 向上查找** 解析，避免与「文件即 SSOT」双轨并存。`**docs-init` 写入**见 §3.2：`**DOC_ROOT`** 仅初始化显式指定（**无**默认推断）；`**REPO_ROOT`** / `**DOC_DIR**` 由 `**DOC_ROOT**` 推算；**不再**依赖历史 **`REPO_DOC_ROOT`** / **`SDX_DOC_ROOT`** / `.sdx-doc-root`；**无** `probe_base` / `**probe_doc_segment`**。

---

## 2. `.docsconfig` 格式与字段

### 2.1 位置

- **路径**：`$REPO_ROOT/.docsconfig`，其中 `**REPO_ROOT`** 为**目标工程**的 Git 仓库根目录（见 §3.3）。

### 2.2 语法

- **推荐**：每行 `KEY=value`，`#` 行首为注释；使用 UTF-8。
- **必填键**（逻辑顺序：**先 `DOC_ROOT`，再由此推算 `REPO_ROOT` 与 `DOC_DIR`**）：
  - `**DOC_ROOT**`：仅来自初始化时显式指定（`**CFG[docs_abs]**`，即 `**docs-init**` 的 `**<目标工程文档目录>**` 规范化结果），**不**经推断；见 §1.2。
  - `**REPO_ROOT`**：由 `**DOC_ROOT**` 推算的**仓库根**绝对路径（与 `git -C "$DOC_ROOT" rev-parse --show-toplevel` 语义对齐）。
  - `**DOC_DIR`**：由 `**DOC_ROOT**` 与 `**REPO_ROOT**` 推算，使 `**REPO_ROOT` + `DOC_DIR` = `DOC_ROOT**`（`realpath "$REPO_ROOT/$DOC_DIR"` 与 `realpath "$DOC_ROOT"` 一致）。相对路径、无前导 `/`。若知识库根与仓库根重合（少见），`**DOC_DIR**` 为 `**.**`（实现须统一，禁止与空字符串混用）。

### 2.2.1 三者关系

- **推导顺序**：`**DOC_ROOT`**（**仅**初始化显式给定，见 §1.2）→ `**REPO_ROOT`** = 由 `**DOC_ROOT**` 解析 Git 顶层 → `**DOC_DIR**` 由二者推算，满足 `**REPO_ROOT` + `DOC_DIR` = `DOC_ROOT**`。
- 写入 `.docsconfig` 时：按 §3.2 先定 `**DOC_ROOT**`，再算 `**REPO_ROOT**`、`**DOC_DIR**` 并一并落盘（避免手填不一致）。

### 2.2.2 禁止使用 `export`（避免多仓库环境串扰）

- **不**将 `**REPO_ROOT`** / `**DOC_ROOT**` / `**DOC_DIR**`（shell 变量名统一为上述三键，旧名 **`REPO_DOC_ROOT`** 已废弃）通过 `**export**` 写入继承给交互式 Shell 或跨会话全局环境。
- **允许**：在**当前脚本进程**内使用普通赋值；调用子进程（如 `python3`）时使用**单次命令前缀**（建议顺序 `**DOC_ROOT`**、`**REPO_ROOT**`、`**DOC_DIR**`）：`DOC_ROOT=... REPO_ROOT=... DOC_DIR=... python3 ...`，或让子进程**自行读取** `.docsconfig`。
- **迁移**：既有脚本若仍使用旧名 **`REPO_DOC_ROOT`**，应改为仅使用 **`DOC_ROOT`**（与 `.docsconfig` 键名一致）或上述前缀传参，**不**再依赖已 export 的环境变量。

### 2.3 写入与更新策略

- `**docs-init` 在同时满足以下条件时写入或覆盖 `.docsconfig`**（非 dry-run）：
  - 本次调用提供了 `**<目标工程文档目录>**`（即 `**CFG[docs_abs]**` 非空）；且
  - `**--scope**` 为 `**config**`（或 `**c**`），或 `**all` / `knowledge**` 等会落地工程文档的 scope（与「本次安装的文档根」保持一致）。
- **仅 `--scope=skills` / `rules` / `rs` 且未提供 `<目标工程文档目录>`**：**不写** `.docsconfig`（与现逻辑一致：无稳定文档根）。
- `**--dry-run`**：**不写** `.docsconfig`。

---

## 3. `docs-init` 行为扩展

### 3.0 缺少 `.docsconfig` 时的执行策略

- 与 §4.2 **策略 D**（运行时缺文件、依赖用户确认是否调 `docs-init`）**不同**：用户**已主动执行** `docs-init.sh` 时，视为授权写入；若 `**$REPO_ROOT/.docsconfig`** 尚不存在，在满足 §2.3 时**默认**执行 §3.2 **写入**并**创建/落盘**（`**DOC_ROOT`** 仍须按 §3.2 **显式**来源，**不**推断），**不**再弹出「是否创建 `.docsconfig`」类确认（`--dry-run` 仍只预览、不写盘）。

### 3.1 新增 `--scope=config`

- **CLI**：`**--scope=config`** 与 `**--scope=c`** 等价（`c` 仅表示 **config**，与其它 scope 首字母不冲突）。
- **含义**：在**目标工程**仓库根写入 `**.docsconfig`**（记录 `**DOC_ROOT**` / `**REPO_ROOT**` / `**DOC_DIR**`），**不**执行 `install_system_to_docs`、`install_agent_skills`、`install_agent_rules`。
- **参数要求**：必须提供 `**<目标工程文档目录>`**（规范化后为文档树根绝对路径，与 `**DOC_ROOT**` 对齐；见 §3.2）。
- **与 `--mode=central`**：`--scope=config` 改的是**目标仓库**的 `.docsconfig`；`--mode=central` 表示在**源知识库（运行 `docs-init` 所针对的 ai-knowledge 克隆）**内向 `application/INDEX_GUIDE.md` 等**登记目标工程**（`install_central`）。二者语义正交，**允许组合**。未显式 `--type` 且为 `central` 时，实现默认 `--type=application`，以便与既有 central 登记路径一致；若需登记 **system/company** 型目标，请显式传 `--type`。**凡**执行 `install_central` 的路径，**均不要求**目标 `DOC_ROOT`（`DOC_DIR` 所指文档根）下已存在 `knowledge/`（可先登记、后补知识树或再跑 `docs-init` 同步）。

### 3.2 写入顺序（写入 `.docsconfig` 时）

`**DOC_ROOT`** **仅**由下列步骤 **1–2** 之一得到（**非推断**）；**禁止**无参默认、`docs` 兜底或其它推断。**不**新增 `**--doc-root`** 等 CLI：`**<目标工程文档目录>**`（`CFG[docs_abs]`）为 `**docs-init**` 侧唯一显式路径参数；步骤 2 直接以其规范化结果作为 `**DOC_ROOT**`。

先确定 `**DOC_ROOT**`（如上），再按 §3.3 由 `**DOC_ROOT**` 解析 Git 顶层 `**REPO_ROOT**`（与 `.docsconfig` 内字段同名）并落盘。最后按 §2.2.1 算 `**DOC_DIR**`。细节：

1. **既有 `$REPO_ROOT/.docsconfig`**：若该文件**已存在**、可解析，则**读取**已初始化的 `**DOC_ROOT`**、`**REPO_ROOT**`、`**DOC_DIR**`。若缺 `**DOC_DIR**`，在本次 `**docs-init**` 写入流程中按 §2.2.1 **补算**并**随本次落盘一并写入**（**不**触发 §4.2.1：已处于用户授权的 `**docs-init`**）。三者与 §2.2.1 一致时**直接采用**；**不再**执行步骤 2。若文件内 `**REPO_ROOT`** 与 `**git -C "$DOC_ROOT" …**` 不一致，**推荐**以 **由 `DOC_ROOT` 重算的 Git 顶层**为准校正 `**REPO_ROOT`** 并**重算** `**DOC_DIR`**。
2. **否则**（首次写入或文件不存在）：将 `**docs-init`** 传入并规范化后的 `**<目标工程文档目录>**` **直接作为** `**DOC_ROOT`**；再 `**REPO_ROOT="$(git -C "$DOC_ROOT" rev-parse --show-toplevel 2>/dev/null)"**`。再按 §2.2.1 计算 `**DOC_DIR**`。若本次**未**提供 `<目标工程文档目录>`，**不得**写入 `**DOC_ROOT`**（**不**使用默认 `docs`、**不**推断）。**不**使用 `**probe_base`** / `**probe_doc_segment**`。

**摘要**：`**DOC_ROOT`** = `**<目标工程文档目录>` 规范化** 或 **读取既有 `.docsconfig`**；**无**默认推断；`**REPO_ROOT`** / `**DOC_DIR**` 由 `**DOC_ROOT**` 推算。

**与模板替换**：相对工程根的知识库前缀以 `**DOC_DIR`** 为准（实现可导出为带尾斜杠形式，如 `docs/`，与 `**docs_slash**` 一类变量对齐）。

**说明**：旧版 **`REPO_DOC_ROOT` / `SDX_DOC_ROOT` / `.sdx-doc-root`** 不再参与本链；迁移依赖 **步骤 1** 的既有 `**.docsconfig`**，或重新执行 `**docs-init**`（传入 `**<目标工程文档目录>**`）生成新文件。

### 3.3 `REPO_ROOT`（目标工程）解析

- **默认**：在 `**DOC_ROOT`** 已确定后，由 `**DOC_ROOT**` 推算仓库根：`REPO_ROOT="$(git -C "$DOC_ROOT" rev-parse --show-toplevel 2>/dev/null)"`；该值即写入 `.docsconfig` 的 `**REPO_ROOT**`。（等价地，亦可先规范化传入的 `**<目标工程文档目录>**` 为 `**DOC_ROOT**`，再执行同上 `git -C`。）
- **若不在 Git 仓库内或命令失败**：规范可二选一并在实现中写死：**(a)** 失败并提示；或 **(b)** 回退为 `**dirname` 链**至含 `.docsconfig` 预定位置——**推荐 (a)**，与「仓库根」定义一致。

### 3.4 实现位置（方案甲）

- **推断**：写入链中的**核心实现逻辑**为：在 `**DOC_ROOT`** 已确定（见 §3.2）后，**由 `DOC_ROOT` 推算 `REPO_ROOT`**（§3.3）**与 `DOC_DIR`**（§2.2.1），一并写入 `.docsconfig`。代码落在 `**scripts/docs-config.sh**` 的函数中（可与既有首段规范化等辅助逻辑同文件编排），与既有配置/校验函数同文件维护；**不再**将 `**probe_doc_segment`** 纳入写入链，该函数可删除或仅保留给遗留脚本直至移除；**不**另建 `sdx-doc-root-resolve.sh` 等平行文件；**不**留在 `.agent/scripts/`。`**docs-init.sh`** 已 `source docs-config.sh`，写入 `.docsconfig` 时直接调用上述函数。
- `**.agent**`：仅保留「**读取** `.docsconfig`」的薄封装（见 §4），不再保留完整推断链。

---

## 4. 运行时读取与 `validate-*` 改造

### 4.1 正常路径

#### 4.1.1 解析 `REPO_ROOT`（多宿主 `.agent`）

技能脚本可能位于 `**REPO_ROOT/.agent/skills/...`**（仓内），也可能位于 `**~/.../skills/...`**（用户目录安装）。不得仅用 `git -C "$SCRIPT_DIR"` 取顶：装在 `~/` 时常不在业务仓库内，须以**工作区**为主。

**不支持**通过环境变量（如 `DOCS_CONFIG_FILE`、`DOCS_CONFIG_ROOT` 等）显式指定路径或仓库根。

**建议解析顺序**（实现须与此等价）：

1. `**git -C "${PWD}" rev-parse --show-toplevel 2>/dev/null`** — Agent 执行 Skill 时 `**$PWD` 多为工作区根**，与「技能装在 `~/`」场景一致。
2. `**git -C "${SCRIPT_DIR}" rev-parse --show-toplevel 2>/dev/null`** — 技能在 `**REPO_ROOT/.agent/...`** 时通常有效。
3. **自 `$PWD` 向上**（逐层父目录，上限 N 层）查找 `**/.docsconfig`**，命中则所在目录即为 `**REPO_ROOT`**。
4. 仍无法确定 → **§4.2** 策略 D。

得到 `**REPO_ROOT`** 后：**若存在 `$REPO_ROOT/.docsconfig`**：source 或逐行解析，在**当前脚本**内赋值 `**DOC_ROOT`**、`**REPO_ROOT**`、`**DOC_DIR**`（**不** `export`，见 §2.2.2；语义顺序与 §2.2.1 一致）。若文件**缺 `DOC_DIR`**：**不**得以运行时补算代替落盘并继续后续校验 → **§4.2.1**。若三者齐备，文件内 `**REPO_ROOT`** 可与 `**git -C "$DOC_ROOT" …**` 交叉校验（不一致时以实现约定为准）。

### 4.2 缺失 `.docsconfig`（策略 D，仅运行时）

适用于 `**validate-*.sh` 等未直接调用 `docs-init` 的路径**。用户**自行执行 `docs-init.sh`** 时见 **§3.0**，**不**走本表确认流程。


| 场景                  | 行为                                                                                                                                                                                                   |
| ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **交互式 TTY**         | 打印说明：缺少 `.docsconfig`，建议运行 `docs-init --scope=config <目标工程文档目录>`（或 `**--scope=c`**）；询问是否**立即代为执行**该命令。用户确认后，以非 dry-run 调用（需能定位 `docs-init.sh`：相对模板仓库、`PATH` 或文档约定）。**不得**在无人确认时由 bootstrap **代为**写盘。 |
| **非交互（无 TTY / CI）** | 打印**完整可复制**的 `docs-init` 示例命令（含 `config` / `c`）；**退出非 0**；不等待输入。                                                                                                                                     |


### 4.2.1 缺 `DOC_DIR`（仅运行时）

适用于 `**validate-*.sh` 等**：`.docsconfig` **已存在**且可读，但**未**包含 `**DOC_DIR`**（或解析为空）。**不**允许在未确认的情况下用 §2.2.1 **补算** `**DOC_DIR`** 并继续执行校验——须先补全文件。


| 场景                  | 行为                                                                                                                                                                                                                  |
| ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **交互式 TTY**         | 说明缺 `**DOC_DIR`**，须通过 `**docs-init.sh --scope=c <目标工程文档目录>**`（与 `**--scope=config**` 等价）回写；**强制**询问是否**立即代为执行**该命令。用户**确认** → 以非 dry-run 调用（定位方式同 §4.2）；**拒绝** → **退出非 0**，**不**继续当前脚本。**不得**在无人确认时**代为**写盘或静默补算继续。 |
| **非交互（无 TTY / CI）** | 打印**完整可复制**的 `**docs-init.sh --scope=c <目标工程文档目录>`** 示例；**退出非 0**；不等待输入。                                                                                                                                            |


用户**自行执行 `docs-init.sh`** 并落盘完整键后，再次运行 validate 即走 §4.1.1 正常路径。`**docs-init**` 写入路径见 §3.2 步骤 1（当场补算并落盘，**不**走本小节确认表）。

### 4.3 替换已删除脚本

- **已移除**：`**.agent/scripts/sdx-doc-root.sh`**、`**.agent/scripts/sdx-validate-bootstrap.sh`**。
- **现行**：`**.agent/scripts/docsconfig-bootstrap.sh`** — 定位 `.docsconfig`、加载变量（不 export）、**§4.2 策略 D** 与 **§4.2.1 缺 `DOC_DIR`** 的确认/退出流程；**不含**旧版 `sdx_resolve_repo_doc_root`（原 `sdx-doc-root.sh`）的完整推断实现；兼容入口为 **`resolve_repo_doc_root`**（读 `.docsconfig` 中 `DOC_ROOT`）。
- `**sdx_find_repo_root_from_path`**（若实现保留）：**不再**以「存在 `sdx-doc-root.sh`」为锚；改为向上查找 `**.docsconfig`**，或 `**.git` + 仓库根**（与各 validate 默认一致）。具体锚点以**实现 PR** 为准，但须在 **§6** 自检清单中列明。

### 4.4 `validate-agent-md-links.sh`

- 先按 §4.1 加载 `**DOC_ROOT`**、`**REPO_ROOT**`、`**DOC_DIR**`（**不** `export`）；若**无** `.docsconfig` 则 §4.2；若文件存在但**缺 `DOC_DIR`** 则 §4.2.1（**不**静默补算继续）。Python 段使用 §2.2.2 的**前缀赋值**或读文件传入路径。
- 跨 `.agent` 链接判定逻辑不变，仅变量来源改为 `**.docsconfig`**。

---

## 5. 文档与引用更新

- `**scripts/README.md**`：`doc_root` 章节改为描述 `**.docsconfig**` 与 `**docs-init --scope=config**`；删除对已删脚本的「单一事实来源」表述。
- `**.agent/README.md**`：更新 `.agent/scripts/` 说明。
- `**docs/superpowers/specs/2026-04-07-agent-external-refs-path-resolution-design.md**`：在后续 PR 中增加「已由 `.docsconfig`  supersede 运行时推断」的指向段，避免长期双轨叙述冲突。
- **各 skill `validate-*.sh` 注释**：指向新 bootstrap 文件与 `.docsconfig`。

---

## 6. 实施自检（占位符与一致性）

- `.docsconfig` 中 `**DOC_ROOT`** / `**REPO_ROOT**` / `**DOC_DIR**` 与 §2.2.1 一致（`**REPO_ROOT**` 须可由 `**DOC_ROOT**` 推算）；`**DOC_ROOT**` 无默认推断，与 §1.2 / §3.2 一致；运行时**无** `export` 泄漏，与 §2.2.2 一致；运行时缺 `**DOC_DIR`** 须 **§4.2.1**（强制确认 `**docs-init.sh --scope=c`**，拒绝则退出），**不**静默补算继续。
- `docs-init` 中模板 `**CFG[repo_root]`** 与目标 `**REPO_ROOT`** 变量命名在代码中无混用。
- `--scope=config` 与 `--mode=central` / `install_central` 组合行为已定义。
- 非交互失败码与 CI 文档一致。
- 删除脚本后无残留 `source` 路径。
- 运行时解析 `.docsconfig` 未引入「显式环境变量覆盖路径」能力；与 §4.1.1 一致。

---

## 7. 参考

- 写入与推算：`scripts/docs-config.sh`；运行时加载：`scripts/docs-init.sh`、`.agent/scripts/docsconfig-bootstrap.sh`。
- 相关历史规格：`docs/superpowers/specs/2026-04-07-agent-external-refs-path-resolution-design.md`。

