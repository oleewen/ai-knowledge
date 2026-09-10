# docs-bootstrap 工作流

## 参数向导

按序收口；用户已明确时可跳过对应项：

1. `--components`（默认 `both`）
2. 目标工程文档目录（docs 需要时，或 `agent` + `agent-scope=project`：`--doc-target` / docs-install `--target`）
3. `--agents` 与 agent 安装根（agent 需要时：`--agent-scope` 或 agent `--target`）
4. docs 透传：`--type` / `--mode` / `--scope` / `--force` / 其他已声明项
5. agent 透传：`--scope`（hooks/rules/…）/ `--dry-run`
6. 是否先 dry-run（默认是）

参数未收口前，不进入执行。

## 当前单元

**一次装机计划** = 一个当前单元（含所选 components 与全部参数）。

一次只推进一个计划；不并行多目标工程。

## 源路径探测

工作区根（或用户指定的中央库根）**同时**存在：

- `scripts/docs-bootstrap.sh`
- `scripts/docs-install.sh`
- `agent/scripts/docs-core.sh`

→ **本仓快路径**（`source=local`）。否则 → **`source=remote`**（尚无本地脚本树）。

### 何时允许 `docs-bootstrap.sh`

仅同时满足：

1. `source=remote`（非 local）
2. 用户**未**声明超出 bootstrap 表面的旗标

**表面参**（可进 bootstrap）：

- `--components`（`docs` \| `agent` \| `both`）
- `--doc-target` / `--agents` / `--agent-scope`
- 环境变量 `GIT_REPO_URL` / `GIT_REF`

**超出表面**（禁止 bootstrap，须取得脚本树后分步透传）：`--force` / `--type` / `--mode` / docs|agent `--scope` / 分步 `--dry-run` 等。

| components | local | remote + 仅表面 |
| --- | --- | --- |
| `docs` | 只跑 `docs-install.sh`（全透传） | 可 `docs-bootstrap.sh --components=docs` |
| `agent` | 只跑 `agent-install.sh`（全透传） | 可 `docs-bootstrap.sh --components=agent` |
| `both` | 依次两脚本 | 可 `docs-bootstrap.sh`（默认 both） |
| 任意 + 超出表面 | 分步透传 | 取得脚本树后分步透传；**禁止** bootstrap |

本仓快路径下**不要**为「方便」再临时 clone bootstrap。

## 执行循环

### 1 准备

- Bash 5+、Git（需要 clone 时）
- docs：目标父目录存在
- agent：`--agents` 合法（见 [scripts/README.md](../../../../scripts/README.md)）

### 2 dry-run / 计划校核

- **分步调用**：对将执行的脚本加 `--dry-run`，展示摘要
- **bootstrap 路径**：脚本无统一 dry-run → 打印与脚本确认块等价的计划（components / doc-target / agents / agent-target / repo URL·ref），**不得**未 `C` 直接 clone+装机；Agent 已用计划摘要 + `C` 时，勿再把 bootstrap 交互 `[Y/n]` 当唯一闸门（非交互/管道须带齐参数）

dry-run 或计划摘要后立即校核：路径、components、高风险项是否仍符合用户意图。

### 3 实跑

用户 `C` 后去掉 dry-run（或确认 bootstrap 计划）执行。失败则整单停，不静默改 components 重试。

### 4 写后停顿

1. 校核产物（`.docsconfig`、知识库目录、Agent 目录）
2. 按 [audience-and-language.md](../../../references/audience-and-language.md) 轻流程默认读者表做 **A/B**
3. 停下等待 `C/M/S/F`（见 [light-flow-actions.md](../../../references/light-flow-actions.md)）

未过 A/B → 不得宣称单元完成。
