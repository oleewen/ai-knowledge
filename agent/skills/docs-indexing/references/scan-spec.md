# 扫描执行规范

Agent 负责读取证据和更新九章正文。辅助脚本只统计 `DOC_DIR` 内的候选文件；mode 与 depth 不会让脚本自动阅读或分析文件。

## 深度级别

| 深度 | Agent 应完成的工作 |
| --- | --- |
| 1 · 拓扑 | 核实目录、主要模块、入口及元数据，建立导航骨架 |
| 2 · 结构 | 在拓扑上读取接口、符号、关键配置与文档结构 |
| 3 · 精读 | 在已确认范围和排除集内遍历可读文本，完整或分段读完，覆盖逻辑、分支、配置与正文 |

### 深度 3：应读尽读

不得用少量样本代表整个目录。部分读取、无法读取及排除项写入第八章，注明路径、范围和原因；索引条目由已核实内容决定，不为凑数量重复条目。

## 模式与 Git 变更

full 读取已确认范围；incremental 依据 [文内锚点或显式 since](indexing-log-spec.md) 合并变化，保持完整九章和未变章节。

增量至少检查四类来源：

| 来源 | 命令（在仓库根运行） |
| --- | --- |
| 基线后的提交 | `git --literal-pathspecs log --first-parent -m --since="$SINCE_ISO" --name-status -z --format= -M -- "$SCAN_ROOT"` |
| 暂存区 | `git --literal-pathspecs diff --cached --name-status -z -M -- "$SCAN_ROOT"` |
| 未暂存 | `git --literal-pathspecs diff --name-status -z -M -- "$SCAN_ROOT"` |
| 未跟踪 | `git --literal-pathspecs ls-files --others --exclude-standard -z -- "$SCAN_ROOT"` |

`SCAN_ROOT` 为已确认的仓库根相对范围，通常为 `DOC_DIR`；`SINCE_ISO` 从本轮 epoch 毫秒转换成带时区的 ISO 时间。提交来源沿第一父链并展开合并差异，避免漏掉基线后合入的旧分支提交。用 NUL 分隔读取结果，保留状态；重命名检查旧、新两条路径，删除更新引用，不尝试读已删除文件。新增文件也可能位于暂存区，不能仅靠未跟踪列表发现。

合并四类结果、去重，再按排除规则读取相关文件。变更可能影响未改动文件中的导航或依赖，按引用关系补查，不能把 Git 列表当作已读证据。Git 不可用或历史不足时报告限制，重新确定策略，不宣称完成增量。

## 范围与过滤

`output` 只决定指南位置。脚本始终扫描配置解析的 `DOC_DIR`；Agent 的全仓地图范围须单独明确。

脚本不进入软链或隐藏目录，排除 `target/`、`build/`、`node_modules/`；忽略 `viz.html`、`.DS_Store`、`*.log`、`*.class`、`*.jar`。Agent 阅读时还须识别二进制、生成物及工程声明的排除项，并在第八章说明。

联邦槽位通常是软链，不因 depth 3 自动跨库。扫描根缺失或枚举失败应非零退出，保持指南不变；不能把失败当作零文件成功。

## 统计与完成

候选文件数不是已阅读文件数。运行块仅记录候选统计，真实覆盖在第八章陈述；扫描结束不写完成锚点。写入时机见 [indexing-log-spec.md](indexing-log-spec.md)。
