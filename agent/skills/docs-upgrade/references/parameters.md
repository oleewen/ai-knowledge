# docs-upgrade 参数

本文定义技能输入与路径展开；CLI 参数以 [docs-upgrade.sh](../scripts/docs-upgrade.sh) 的 `-h` 为准。

## 输入

| 输入 | 说明 |
| --- | --- |
| 工程根 | 须有可读 `.docsconfig`；脚本从 cwd 向上解析 `文档目录`、`仓库路径`、`DOC_DIR`、`KNOWLEDGE_TYPE` |
| meta | 默认读 `{文档目录}/knowledge-links.yaml` 唯一 `type: meta`；可用 `--meta-path PATH` 本次覆盖，不修改登记 |
| `--ref REF` | 可选；默认不传。所选 Git 历史及 clone 行为见 [源解析](workflow.md#源解析)；meta YAML 无 `ref` 字段 |
| `--dry-run` | 整树默认：只生成清单，不写目标、备份或软链 |
| `--apply-scaffold` | 整树确认后：备份、新增骨架、根级 DESIGN 覆盖与路径收尾；不自动重填正文 |
| 文件 / 目录路径 | 触发指定路径模式；由 Agent 编排，不传给脚本 |

登记 `path` 使用 `${WORK_SPACE}/…`；`--meta-path` 也可用本机路径。均按文件所属库配置展开并校验工作区边界；缺配置、旧格式或越界即停止。完整契约见 [knowledge-links 路径契约](../../../knowledge/federation-config.md#knowledge-links-路径契约)。`dir` 校验先于目录展开，见 [workflow.md](workflow.md#源解析)。

## 指定路径展开

1. 接受会话明文、相对 / 绝对路径及 IDE 附件解析出的真实路径；不要求 `@`，不模糊匹配文件名。无法解析的疑似路径须澄清。
2. 将路径规范化为相对当前 `文档目录` 的路径，拒绝库外路径与 `..` 逃逸；按 [merge-rules.md §3](merge-rules.md#3-清单桶脚本) 检查排除项、软链与 README 映射。
3. 文件直接入名单；目录取**本库与元库同相对路径的文件并集**，按规范化路径去重。必须反向扫描元库，避免漏掉本库尚无的示例目录。
4. 总览逐条列出来源与动作：`meta-only` → scaffold；`local-only` → 元缺拒绝并保留；`both` → [§7 分类](merge-rules.md#7-指定路径强制对齐文件模式)。显式列出每个 `meta-only` 文件，核对动作项总数等于并集项数。

指定模式不套用整树示例去重；不以版本差异缩小名单。确认与后续执行见 [gates.md](gates.md)、[workflow.md](workflow.md)。
