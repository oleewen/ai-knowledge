# docs-change 采集规则

输出目录定位、三源采集、排除列表与错误处理。**歧义时是否停顿**见 [gates.md](gates.md)。

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
