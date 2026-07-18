# docs-agent 工作流

主干：[SKILL.md](../SKILL.md)。推进 binding：[gates.md](gates.md)。

契约：

- 写前澄清：[intent-clarify.md](../../../references/intent-clarify.md)
- 单元推进 / `C/M/G/S/F`：[unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)
- 写后烤干：[grilling-skill.md](../../../references/grilling-skill.md)

## 输入输出

| 类型 | 内容 |
| ---- | ---- |
| 硬输入 | 落盘 `INDEX-GUIDE.md`；无则不编造 |
| 必需参数 | `output`、`mode` |
| 固定输出 | `{REPO_ROOT}/README.md`、`AGENTS.md` |
| 不产出 | 不替代 `INDEX-GUIDE.md`；不把索引指南全文并入 AGENTS |

## 参数

| 参数 | 默认 | 说明 |
| ---- | ---- | ---- |
| `--output` | `both` | `readme` / `agents` / `both` |
| `--mode` | `update` | `create` 初始化；`update` 合并 |

## 参数向导

按序收口；用户已明确时可跳过对应项：

1. `output`
2. `mode`
3. 覆盖还是合并策略
4. 当前轮起始单元（默认 `README.md`；若 `output=agents` 则直接从 `AGENTS.md` 开始）

满足任一时，先澄清再写：未说明输出范围；未说明 `create` / `update`；指令过宽可能越出根入口双文件。

参数未收口前，不进入执行。

## 步骤 1：Index 解析

`source` `agent/scripts/config-bootstrap.sh`，`validate_bootstrap_docsconfig` 指向本技能 `scripts/`，解析 `.docsconfig` 得 **`REPO_ROOT`**、**`DOC_ROOT`**（及可选 `AGENT_*`）。

```bash
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
source "$REPO_ROOT/agent/scripts/config-bootstrap.sh"
validate_bootstrap_docsconfig "$REPO_ROOT/agent/skills/docs-agent/scripts"
DOC_ROOT="$(resolve_repo_doc_root)"
```

按序查找落盘 Index Guide，命中即停并记录相对路径：`REPO_ROOT/INDEX-GUIDE.md`，再 `DOC_ROOT/INDEX-GUIDE.md`。未命中 → 终止并提示 `/docs-indexing`。细则与降级见 [execution-spec.md](execution-spec.md)。

## 步骤 2：探索

以 INDEX 为地图，最小阅读集；禁止为 AGENTS 通读全仓。章节 → 去向见 [execution-spec.md](execution-spec.md) §2。

## 当前单元

单个根入口文档（`README.md` 或 `AGENTS.md`）。定义见 [gates.md](gates.md)。

## 写后默认表

| 对象 | 默认烤干 | 强制升级 |
| --- | --- | --- |
| 单个入口文档（README 或 AGENTS） | **必须** | 未确认决策写入；职责边界/覆盖策略变更；跨入口前文前提变更 |

启发式只可升级为必须，不可把默认「必须」降为跳过。

## 技能步骤

推进环见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)；本技能只补入口文档特有步骤：

1. 选定当前单元
2. **意图澄清**：公共六项 + [gates.md](gates.md) 追加字段（写入策略、INDEX 锚点）；写前 `C` 后方可写入
3. 按模板生成并写入终稿：
   - README：`assets/readme-skeleton.md`；30 秒内「是什么、下一步」；目录树唯一起源 INDEX §2
   - AGENTS：`assets/agents-skeleton.md`；去重 [three-file-spec.md](three-file-spec.md)；概述 ≤3 行；命令块只在 README
4. **烤干**：按写后默认表；语义问题或跨入口前文回改须停下确认（回改协议见 unit-cycle-protocol）
5. 用户动作：`C/M/G/S/F` 见 unit-cycle-protocol

## 验证

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
| INDEX | 本技能内不调 docs-indexing；只消费已落盘 `INDEX-GUIDE.md` |
| update | `update` 合并，不全量覆盖 |
