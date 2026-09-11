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
| `@` 文件/目录 | 否 | 有则进入**文件强制对齐**模式（与整树互斥）；见下节 |

脚本**暂无** `--path`；文件模式写盘由 Skill/Agent 编排。

## 文件模式输入（`@`）

| 规则 | 说明 |
| --- | --- |
| 触发 | 调用时 ≥1 个有效 `@` 文件或目录 → 文件模式；无 `@` → 整树 |
| 解析 | 只用 `@` 展开后的真实路径；不模糊匹配文件名 |
| `DOC_ROOT` 内 | 须落在当前工程 `DOC_ROOT`；规范化为相对 `DOC_ROOT` 路径；禁止 `..` 逃出；再在元库 `{meta}/{doc_dir}/` 找同相对路径（README：`README.md`↔`README-s.md`） |
| `@` 目录 | 递归收集目录下**所有文件**；再按合并规则分类动作（重填仅 `.md`） |
| 去重 | 展开后按规范化路径去重，再出总览 |

## 脚本行为摘要（整树）

| 模式 | 行为 |
| --- | --- |
| `--dry-run` | fetch/解析 meta；打印四桶清单；不写盘、不备份 |
| `--apply-scaffold` | fetch/解析；备份将动路径；写入「新增骨架」桶；不重填 md、不删本库独有 |

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
# 文件模式（会话）：/docs-upgrade 并 @ 若干文件或目录
# → 总览 C → 逐文件 C；无脚本 --path
```
