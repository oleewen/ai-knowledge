# docs-distill 工作流

主干：[SKILL.md](../SKILL.md)。推进 binding：[gates.md](gates.md)。

契约：

- 写前澄清：[intent-clarify.md](../../../references/intent-clarify.md)
- 单元推进 / `C/M/G/S/F`：[unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)
- 写后烤干：[grilling-skill.md](../../../references/grilling-skill.md)

## 目标

参数向导 +「澄清 → 生成 → 烤干」：将联邦槽位已核实内容按 [federation-spec.md](federation-spec.md) **全量**去重后以 delta 写入目标层 overview 第三列。**不写** `DISTILL-LOG`。

## 边与路径

| `DOC_DIR` | 源槽位 | 目标 overview |
| --- | --- | --- |
| `system` | `system/application-slots/application-{NAME}/` | `system/knowledge/overview/{NAME}-overview.md` |
| `company` | `company/system-slots/system-{NAME}/` | `company/knowledge/overview/{NAME}-overview.md` |

`DOC_DIR`：`.docsconfig` / 环境变量优先；须为 `system|company`；否则向导必选。`--doc-dir` 可覆盖。

## 前置

- 路径：[knowledge-layout.md](../../../references/knowledge-layout.md)
- 源槽位已 pull 且非空
- overview 目标路径可解析；模板 `NAME-overview.md` 存在
- 若环境未安装 `grilling` Skill，则按 grilling-skill fallback

## 参数向导

按序收口；用户已明确时可跳过对应项：

1. `DOC_DIR` / `--doc-dir`（`system|company`）
2. `--name`
3. 是否 `--dry-run`
4. 当前 overview 是新建还是更新

参数未收口前，不进入执行。模式恒为全量。

## 当前单元

单个 `{NAME}-overview.md` + 单次全量范围。定义见 [gates.md](gates.md)。

## 写后默认表

| 对象 | 默认烤干 | 强制升级 |
| --- | --- | --- |
| 单个 overview 蒸馏单元（含 `--dry-run` 预览） | **必须** | 首次建 overview；冲突消解；未确认决策写入；跳过预览直写 |

启发式只可升级为必须，不可把默认「必须」降为跳过。

## 技能步骤

推进环见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)；本技能只补蒸馏特有步骤：

1. 选定当前单元（边 + `--name`）
2. **意图澄清**：公共六项 + [gates.md](gates.md) 追加字段；写前 `C` 后方可执行或预览
3. 校验槽位非空；读槽位 knowledge/SDD 与目标 overview（全量）
4. 按目标层表行 + federation-spec 去重、定 delta / A/U/D
5. `--dry-run` → 三分区预览（跳过 >10 行折叠），不写 overview
6. 写入第三列 delta（不写 DISTILL-LOG）
7. **烤干**：按写后默认表（含预览结果）
8. 用户动作：`C/M/G/S/F` 见 unit-cycle-protocol

## 命令示例

```bash
/docs-distill --doc-dir system --name billing-appeal --dry-run
/docs-distill --doc-dir system --name billing-appeal
/docs-distill --doc-dir company --name payment-platform --dry-run
```

校验壳：

```bash
agent/skills/docs-distill/scripts/run-docs-distill.sh --doc-dir system --name billing-appeal
```

## 脚本

`scripts/run-docs-distill.sh`：**薄校验**（路径/槽位/模板），不代工正文、不写 LOG。

## 执行摘要

- 仅全量；高风险时先 dry-run
- 第三列：federation-spec（按目标层表行）；不写 `(来源…)`
- 不写 DISTILL-LOG；单元结束须停等用户动作
