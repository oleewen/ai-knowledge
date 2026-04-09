# 执行规范与验证清单

docs-change 的详细采集规则、错误处理与验证标准。SKILL.md 中已有的流程概述不在此重复。

---

## 输出目录定位

优先级顺序：
1. 用户指定 `--output`
2. 当前目录 `./changelogs/`
3. 最短路径的 `**/changelogs/` 目录
4. 新建 `./changelogs/`

---

## 数据采集规则

### Git 提交

**过滤条件**：`commit_time > baseline_time`

```bash
git log --since="$BASELINE_TIME" \
    --pretty=format:"%H|%aI|%aN|%s" --name-only
```

每条记录提取：`commit_hash`、`time`、`author`、`message`、`files[]`

### CHANGELOG 条目

**过滤条件**：`entry_time > cutoff_time`

支持格式：

| 格式 | 示例 |
|------|------|
| Keep a Changelog | `## [1.0.0] - 2026-03-23` |
| Semantic Release JSON | `{"version":"1.0.0","date":"2026-03-23T10:00:00Z"}` |
| 自定义 | 正则匹配 `\d{4}-\d{2}-\d{2}` |

日期提取正则：
```
\[(\d{4}-\d{2}-\d{2})\]|(\d{4}-\d{2}-\d{2})|(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})
```

解析失败时只跳过该条目并输出 `[WARN]`，继续解析同文件其余条目。

### 本地文件变更

**过滤条件**：`mtime > cutoff_time`

排除目录：

| 排除模式 | 原因 |
|----------|------|
| `.git` | 版本控制 |
| `node_modules` | 前端依赖 |
| `.venv`、`__pycache__` | Python 运行时 |
| `target`、`build` | 构建产物 |
| `.cursor`、`.idea`、`.vscode` | IDE 配置 |
| `{output_dir}` | 防止输出目录自引用循环 |

---

## 错误处理

| 场景 | 检测 | 处理 |
|------|------|------|
| Git 不可用 | `git --version` 失败 | `[WARN]` 跳过 git 来源，继续执行 |
| CHANGELOG 解析失败 | 时间提取为空 | `[WARN]` 跳过该条目，继续解析 |
| 输出目录不可写 | `test -w` 失败 | 创建目录或终止并报错 |
| JSON 生成异常 | 异常捕获 | 清理临时文件，输出 `[ERROR]` |
| 时间格式无效 | 正则匹配失败 | 使用默认时间或跳过 |

日志格式：
```
[ERROR] [yyyy-MM-dd HH:mm:ss] {错误描述}
[WARN]  [yyyy-MM-dd HH:mm:ss] {警告描述}
[INFO]  [yyyy-MM-dd HH:mm:ss] {信息描述}
```

---

## 验证清单

### 文件存在性
- [ ] `CHANGE-LOG.md` 存在且为有效 Markdown

### 基线与内容
- [ ] 文末存在 `<!-- docs-change:baseline_time_ms=... -->`，且与本轮聚合后的基线一致
- [ ] 收录条目均标注来源（git / changelog / local）且时间可核对

### 时间一致性
- [ ] 条目时间均在约定的 `baseline_time` / `cutoff_time` 规则下（见 [gotchas.md](../gotchas.md)）

---

## 最佳实践

- **定时执行**：每日或每次提交后运行，保持索引新鲜
- **CI 集成**：在 CI/CD 流程中自动生成，产物纳入 git
- **基线备份**：定期备份 `CHANGE-LOG.md` 以防文末基线注释丢失
