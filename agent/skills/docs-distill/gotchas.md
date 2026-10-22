# 易错点

- `DOC_DIR` 只能是 `system|solution|company`；`application` overview 走 `docs-extract` 或 `docs-archive`。
- 目标层由槽位边决定：应用槽位上行到 system，系统槽位上行到 solution，解决方案槽位上行到 company。
- `--dry-run` 也要先完成职责/粒度闭合和写前 `C`；契约未闭合时不得预览。
- 槽位缺失、为空或无 README 时停止；不从源仓直读绕过联邦契约。
- `--since`、`--full`、`DISTILL-LOG` 已废止；全量比对是唯一模式。
- 新建 overview 必须同时替换文件名和标题；第三列按目标层表行处理，不能跳行。
- 目标层写能力摘要，不搬运下层类名、接口、OpenAPI、DDL 或来源脚注。
- 一个当前单元只处理一个 `{NAME}-overview.md`；收敛前不自动切换源或边。
