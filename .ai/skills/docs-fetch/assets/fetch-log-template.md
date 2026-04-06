# {APPNAME} 知识库同步日志

> 本文件由 docs-fetch 自动维护，记录每次从目标工程拉取文档的同步历史。
> 每次同步追加一条记录，不覆盖历史。

---

## {YYYY-MM-DD HH:mm} 同步 — {branch}@{short_commit}

| 字段 | 值 |
|------|-----|
| 应用 | {APPNAME}（{app_id}） |
| 仓库 | {repo_url} |
| 分支 | {branch} |
| 提交 | {short_commit}（{commit_message}） |
| 同步时间 | {ISO-8601} |
| 新增文件 | {added_count} |
| 修改文件 | {modified_count} |
| 删除文件 | {deleted_count} |

<!-- 若文件无变化，新增/修改/删除均为 0，仍须记录本条同步 -->
