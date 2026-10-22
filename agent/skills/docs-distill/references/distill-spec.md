# 蒸馏范围与产物

## 源与目标

只读取已 pull 的联邦槽位内 knowledge 与 SDD，目标为对应层 `knowledge/overview/{NAME}-overview.md`。边路径见 [workflow.md](workflow.md)。

目标不存在时，从同层 `NAME-overview.md` 创建；同步替换文件名和 `# {NAME} 架构概览`。目标已存在时只更新第三列。

## 变更发现

流程仍是全量扫描。用户提供的路径清单或槽位 Git diff 只能作为阅读顺序提示，不能改成增量模式，也不能替代全量比对。

## 产物

| 产物 | 约束 |
| --- | --- |
| overview | 五视角表；第三列写 delta 与 `A/U/D` |
| dry-run 输出 | 将写入、跳过、无命中三分区；不改 overview |
| 日志 | 不生成或更新 `DISTILL-LOG` |
