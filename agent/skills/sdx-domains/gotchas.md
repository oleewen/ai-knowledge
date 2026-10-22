# sdx-domains 执行提示

| 现象 | 检查与处理 |
| --- | --- |
| 元仓校验报 `KNOWLEDGE_TYPE=meta` | 这是层级保护；在真实 company 工程或隔离 company fixture 验证，不改元仓配置 |
| `bash` 提示版本不足 | 检查 `bash --version`，改用 Bash 5+；macOS 系统 Bash 可能是 3.2 |
| 总图没有 `id` | 合法；总图用 `type/title`，不能套分域的 id 检查 |
| `--file` 找不到目标 | 路径相对调用时工作目录；只能选择配置文档根 domains 内直属 DOMAIN Markdown |
| 旧文件叫 `DOMAIN-EXAMPLE.md` | 核对对应 BD 和映射，保留现名；新建命名见 [core-concepts](references/core-concepts.md) |
| 校验通过仍有待确认项 | 结构检查不证明实体关系或业务完成，按 [质量清单](references/quality-checklist.md) 收口 |

参数与退出语义见 [workflow.md](references/workflow.md#校验脚本)。
