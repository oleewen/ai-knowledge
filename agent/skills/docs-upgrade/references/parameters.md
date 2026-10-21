# docs-upgrade 参数

脚本 SSOT：`bash agent/skills/docs-upgrade/scripts/docs-upgrade.sh -h`。本文列技能编排层。

整树且目标 `DESIGN.md` 含 `version` 时，脚本在元库所选 ref 的可达历史中，用 `docs-publish: version YYYY.MMdd.patch` commit 查找当前基线和最新目标发布点。缺少任一提交、元库非 Git 或当前发布点不是目标祖先时硬停；无 `version` 的旧库保留整树扫描。目标工程自身的发布历史不参与此计算。

增量范围按元库模板目录下两个发布提交的文件差异计算；读取固定为目标发布快照。应用 README 按 `README-s.md` 源路径过滤后映射为 `README.md`；未变化文件不进动作桶，元库删除项保留为本库独有。scaffold 后的全树 Agent 路径重写仍按原契约执行。`--apply-scaffold` 保留原版本号，整单成功后由 Agent 更新；文件模式不推进整库版本。

## 技能层

| 参数 | 必选 | 说明 |
| --- | --- | --- |
| （工程根） | 是 | 含 `.docsconfig`；脚本从 cwd 向上解析 |
| `--meta-path PATH` | 否 | 覆盖 links 中 meta 的本机 path（仅本次；不改 yaml；可传工作区内本机路径或 `${WORK_SPACE}/…`，均校验工作区边界） |
| `--ref REF` | 否 | 显式对齐的 git ref；**默认不传**。有则优先于 path 当前 HEAD；仅 path 无效走 clone 且未传时默认 `main`（yaml meta 条暂无 `ref` 字段） |
| `--dry-run` | 否 | 整树：只出清单（脚本默认模式之一） |
| `--apply-scaffold` | 否 | 整树：备份并将「新增骨架」写入本库（须已 `C`） |
| 文件/目录路径 | 否 | 有 ≥1 个可解析路径则进入**指定路径强制对齐**（与整树互斥）；见下节 |

脚本**暂无** `--path`；文件模式写盘由 Skill/Agent 编排。

## 文件模式输入（指定路径）

| 规则 | 说明 |
| --- | --- |
| 触发 | 调用时 ≥1 个可解析为 `文档目录` 内真实文件/目录的路径 → 文件模式；无此类路径 → 整树 |
| 路径来源 | 会话明文路径、相对/绝对路径、IDE 附件解析出的真实路径；**不**要求 `@` 前缀；不模糊匹配文件名 |
| 不可解析 | 像路径但落不出真实项 → 先澄清，不默整树也不默文件模式 |
| `文档目录` 内 | 须落在当前工程 `文档目录`；规范化为相对 `文档目录` 路径；禁止 `..` 逃出；再在元库 `{meta}/{doc_dir}/` 找同相对路径（README：`README.md`↔`README-s.md`） |
| 指定目录 | 取目录下本库文件与元库同相对路径文件的**并集**；`meta-only` 进入 scaffold 候选，`local-only` 进入元缺拒绝候选，`both` 再按合并规则分类动作（重填仅 `.md`） |
| 去重 | 两侧并集按规范化相对路径去重；总览显式列出 `meta-only` scaffold 文件 |

## 脚本行为摘要（整树）

| 模式 | 行为 |
| --- | --- |
| `--dry-run` | 解析 meta（见源解析优先级）；打印清单（含整文件覆盖桶）；不写盘、不备份、不重写 `agent/`、不改 README |
| `--apply-scaffold` | 解析 meta；备份将动路径；写入「新增骨架」桶；收尾全树裸 `agent/`、多层上跳 `../agent/` 与 IDE 段→`~/.agents/` + README 注记（空桶亦跑）；不重填 md、不删本库独有 |

结构重填与未落位由 Skill/Agent 执行（契约见 [merge-rules.md](merge-rules.md) §5），不在脚本内自动合正文。文件模式的 scaffold / 强制重填亦由 Agent 执行。

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
# → 总览；C=可处理项；有未落位则 C 后策略三档 / M=下钻单文件；无脚本 --path
```
