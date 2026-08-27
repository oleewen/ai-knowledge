# docs-extract 工作流

主干：[SKILL.md](../SKILL.md)。推进 binding：[gates.md](gates.md)。

契约：

- 写前澄清：[intent-clarify.md](../../../references/intent-clarify.md)
- 单元推进 / `C/M/G/S/F`：[unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)
- 写后烤干：[grilling-skill.md](../../../references/grilling-skill.md)

## 目标

参数向导 +「澄清 → 生成 → 烤干」：将 `--sources` 命中内容按 [federation-spec.md](../../docs-distill/references/federation-spec.md) 去重后以 delta 写入单个 `--overview` 第三列（A/U/D）。

## 与 docs-distill

任意 `--sources` 补充路径；共享目标（overview 第三列）与 A/U/D；**无** `DISTILL-LOG` / 应用蒸馏锚点。

| 维度 | docs-distill | docs-extract |
| ------ | ------ | ------ |
| 源 | `system/application-{name}/` | 用户 `--sources` |
| 过滤 | 联邦规则 | **必须**段落级关键词（[extract-spec.md](extract-spec.md)） |
| 增量锚点 | 有 | **无** |
| 写入 | overview + DISTILL-LOG | **仅**第三列 |

## 前置

- 路径：[knowledge-layout.md](../../../references/knowledge-layout.md)
- `--sources` 可解析（路径或文本）
- `--overview` 可解析
- overview 含 `## 文档关键词`
- 若环境未安装 `grilling` Skill，则按 grilling-skill fallback

## 参数向导

按序收口；用户已明确时可跳过对应项：

1. `--sources`
2. `--overview`
3. 关键词口径或过滤范围
4. 是否 `--dry-run`

参数未收口前，不进入执行。

## 当前单元

单个 `--overview` + 单批命中段落与 `A/U/D`。定义见 [gates.md](gates.md)。

## 写后默认表

| 对象 | 默认烤干 | 强制升级 |
| --- | --- | --- |
| 单个 overview 提炼单元（含 `--dry-run` 预览） | **必须** | 首次实质写第三列；命中面过大；`[U]` 影响面大；未确认决策写入 |

启发式只可升级为必须，不可把默认「必须」降为跳过。

## 技能步骤

推进环见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)；本技能只补提炼特有步骤：

1. 选定当前单元
2. **意图澄清**：公共六项 + [gates.md](gates.md) 追加字段（`--sources` / `--overview` / dry-run / 关键词附录）；写前 `C` 后方可执行或预览
3. 读附录与 sources，筛选命中段落
4. 无命中 → 结束单元
5. 按 federation-spec 去重、定 delta / A/U/D
6. `--dry-run` → 三分区预览（跳过 >10 行折叠），不写第三列
7. 正式写入 delta；失败整体回滚
8. **烤干**：按写后默认表（含预览结果）
9. 用户动作：`C/M/G/S/F` 见 unit-cycle-protocol

## 命令示例

```bash
/docs-extract --sources docs/design.md --overview system/knowledge/overview/billing-overview.md --dry-run
/docs-extract --sources docs/ --overview system/knowledge/overview/billing-overview.md
/docs-extract --sources docs/design.md docs/adr/ --overview system/knowledge/overview/billing-overview.md
/docs-extract --sources "这里是一段临时业务说明文本，用于提炼进 overview 第三列" --overview system/knowledge/overview/billing-overview.md --dry-run
```

## 执行摘要

- 附录为筛选唯一依据；弱相关不入
- 第三列：federation-spec（去重、delta、无脚注）
- 仅改有命中且未覆盖行；单元结束须停等用户动作
