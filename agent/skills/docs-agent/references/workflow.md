# docs-agent 工作流

主干：[SKILL.md](../SKILL.md)；风险控制与动作协议 [gates.md](gates.md)。

## 输入输出

| 类型 | 内容 |
| ---- | ---- |
| 硬输入 | 落盘 INDEX；无则不编造 |
| 必需参数 | `output`、`mode` |
| 固定输出 | `{REPO_ROOT}/README.md`、`AGENTS.md` |
| 不产出 | 不替代 INDEX；不把 INDEX 全文并入 AGENTS |

## 参数

| 参数 | 默认 | 说明 |
| ---- | ---- | ---- |
| `--output` | `both` | `readme` / `agents` / `both` |
| `--mode` | `update` | `create` 初始化；`update` 合并 |

## 参数向导

按以下顺序收口参数；用户已明确时可跳过对应项：

1. `output`
2. `mode`
3. 覆盖还是合并策略
4. 当前轮起始单元（默认 `README.md`；若 `output=agents` 则直接从 `AGENTS.md` 开始）

参数未收口前，不进入执行。

## 步骤 1：Index 解析

`source` `agent/scripts/config-bootstrap.sh`，`validate_bootstrap_docsconfig` 指向本技能 `scripts/`，解析 `.docsconfig` 得 **`REPO_ROOT`**、**`DOC_ROOT`**（及可选 `AGENT_*`）。

```bash
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
source "$REPO_ROOT/agent/scripts/config-bootstrap.sh"
validate_bootstrap_docsconfig "$REPO_ROOT/agent/skills/docs-agent/scripts"
DOC_ROOT="$(resolve_repo_doc_root)"
```

按序查找落盘 Index，命中即停并记录相对路径：`REPO_ROOT` 下 `index.md` / `INDEX_GUIDE.md`，再 `DOC_ROOT` 下同名。未命中 → 终止并提示 `/docs-indexing`。细则与降级见 [execution-spec.md](execution-spec.md)。

## 步骤 2：探索

以 INDEX 为地图，最小阅读集；禁止为 AGENTS 通读全仓。章节 → 去向见 [execution-spec.md](execution-spec.md) §2。

## 当前单元

一个当前单元就是单个根入口文档：

- `README.md`
- `AGENTS.md`

`output=both` 时，默认顺序：

1. `README.md`
2. `AGENTS.md`

一次只处理一个当前单元，不并行推进两个入口文件。

## 执行循环

### 1 选定当前单元

基于 `output` 与当前轮参数，确定本轮只处理一个根入口文档。

### 2 生成当前单元

- README：`assets/readme-skeleton.md`；30 秒内「是什么、下一步」；目录树唯一起源 INDEX §2
- AGENTS：`assets/agents-skeleton.md`；去重 [three-file-spec.md](three-file-spec.md)；概述 ≤3 行；命令块只在 README

### 3 自动 grilling

当前单元写入后，立即做自动 `grilling`：

- 检查是否与 INDEX 保持一致
- 检查 README/AGENTS 是否职责重叠
- 检查命令块是否仍只留在 README
- 检查 `update` 是否被误写成全量覆盖

### 4 输出与动作停顿

当前单元收敛后，停下等待 `C/M/G/S/F`：

- `C`：确认当前单元并进入下一入口文件或结束
- `M`：修改参数、覆盖策略或文本重点，再重新 grill
- `G`：继续深挖当前单元的一致性或职责边界
- `S`：暂存当前单元，跳过写入
- `F`：按已确认策略补齐剩余入口文件

### 5 验证

```bash
bash agent/skills/docs-agent/scripts/validate-guide.sh --root .
```

清单与反模式：[quality-standards.md](quality-standards.md)。

## 约束摘要

| 项 | 要求 |
| -- | ---- |
| 零幻觉 | 无落盘 INDEX 不编造；未读不写死 |
| 单单元推进 | 一次只处理一个入口文档，收敛后再进入下一文档 |
| 单一事实 | 命令在 README；AGENTS ≤3 行；不复制 INDEX §3 表 |
| INDEX | 本技能内不调 docs-indexing |
| update | `update` 合并，不全量覆盖 |
