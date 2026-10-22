# docs-extract 反模式

| 反模式 | 正确处理 |
| --- | --- |
| 用标题猜关键词、为命中自动改附录 | 按 [extract-spec.md](extract-spec.md) 检查有效附录，缺失先澄清 |
| 用旧第三列证明“知识正文已覆盖” | 读取行链接对应的知识正文 |
| 新 delta 覆盖无关旧项，或无命中写 `—` | 保留待归档内容，只处理已确认变更 |
| 来源没提到旧知识就写 `[D]` | 先取得废止依据或用户确认 |
| dry-run 改文件或声称已归档 | 只输出 [workflow.md](workflow.md) 定义的预览 |
| 宣称执行了 `/docs-extract` shell 命令 | Slash 是会话入口；不得虚构脚本执行证据 |

扫描异常与恢复见 [gotchas.md](../gotchas.md)，写前门禁见 [gates.md](gates.md)。
