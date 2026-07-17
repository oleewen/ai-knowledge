# 反模式 → 纠正

原则 [design-principles.md](design-principles.md)；实操 [gotchas.md](../gotchas.md)。

| 反模式 | 纠正 |
| ------ | ------ |
| 参数未收口即写 overview 或 DISTILL | 先收口 `--app`、范围、是否 `--full`/`--dry-run`；[gates.md](gates.md) |
| 跳过写前意图澄清 | 须六项清单 + 写前 C；[intent-clarify.md](../../../references/intent-clarify.md) |
| 4.3 败仍 4.4 | 仅成功后追加；[workflow.md](workflow.md) |
| 混淆 CHANGE-LOG 与 DISTILL-LOG | [workflow.md](workflow.md)；[distill-log-spec.md](distill-log-spec.md) |
| `--full` 无预览直盖 | gates + gotchas |
| 第三列贴应用正文 | [federation-spec.md](federation-spec.md) |
| 锚点 id 失联仍静默全量 | gates |
| 五视角跳行 | 全表处理，`—` 占位；gotchas |
| 新建 overview 只改名不改标题 | 文件名 + `# …架构概览` 同步 APPNAME |
| 第三列堆来源脚注 | [design-principles.md](design-principles.md) |
| 无 `--app` 深读全库 | 轻扫日志与锚点；分批 `--app`；gates |
