# docs-init：`.docsconfig` 的 `~` 根路径与 Agent 键（方案 A）

**日期**：2026-04-09  
**状态**：已评审（方案 A）  
**关联**：`scripts/docs-init.sh`、`scripts/docs-config.sh`、`.agent/scripts/docsconfig-bootstrap.sh`

---

## 1. 背景与目标

- 在 `**--scope=config`** 写入目标仓库根 `.docsconfig` 时，除既有 `**DOC_ROOT` / `REPO_ROOT` / `DOC_DIR`** 外，增加 `**AGENT_ROOT`** 与 `**AGENT_DIRS**`，与 `**install_agent_***` 的安装根及目录名语义一致。
- 对凡名为 `***_ROOT**` 的键采用 **C 策略**：在路径位于当前用户主目录下时，统一写为 `**~/...`**；读入后展开为绝对路径供脚本使用。
- 采用 **方案 A**：路径规范化与写入集中在 `docs-config.sh`；读入侧在 bootstrap / `docsconfig_read_into` 中对 `**~` 展开**，保证 `cd`、`-f` 等用法安全。

---

## 2. 范围


| 纳入                                                                                      | 不纳入（本 spec）                                         |
| --------------------------------------------------------------------------------------- | --------------------------------------------------- |
| `docsconfig_write` 及调用链：`DOC_ROOT`/`REPO_ROOT`/`AGENT_ROOT` 的写入格式                       | 修改 Skill 正文中的术语示例（除非与行为冲突）                          |
| `AGENT_ROOT`/`AGENT_DIRS` 在 `scope=config` 落盘                                           | 为无 `<目标工程文档目录>` 单独新增 `config` 变体（当前 config 仍要求文档目录） |
| `docsconfig_read_into`、`docsconfig_parse_into_globals` 的 `~` 展开；各消费方改为读 `AGENT_*`（§4.4） | 非 Bash 的其它语言解析器                                     |
| `docsconfig_grep_keys` 扩展以包含新键（若保留该函数）                                                  | 变更 `DOC_DIR` 键的语义                                   |


---

## 3. `*_ROOT` 的 C 策略（写入）

- **适用键**：`DOC_ROOT`、`REPO_ROOT`、`AGENT_ROOT`。
- **规则**：设 `H` 为当前用户的 `$HOME`（规范化后的绝对路径）。若待写入的绝对路径 `P` 满足 `P == H` 或 `P` 为 `H/` 下的路径，则写入值为 `**~/`** 或 `**~/` + 去掉前缀 `H/` 后的余段**（单一路径段拼接规则与现有 `abs_path` 一致，避免出现 `~/` 双斜杠）。
- **例外**：若 `P` **不在** `H` 下（例如其它卷、只读挂载），则写入 **绝对路径** `P`，避免歧义。
- **兼容性**：历史上已落盘的 **纯绝对路径** 文件仍合法；读入侧见 §5。

---

## 4. 新增键：`AGENT_ROOT` / `AGENT_DIRS`

### 4.1 语义

- **AGENT_ROOT**：与 `install_agent_skills` / `install_agent_rules` 中 `agent_install_root` 的**父目录**含义一致——即各 Agent 目录（`.cursor`、`.claude` 等）的**父目录**（工程根或用户主目录），**不是** `~/.cursor` 本身。
  - 已提供 `**<目标工程文档目录>`** 时：与 **REPO_ROOT** 所表示的同一逻辑根（实现上与 `install_docsconfig` 使用的 `repo_target` / `target_dir` 一致，经 §3 格式化为 `~/...` 或绝对回退）。
  - 将来若支持「无文档目录」且与 config 组合：**未指定文档目录时** 对应 `$HOME`，写入 `~/`（或按 §3 规则）。
- **AGENT_DIRS**：按当前 `ENABLED_AGENTS` 顺序，对每个 agent 取 `get_agent_dir`（如 `.cursor`、`.trea`、`.claude`），**空格分隔**。

### 4.2 文件中的编码

- 因 **AGENT_DIRS** 值内含空格，写入单行时使用**双引号包裹值**，例如：
  - `AGENT_DIRS=".cursor .claude"`
- 解析时：去首尾空白与可选包裹引号后，按 **IFS 空白** 切分为多个目录名。

### 4.3 `scope=config` 时的执行顺序

在 **`install_docsconfig`** 之前：

1. `**apply_agents`**（解析 `--agents`，填充 `ENABLED_AGENTS`）。
2. 计算 **AGENT_ROOT**（绝对路径）与 **AGENT_DIRS** 列表，再经 §3 将 `AGENT_ROOT` 格式化为 `~/...` 或绝对路径。
3. 调用扩展后的 `**docsconfig_write`**（或等价单一写入点）一次性写出全部键。

### 4.4 消费方（与 `DOC_ROOT` 一致）

- `**.docsconfig` 五键（`DOC_ROOT` / `REPO_ROOT` / `DOC_DIR` / `AGENT_ROOT` / `AGENT_DIRS`）落盘之后**，凡运行时需要与任一键**相同语义**的量，**应自 `.docsconfig` 读取**（经 §5 对 `***_ROOT`** 做 `~` 展开后使用），**不以**各处重复推导为长期事实源——与 `**DOC_ROOT` 通过 `docsconfig-bootstrap` / `resolve_repo_doc_root` 消费** 的方式对齐。
  - `**DOC_ROOT`**：目标工程「文档树根」绝对路径（与 `resolve_repo_doc_root` 一致）。
  - `**REPO_ROOT`**：承载 `.docsconfig` 的目标工程 **Git 仓库根**（与 bootstrap 解析结果一致）。
  - `**DOC_DIR`**：相对 `**REPO_ROOT`** 的文档路径段（与 `docsconfig_doc_dir_from_roots` 语义一致；可为 `.`）。
  - `**AGENT_ROOT` / `AGENT_DIRS` / `AGENT_DIR**`：见 §4.1–§4.2；安装路径为 `**$AGENT_ROOT/AGENT_DIR**`（`**AGENT_DIR**` 为 `**AGENT_DIRS**` 中的某一目录名）。
- **例外**：`docs-init` 在**尚未存在**或**正在首次写入** `.docsconfig` 的路径上，仍可按 CLI 与 `agent_install_root` / 路径推导计算并写入；**其它**脚本、Skill、校验与索引流程在已存在 `.docsconfig` 时，应优先经 `**docsconfig_parse_into_globals` / `docsconfig_read_into`**（或等价）加载上述键，避免与落盘配置漂移。
- **文档与脚本表述（术语替换范围）**：下列路径中的 **Markdown、注释与可执行脚本**，凡出现与下述**相同语义**的表述，**应统一改为对应变量名**（与 `.docsconfig` 键名一致；`**AGENT_DIR`** 仍为文档占位，见下）。
  - `**DOC_ROOT`**：指「目标工程文档根 / 应用知识库根」等绝对路径语义，而非本仓库内 `application/` 模板树路径时。
  - `**REPO_ROOT`**：指「目标工程仓库根 / 工程根」且与 `.docsconfig` 中 `**REPO_ROOT**` 同义时。
  - `**DOC_DIR**`：指「相对仓库根的文档子路径」且与 `**DOC_DIR**` 键同义时（勿与 `**DOC_ROOT**` 混用；`**DOC_ROOT` = `$REPO_ROOT/$DOC_DIR**` 的分解在文可用文字说明）。
  - `**AGENT_ROOT` / `AGENT_DIRS` / `AGENT_DIR**`：与 `**AGENT_ROOT` 相同语义**（Agent 配置树所在父路径：工程根或用户主目录下的「安装根」），或 `**AGENT_DIRS` 中任一目录名相同语义**（如字面 `.cursor`、`.claude`、`.trea` 等作为「已选 Agent 根目录名」而非仓库内 `.agent/` 模板路径时）；指**单个**目录名时写作 `**AGENT_DIR`**（`**AGENT_DIRS` 中的某项**；文件键名仍为 `**AGENT_DIRS`**）。
  - **目录**：`.agent/`、`application/`、`system/`、`company/`、`scripts/`（含递归子路径）。
  - **文件**：仓库根 `**README.md`**、`**AGENTS.md`**、`**INDEX_GUIDE.md**`，以及子域内同名 `**INDEX_GUIDE.md**`（如 `application/INDEX_GUIDE.md` 等）中涉及上述语义者，一并按上款替换。
- **边界**：
  - 本款**不**要求把本仓库**源模板**路径（如 `application/`、`system/`、`company/` 树或本仓库 `.agent/`）**机械替换**为 `**DOC_*` / `REPO_*`**；仅当正文描述的是**目标工程侧**与 `**.docsconfig` 一致**的语义时，改用上述变量名。
  - 若须特指「ai-knowledge 模板仓库内」路径，可保留「本仓库 `application/`」等字面说明以免歧义。

---

## 5. 读入与 `~` 展开（方案 A）

- `**docsconfig_read_into`**（`scripts/docs-config.sh`）：在解析出 `DOC_ROOT`、`REPO_ROOT`、`AGENT_ROOT` 的值后，若值以 `**~/`** 开头，则展开为 `**$HOME/` + 余下路径**；单独一个 `**~`** 视为 `**$HOME`**。若值已为绝对路径，则不变。`AGENT_DIRS` 按 §4.2 解析为可迭代列表。
- `**docsconfig_parse_into_globals`**（`.agent/scripts/docsconfig-bootstrap.sh`）：对 `**DOC_ROOT`、`REPO_ROOT`、`AGENT_ROOT**` 在赋值后做**相同展开**；`AGENT_DIRS` 的解析与 §4.2 一致，供 §4.4 消费。
- 展开后，`**resolve_repo_doc_root`** 等返回的是 `.docsconfig` 解析并展开 `~` 后的值。

---

## 6. `install_central` / INDEX 表格

- **中央库 `application/INDEX_GUIDE.md`（十）** 等登记行若需路径可读性与跨机器一致性，**建议继续使用绝对路径或 Git remote**，**不强制**与 `.docsconfig` 内 `~/` 展示一致；实现时可用**未格式化的绝对路径变量**单独传入登记函数，与 `.docsconfig` 写入解耦。

---

## 7. `docsconfig_write` / dry-run

- **dry-run**：预览输出应反映最终文件内容（含 `~/` 与带引号的 `AGENT_DIRS`）。
- **正式写入**：`umask`、单行 `KEY=value` 与 UTF-8 与现有行为保持一致；键集合扩展为至少：`DOC_ROOT`、`REPO_ROOT`、`DOC_DIR`、`AGENT_ROOT`、`AGENT_DIRS`（后两者在 `scope=config` 且本 spec 实现时写入）。

---

## 8. 实施检查清单

- `docs-config.sh`：实现根路径「绝对 → `~/` 或保留绝对」辅助函数；扩展 `docsconfig_write`；扩展 `docsconfig_read_into` 与 `docsconfig_grep_keys`（如仍使用）。
- `docs-init.sh`：`scope=config` 分支在写配置前调用 `apply_agents`；由 `install_docsconfig` 调用 `docsconfig_write` 传入 Agent 元数据。
- `docsconfig-bootstrap.sh`：`docsconfig_parse_into_globals` 支持新键并对 `*_ROOT` 展开 `~`。
- **消费方**：凡需与 `DOC_ROOT` / `REPO_ROOT` / `DOC_DIR` / `AGENT_ROOT` / `AGENT_DIRS` 同语义的逻辑（见 §4.4），在目标仓库已有 `.docsconfig` 时改为从该文件读取；盘点并更新相关 Skill 脚本 / 校验脚本等。
- **术语替换**：按 §4.4 第三节，扫描 `.agent/`、`application/`、`system/`、`company/`、`scripts/` 及根 / 子域 `INDEX_GUIDE.md`、`README.md`、`AGENTS.md`，将符合边界说明的表述改为 `DOC_ROOT` / `REPO_ROOT` / `DOC_DIR` / `AGENT_ROOT` / `AGENT_DIRS` / `AGENT_DIR`（占位）。
- `scripts/README.md`：简要说明 `.docsconfig` 键与 `~` 约定（若该节已存在则增量补一句）。
- 自测：`--scope=config`、`--agents=cursor,claude`、dry-run 与实写各一次；`HOME` 下与非 `HOME` 路径各一种（若可测）。

---

## 9. 修订记录


| 日期         | 说明                                                                        |
| ---------- | ------------------------------------------------------------------------- |
| 2026-04-09 | 初稿：方案 A + C 策略 + `AGENT_ROOT`/`AGENT_DIRS`                                |
| 2026-04-09 | 增补 §4.4：消费方与 `DOC_ROOT` 一致、自 `.docsconfig` 读取                             |
| 2026-04-09 | §4.4：约定 `.agent/` 等目录与入口 MD 中术语向 `AGENT_ROOT`/`AGENT_DIRS`/`AGENT_DIR` 对齐 |
| 2026-04-09 | §4.4：术语替换一并纳入 `DOC_ROOT`/`REPO_ROOT`/`DOC_DIR` 与边界说明                      |


