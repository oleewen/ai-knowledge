# docs-upgrade 参数

脚本 SSOT：`bash agent/skills/docs-upgrade/scripts/docs-upgrade.sh -h`。本文列技能编排层。

## 技能层

| 参数 | 必选 | 说明 |
| --- | --- | --- |
| （工程根） | 是 | 含 `.docsconfig`；脚本从 cwd 向上解析 |
| `--meta-path PATH` | 否 | 覆盖 links 中 meta 的本机 path（仅本次；不改 yaml） |
| `--ref REF` | 否 | 对齐的 git ref；默认 `main`；仅 CLI 覆盖（yaml meta 条暂无 `ref` 字段） |
| `--dry-run` | 否 | 整树：只出清单（脚本默认模式之一） |
| `--apply-scaffold` | 否 | 整树：备份并将「新增骨架」写入本库（须已 `C`） |
| 文件/目录路径 | 否 | 有 ≥1 个可解析路径则进入**指定路径强制对齐**（与整树互斥）；见下节 |

脚本**暂无** `--path`；文件模式写盘由 Skill/Agent 编排。

## 文件模式输入（指定路径）

| 规则 | 说明 |
| --- | --- |
| 触发 | 调用时 ≥1 个可解析为 `DOC_ROOT` 内真实文件/目录的路径 → 文件模式；无此类路径 → 整树 |
| 路径来源 | 会话明文路径、相对/绝对路径、IDE 附件解析出的真实路径；**不**要求 `@` 前缀；不模糊匹配文件名 |
| 不可解析 | 像路径但落不出真实项 → 先澄清，不默整树也不默文件模式 |
| `DOC_ROOT` 内 | 须落在当前工程 `DOC_ROOT`；规范化为相对 `DOC_ROOT` 路径；禁止 `..` 逃出；再在元库 `{meta}/{doc_dir}/` 找同相对路径（README：`README.md`↔`README-s.md`） |
| 指定目录 | 递归收集目录下**所有文件**；再按合并规则分类动作（重填仅 `.md`） |
| 去重 | 展开后按规范化路径去重，再出总览 |

## 脚本行为摘要（整树）

| 模式 | 行为 |
| --- | --- |
| `--dry-run` | fetch/解析 meta；打印四桶清单；不写盘、不备份、不重写 `agent/`、不改 README |
| `--apply-scaffold` | fetch/解析；备份将动路径；写入「新增骨架」桶；收尾全树 `agent/`/IDE 段→`~/.agents/` + README 注记（空桶亦跑）；不重填 md、不删本库独有 |

结构重填与未落位由 Skill/Agent 执行，不在脚本内自动合正文。文件模式的 scaffold / 强制重填亦由 Agent 执行。

## 示例

```bash
# 整树：目标工程根
cd /path/to/my-app
bash ~/workspaces/ai-knowledge/agent/skills/docs-upgrade/scripts/docs-upgrade.sh --dry-run
# 确认后
bash ~/workspaces/ai-knowledge/agent/skills/docs-upgrade/scripts/docs-upgrade.sh --apply-scaffold
```

```text
# 文件模式（会话）：/docs-upgrade 并给出若干文件或目录路径（或挂附件）
# → 总览；C=一键全量 / M=下钻单文件或逐项；无脚本 --path
```
