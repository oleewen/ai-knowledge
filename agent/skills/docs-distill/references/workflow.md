# docs-distill 工作流

主干：[SKILL.md](../SKILL.md)。推进 binding：[gates.md](gates.md)。

契约：

- 写前澄清：[intent-clarify.md](../../../references/intent-clarify.md)
- 单元推进 / `C/M/G/S/F`：[unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)
- 写后烤干：[grilling-skill.md](../../../references/grilling-skill.md)

## 目标

参数向导 +「澄清 → 生成 → 烤干」：将应用已核实变更按 [federation-spec.md](federation-spec.md) 去重后以 delta 写入 overview 第三列；成功后追加 `DISTILL-LOG`。

## 前置

- 路径：[knowledge-layout.md](../../../references/knowledge-layout.md)
- 可读 `system/application-{name}/changelogs/CHANGE-LOG.md`
- overview 目标路径可解析
- `system/changelogs/DISTILL-LOG.md` 可写
- 若环境未安装 `grilling` Skill，则按 grilling-skill fallback

## 两日志

| 文件 | 职责 | 本技能写入 |
| ---- | ----- | --------- |
| `system/application-{name}/changelogs/CHANGE-LOG.md` | 增量候选来源 | **否** |
| `system/changelogs/DISTILL-LOG.md` | 蒸馏记录与下次锚点 | **是**（overview 成功后） |

不得把这两份日志混用。`CHANGE-LOG` 负责提供应用增量来源；`DISTILL-LOG` 负责记录蒸馏完成点。

## 参数向导

按序收口；用户已明确时可跳过对应项：

1. `--app`
2. `--since` 或自动锚点
3. 是否 `--full`
4. 是否 `--dry-run`
5. 当前 overview 是新建还是更新

参数未收口前，不进入执行。

## 当前单元

单个 `{APPNAME}-overview.md` + 单次增量或 `--full` 范围。定义与原子性见 [gates.md](gates.md)。

## 写后默认表

| 对象 | 默认烤干 | 强制升级 |
| --- | --- | --- |
| 单个 overview 蒸馏单元（含 `--dry-run` 预览） | **必须** | `--full`；首次建 overview；锚点/增量起点不明；冲突消解；未确认决策写入 |

启发式只可升级为必须，不可把默认「必须」降为跳过。

## 技能步骤

推进环见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)；本技能只补蒸馏特有步骤：

1. 选定当前单元
2. **意图澄清**：公共六项 + [gates.md](gates.md) 追加字段（`--app` / `--since` / `--full` / `--dry-run` / overview 新建或更新）；写前 `C` 后方可执行或预览
3. 读 CHANGE-LOG 与 overview，定增量或 `--full` 范围
4. 按 federation-spec 去重、定 delta / A/U/D
5. `--dry-run` → 三分区预览（跳过 >10 行折叠），不写 overview / `DISTILL-LOG`
6. 写入第三列 delta；成功后追加 `DISTILL-LOG`；失败禁止写日志（见 gates）
7. **烤干**：按写后默认表（含预览结果）
8. 用户动作：`C/M/G/S/F` 见 unit-cycle-protocol

## 命令示例

```bash
/docs-distill --app billing-appeal --dry-run
/docs-distill --app billing-appeal --since v1.2.0
/docs-distill --app billing-appeal --full
/docs-distill --app billing-appeal
```

## 脚本

`scripts/`：**编排日志**，不代工「内容提炼」。新记录一律**最新在前**。

| 脚本 | 用途 |
| ---- | ---- |
| `run-docs-distill.sh` | `--dry-run` / 编排；仓库根或 `--root` |
| `append-change-log.sh` | 追加 DISTILL-LOG（含 `app`） |

内容提炼步骤 4.2–4.3：`federation-spec.md`。

## 执行摘要

- 默认增量；`--full` 先 dry-run
- 第三列：federation-spec；不写 `(来源…)`
- 先 overview，后 `DISTILL-LOG`；单元结束须停等用户动作
