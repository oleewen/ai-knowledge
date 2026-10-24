# sdx-analysis 审查与验证记录

## 2026-10-24 逐项复审

入口、引用分层、局部续写、事实指标、ADR 与批量授权规则保持自洽，本轮未修改运行技能或校验器。重新运行脚本回归 49/49 通过。下方 6 项文件行为成绩为 2026-10-22 历史证据，本轮未重跑模型，不冒充当前全套行为通过。

2026-10-22：本轮脚本及契约独立复审均未发现新增问题。结果对应未提交工作树，代码摘要及逐断言证据见 [behavior-results.json](behavior-results.json)。

## 验证范围

| 检查 | 结果 |
| --- | --- |
| 校验脚本回归 | 49/49，通过；包含真实不可读目录、中文 ADR、元数据与链接用例 |
| 文件行为场景 | 6/6，通过；15/15 条 P0 断言有实际 diff、hash 或链接证据 |
| 仓库快速回归 | 11/11 套件通过；命令为 `bash agent/scripts/tests/run.sh --quick`，使用 Bash 5 |
| 技能格式、JSON、Markdown 链接、diff 空白 | 通过 |
| 独立代码与契约复审 | 无新增问题 |

六个行为场景覆盖：已授权续写、F 批确认后补齐、company/solution 层级分流、指标保真、既有 ADR 复用。局部草稿的缺章警告如实保留，未将其视为全文验收通过。

## 本轮修复

- ADR 登记仅匹配「决策编号」列，备注提及不算登记。
- 递归扫描失败传回错误，不能只凭已扫到的有效文件报通过。
- 中文 ADR 链接的 awk 字节切片不再触发多字节错误；子进程固定 locale，中文里程碑继续可识别。
- 共享 ADR 协议统一 ANALYSIS §5.2 / §7.2、FEATURE §6.2 的引用落点。
- Bash 守卫回归识别 docs-upgrade 经共享入口加载的真实行为，保留旧版 Bash 拒绝验证。

## 限制与复跑

其余 17 条协议/路由案例及 19 条发现案例本轮未执行；历史触发成绩仍单独保留。一次通过不代表稳定成功率，也不扩展校验器的有限 Markdown/frontmatter 契约。

复跑方法见 [evaluation.md](../references/evaluation.md)。脚本回归入口：`bash agent/scripts/tests/run.sh --suite agent/skills/sdx-analysis/tests/run.sh`，须使用 Bash 5+。
