# OKF 路径解析

先进入目标工程。解析器从当前目录上溯查找 `.docsconfig`，不以技能安装目录推断目标工程。

## 硬门禁

| 条件 | 处理 |
| --- | --- |
| `.docsconfig` 缺失、不可解析，或缺 `REPO_DIR` / `DOC_DIR` | 停止；用 `docs-install --scope=config` 修复 |
| 配置推导的仓库根与 `.docsconfig` 所在目录不一致 | 停止；按配置漂移处理 |
| 缺 `KNOWLEDGE_TYPE` 或值非法 | 停止；核实目标层级后定向修订 `.docsconfig`。不得为补键重装 knowledge（会重置文档树） |
| `KNOWLEDGE_TYPE=meta` | 两个 Shell 入口均须显式传入 `--bundle` 与 `--layer`；环境变量 `BUNDLE` 不能替代显式参数。刷新入口写入前检查 |
| 显式 `--layer` 非法或与非 meta 配置冲突 | 停止；逻辑层不从目录名推断 |
| 缺 `AGENT_ROOT` / `AGENT_DIR` | 停止；补齐配置 |
| `$AGENT_ROOT/$AGENT_DIR/configs` 不存在或 `WORK_SPACE` 无效 | 停止；提示 `/agent-install --workspace` |
| bundle 或 `{DOC_DIR}/{AGENT_DIR}/skills/docs-okf/scripts` 不存在 | 停止；核对目标路径与安装软链 |

不得回退到默认 `application`、git 根或仓库内 `agent/`。

## 映射与覆盖

两个 Shell 入口共用 [resolve-okf-paths.sh](../scripts/resolve-okf-paths.sh)：

| 值 | 规则 |
| --- | --- |
| `BUNDLE` | CLI `--bundle PATH` / `--bundle=PATH` 优先，其次非空环境变量 `BUNDLE`，最后配置 `DOC_DIR` |
| 相对 bundle | 相对目标工程根；绝对路径保持绝对语义 |
| `OKF_VIZ_OUT` | 完整 bundle 路径下的 `viz.html`；移除 bundle 末尾多余 `/` |
| `OKF_VIZ_NAME` | 与默认 bundle 指向同一目录时为 `{KNOWLEDGE_TYPE} OKF`；否则为 `{bundle_basename} OKF` |
| `OKF_SCRIPTS` / `OKF_DIR` | `{DOC_DIR}/{AGENT_DIR}/skills/docs-okf/scripts` 的绝对路径；不随 bundle 覆盖变化 |
| `repo_abs` | 经配置与工作区文件核验的工程根 |

显式 CLI bundle 不得为空；指向不同目录的覆盖会输出提示。例如 `--bundle docs/archive/` 写入 `docs/archive/viz.html`，不是 `archive/viz.html`。

`resolve_okf_paths` 只解析配置映射；`resolve_okf_target` 再应用 bundle 覆盖、核对目录并设置上述运行变量。二者不生成知识产物；后者接受一个可选 bundle 参数。

独立运行 Python 脚本前须完成相同解析，并将 `DOCS_OKF_REPO_ABS` 设为 `repo_abs`，避免从安装目录寻找工程。完整命令见 [工作流](workflow.md)。

## 消费扫描范围

两个 Shell 入口支持重复 `--consumer-root PATH`，追加消费声明扫描根，并递归已登记 child；parent/dependency 只用于目标定位。覆盖结果区分声明扫描与目标定位，并记录不可读来源；局部结果不代表全联邦。生成与校验须传入相同范围。
