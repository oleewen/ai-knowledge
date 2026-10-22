# sdx-architect 操作层陷阱

| 陷阱 | 处理 |
| --- | --- |
| 在公司/解决方案库先建 ASD 再判断类型 | 先读 [类型模式](references/knowledge-type-modes.md)，再创建文件 |
| 重跑向导覆盖已有 ASD | 复用参数与授权，仅处理当前段；初始化只用于新文件 |
| `./specs/` 链到错误目录 | 按 [产物路径](references/workflow.md#产物路径) 计算相对链接 |
| 默认校验 exit 0 被当成完稿 | 草稿可有警告；收尾用 `--strict`，并核实检查文件数 |
| 恢复旧 HTML gate、CONFIRMED 或写前 hook | 使用 [gates.md](references/gates.md) 绑定的共享协议 |

内容边界误用见 [概念反模式](references/anti-patterns.md)。
