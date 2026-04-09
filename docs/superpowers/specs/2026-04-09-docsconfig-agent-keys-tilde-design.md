# docs-init：`.docsconfig` 的 `~` 根路径与 Agent 键（方案 A）

**日期**：2026-04-09  
**状态**：已评审（方案 A）  
**关联**：`scripts/docs-init.sh`、`scripts/docs-config.sh`、`.agent/scripts/docsconfig-bootstrap.sh`

---

## 1. 背景与目标

- 在 **`--scope=config`** 写入目标仓库根 `.docsconfig` 时，除既有 **`DOC_ROOT` / `REPO_ROOT` / `DOC_DIR`** 外，增加 **`AGENT_ROOT`** 与 **`AGENT_DIRS`**，与 **`install_agent_*`** 的安装根及目录名语义一致。
- 对凡名为 **`*_ROOT`** 的键采用 **C 策略**：在路径位于当前用户主目录下时，统一写为 **`~/...`**；读入后展开为绝对路径供脚本使用。
- 采用 **方案 A**：路径规范化与写入集中在 `docs-config.sh`；读入侧在 bootstrap / `docsconfig_read_into` 中 **`~` 展开**，保证 `cd`、`-f` 等用法安全。

---

## 2. 范围

| 纳入 | 不纳入（本 spec） |
|------|-------------------|
| `docsconfig_write` 及调用链：`DOC_ROOT`/`REPO_ROOT`/`AGENT_ROOT` 的写入格式 | 修改 Skill 正文中的术语示例（除非与行为冲突） |
| `AGENT_ROOT`/`AGENT_DIRS` 在 `scope=config` 落盘 | 为无 `<目标工程文档目录>` 单独新增 `config` 变体（当前 config 仍要求文档目录） |
| `docsconfig_read_into`、`docsconfig_parse_into_globals` 的 `~` 展开 | 非 Bash 的其它语言解析器 |
| `docsconfig_grep_keys` 扩展以包含新键（若保留该函数） | 变更 `DOC_DIR` 键的语义 |

---

## 3. `*_ROOT` 的 C 策略（写入）

- **适用键**：`DOC_ROOT`、`REPO_ROOT`、`AGENT_ROOT`。
- **规则**：设 `H` 为当前用户的 `$HOME`（规范化后的绝对路径）。若待写入的绝对路径 `P` 满足 `P == H` 或 `P` 为 `H/` 下的路径，则写入值为 **`~/`** 或 **`~/` + 去掉前缀 `H/` 后的余段**（单一路径段拼接规则与现有 `abs_path` 一致，避免出现 `~/` 双斜杠）。
- **例外**：若 `P` **不在** `H` 下（例如其它卷、只读挂载），则写入 **绝对路径** `P`，避免歧义。
- **兼容性**：历史上已落盘的 **纯绝对路径** 文件仍合法；读入侧见 §5。

---

## 4. 新增键：`AGENT_ROOT` / `AGENT_DIRS`

### 4.1 语义

- **`AGENT_ROOT`**：与 `install_agent_skills` / `install_agent_rules` 中 **`agent_install_root` 的父含义一致**——即各 Agent 目录（`.cursor`、`.claude` 等）的**父目录**（工程根或用户主目录），**不是** `~/.cursor` 本身。
  - 已提供 **`<目标工程文档目录>`** 时：与 **`REPO_ROOT` 所表示的同一逻辑根**（实现上与 `write_target_docsconfig` 使用的 `repo_target` / `target_dir` 一致，经 §3 格式化为 `~/...` 或绝对回退）。
  - 将来若支持「无文档目录」且与 config 组合：**未指定文档目录时** 对应 **`$HOME`**，写入 **`~/`**（或按 §3 规则）。
- **`AGENT_DIRS`**：按当前 **`ENABLED_AGENTS`** 顺序，对每个 agent 取 **`get_agent_dir`**（如 `.cursor`、`.trea`、`.claude`），**空格分隔**。

### 4.2 文件中的编码

- 因 **`AGENT_DIRS`** 值内含空格，写入单行时使用**双引号包裹值**，例如：
  - `AGENT_DIRS=".cursor .claude"`
- 解析时：去首尾空白与可选包裹引号后，按 **IFS 空白** 切分为多个目录名。

### 4.3 `scope=config` 时的执行顺序

在 **`write_target_docsconfig`** 之前：

1. **`apply_agents`**（解析 `--agents`，填充 `ENABLED_AGENTS`）。
2. 计算 **`AGENT_ROOT`**（绝对路径）与 **`AGENT_DIRS`** 列表，再经 §3 将 `AGENT_ROOT` 格式化为 `~/...` 或绝对路径。
3. 调用扩展后的 **`docsconfig_write`**（或等价单一写入点）一次性写出全部键。

---

## 5. 读入与 `~` 展开（方案 A）

- **`docsconfig_read_into`**（`scripts/docs-config.sh`）：在解析出 `DOC_ROOT`、`REPO_ROOT` 的值后，若值以 **`~/`** 开头，则展开为 **`$HOME/` + 余下路径**；单独一个 **`~`** 视为 **`$HOME`**。若值已为绝对路径，则不变。
- **`docsconfig_parse_into_globals`**（`.agent/scripts/docsconfig-bootstrap.sh`）：对 **`DOC_ROOT`、`REPO_ROOT`** 在赋值后做**相同展开**；若本 spec 实施后 **`AGENT_ROOT`** 也被解析，则一并展开。
- 展开后，**`resolve_repo_doc_root`** 等返回的仍是 **绝对路径**（与现有注释「文档树根绝对路径」一致，可微调注释为「由 `.docsconfig` 解析并展开 `~` 后」）。

---

## 6. `install_central` / INDEX 表格

- **中央库 `application/INDEX_GUIDE.md`（十）** 等登记行若需路径可读性与跨机器一致性，**建议继续使用绝对路径或 Git remote**，**不强制**与 `.docsconfig` 内 `~/` 展示一致；实现时可用**未格式化的绝对路径变量**单独传入登记函数，与 `.docsconfig` 写入解耦。

---

## 7. `docsconfig_write` / dry-run

- **dry-run**：预览输出应反映最终文件内容（含 `~/` 与带引号的 `AGENT_DIRS`）。
- **正式写入**：`umask`、单行 `KEY=value` 与 UTF-8 与现有行为保持一致；键集合扩展为至少：`DOC_ROOT`、`REPO_ROOT`、`DOC_DIR`、`AGENT_ROOT`、`AGENT_DIRS`（后两者在 `scope=config` 且本 spec 实现时写入）。

---

## 8. 实施检查清单

- [ ] `docs-config.sh`：实现根路径「绝对 → `~/` 或保留绝对」辅助函数；扩展 `docsconfig_write`；扩展 `docsconfig_read_into` 与 `docsconfig_grep_keys`（如仍使用）。
- [ ] `docs-init.sh`：`scope=config` 分支在写配置前调用 `apply_agents`；向 `docsconfig_write` 传入 Agent 元数据。
- [ ] `docsconfig-bootstrap.sh`：`docsconfig_parse_into_globals` 支持新键并对 `*_ROOT` 展开 `~`。
- [ ] `scripts/README.md`：简要说明 `.docsconfig` 键与 `~` 约定（若该节已存在则增量补一句）。
- [ ] 自测：`--scope=config`、`--agents=cursor,claude`、dry-run 与实写各一次；`HOME` 下与非 `HOME` 路径各一种（若可测）。

---

## 9. 修订记录

| 日期 | 说明 |
|------|------|
| 2026-04-09 | 初稿：方案 A + C 策略 + `AGENT_ROOT`/`AGENT_DIRS` |
