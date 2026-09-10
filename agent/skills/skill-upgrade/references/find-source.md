# 无源补源（编排 find-skills）

本文件是 `skill-upgrade` 的补源栏契约。搜索、质量门、展示格式**遵循已安装的 find-skills 技能**（`npx skills find` / [skills.sh](https://skills.sh/)）；此处只定编排闸门与自动建议门槛。

## 何时进入

凡技能**当前无可用源**（见 [workflow.md](workflow.md)）均进入无源候选集。本仓 overlap 名不进生态补源（仍走 agent-install）。

## 搜前闸门（强制）

1. 展示无源清单（名 + 原因：无 lock / update 失败 / …）与大约数量
2. 问用户是否按 find-skills 查找
3. **拒绝 → 本段整段跳过**（记入清单「补源：跳过」）；不搜、不 add
4. 同意 → 进入搜索

## 搜索

- 默认 query = **本地技能目录名**
- 按 find-skills：可先扫 leaderboard / skills.sh，再 `npx skills find <query>`（或等价检索）
- 质量门同 find-skills：安装量、源声誉、星数；**不单凭搜到就推荐**
- 零候选：汇总；经用户同意可改 query / `--owner` **再搜一次**；再零则待决策标「未找到」

## 置信分流

默认信任 owner（会话可追加）：

`vercel-labs` · `anthropics` · `microsoft` · `obra` · `trailofbits` · `github`

| 结果 | 去向 |
| --- | --- |
| 候选**恰好 1 条**，技能名与目录名**完全一致**（大小写不敏感），且 owner 在信任列表 | **建议桶** |
| 多候选、零候选、同名但非信任 owner、唯一但不同名 | **待决策表** |

**禁止**：多候选时自动挑一条；非信任唯一匹配直接 add。

## 建议桶

- 汇总展示：本地名 → `owner/repo@skill`、安装量/来源链接
- 用户一次确认（可多选/全选/全不选）后，才生成 `npx skills add … -g -y`
- 未确认 → 不得进实跑补源步

## 待决策表

- 默认**一张总表**：技能 | 原因 | 候选摘要 | 用户选择（编号 / 跳过 / 手动 `owner/repo@skill`）
- 用户批量回复；某一行候选过多或冲突大 → 降级为对该技能单问
- 零候选行：选跳过，或同意后二次宽搜

## 与纯 `/find-skills` 分流

| 语境 | 技能 |
| --- | --- |
| 已装追新中遇到无源 | `skill-upgrade` 编排本文件 |
| 「帮我找个做 X 的 skill」无追新 | 主路径 `find-skills` |
