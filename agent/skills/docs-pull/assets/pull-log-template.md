# {APPNAME} 知识库同步日志

> docs-pull 维护；**每条同步追加**，不覆写历史。

## {YYYY-MM-DD HH:mm} — {branch}@{short_commit}

| 字段 | 值 |
|------|-----|
| 应用 | {APPNAME}（{app_id}） |
| 仓库 | {repo_url} |
| 分支 | {branch} |
| 提交 | {short_commit}（{commit_message}） |
| 同步时间 | {ISO-8601} |
| 新增 | {added_count} |
| 修改 | {modified_count} |
| 删除 | {deleted_count} |

<!-- 0 变更也保留本条 -->
