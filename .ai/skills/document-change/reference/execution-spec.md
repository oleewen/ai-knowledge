# 执行规范与验证清单

document-change 技能的详细执行规范，包含五阶段流程、数据采集逻辑、错误处理与验证标准。

---

## Phase 1：环境准备

### 输出目录定位

优先级顺序：
1. 用户指定 `--output`
2. 当前目录 `./changelogs/`
3. 最短路径的 `**/changelogs/` 目录
4. 新建 `./changelogs/`

### 前置条件

| 条件 | 验证方式 | 失败处理 |
|------|----------|----------|
| Git 可用 | `git --version` | 跳过 git 来源 |
| CHANGELOG 可访问 | 检查文件存在 | 跳过 changelog 来源 |
| 输出目录可写 | `test -w <dir>` | 创建目录或报错 |

---

## Phase 2：时间基准计算

### baseline_time 获取

```
if 命令行参数 since:
    baseline = since
elif changes-index.json 存在:
    baseline = json.metadata.baseline_time
else:
    baseline = "2020-01-01 00:00:00.000"
```

### cutoff_time 计算

```
if is_git_repo:
    cutoff = max(baseline_time, latest_git_commit_time)
else:
    cutoff = baseline_time
```

---

## Phase 3：数据采集

### 3.1 Git 提交

**过滤**：`commit_time > baseline_time`

```bash
git log --since="$BASELINE_TIME" \
    --pretty=format:"%H|%aI|%aN|%s" --name-only
```

每条记录提取：`commit_hash`、`time`、`author`、`message`、`files[]`

### 3.2 CHANGELOG 条目

**过滤**：`entry_time > cutoff_time`

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

### 3.3 本地文件变更

**过滤**：`mtime > cutoff_time`

排除目录：

| 排除模式 | 原因 |
|----------|------|
| `.git` | 版本控制 |
| `node_modules` | 前端依赖 |
| `.venv`、`__pycache__` | Python 运行时 |
| `target`、`build` | 构建产物 |
| `.cursor`、`.idea`、`.vscode` | IDE 配置 |
| `{output_dir}` | 输出目录自身 |

---

## Phase 4：数据处理

### 合并与排序

1. 三源数据标记 `source` 字段（`git` / `changelog` / `local`）
2. 统一时间格式：
   - 显示格式：`yyyy-MM-dd HH:mm:ss.SSS`
   - 机器格式：13 位毫秒戳（`*_ms` 字段）
3. 按 `time_ms` 倒序排列

### 产物生成

按模板（见 `assets/`）生成：
- `changes-index.json`：结构化数据，含 metadata + statistics + changes
- `changes-index.md`：可读摘要，含元信息表 + 统计 + 按来源分组明细

---

## Phase 5：验证清单

### 文件存在性

- [ ] `changes-index.json` 存在
- [ ] `changes-index.md` 存在

### JSON 格式

- [ ] `jq empty` 通过
- [ ] `metadata.generated_at` 字段存在
- [ ] `metadata.baseline_time` 字段存在
- [ ] `changes` 数组存在

### 时间一致性

- [ ] 所有 `changes[].time_ms > metadata.cutoff_time_ms`

### 双格式一致

- [ ] JSON `statistics.total_changes` == MD 中的"总变更数"

---

## 错误处理

| 场景 | 检测 | 处理 |
|------|------|------|
| Git 不可用 | `git --version` 失败 | 警告，跳过 git 来源 |
| CHANGELOG 解析失败 | 时间提取为空 | 警告，跳过该文件 |
| 输出目录不可写 | `test -w` 失败 | 创建目录或终止 |
| JSON 生成异常 | 异常捕获 | 清理临时文件，输出错误 |
| 时间格式无效 | 正则匹配失败 | 使用默认时间或跳过 |

### 日志格式

```
[ERROR] [yyyy-MM-dd HH:mm:ss] {错误描述}
[WARN]  [yyyy-MM-dd HH:mm:ss] {警告描述}
[INFO]  [yyyy-MM-dd HH:mm:ss] {信息描述}
```

---

## 最佳实践

- **定时执行**：每日或每次提交后运行
- **CI 集成**：在 CI/CD 流程中自动生成
- **版本控制**：索引文件纳入 git
- **基线备份**：定期备份 `changes-index.json` 以防丢失

### 与其他技能配合

| 场景 | 下游技能 |
|------|----------|
| 基于变更重建文档索引 | `document-indexing` |
| 仅对变更文件执行知识提取 | `knowledge-extract` |
| 基于变更更新知识库 | `knowledge-extract` |
