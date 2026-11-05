# 共享脚本

本目录提供安装、配置、联邦与文档校验的公共能力。Skill 的业务编排留在各自 `scripts/`；测试设施留在 `tests/`。运行环境为 Bash 5+、Python 3，具体命令依赖由调用入口检查。

## 入口

| 入口 | 用途 |
| --- | --- |
| [docs-core.sh](docs-core.sh) | 安装与联邦脚本的聚合 source 入口 |
| [lib/docsconfig.sh](lib/docsconfig.sh) | 轻量配置入口，供无需完整安装能力的工具 source |
| [lib/log-io.sh](lib/log-io.sh) | 日志、文件操作与 CLI 参数诊断的兼容入口 |
| [lib/knowledge-links.sh](lib/knowledge-links.sh) | 联邦清单路径与 YAML 读写入口 |
| [test-core.sh](test-core.sh) | 测试断言与用例运行入口 |

现有调用者继续 source 上述入口。下表中的拆分实现由门面加载，不作为新的公共加载接口。

## 模块职责

| 模块 | 单一职责 |
| --- | --- |
| [docsconfig-fields.sh](lib/docsconfig-fields.sh) | 配置字段解析、格式化与值校验 |
| [docsconfig-workspace.sh](lib/docsconfig-workspace.sh) | 配置定位、工作区与文档根解析、当前 shell 注入 |
| [docsconfig-store.sh](lib/docsconfig-store.sh) | 配置保存与 Agent 字段补全 |
| [backup.sh](lib/backup.sh) | 安装前备份路径、冲突命名与搬移 |
| [logging.sh](lib/logging.sh) | 日志与命令可用性检测 |
| [file-io.sh](lib/file-io.sh) | dry-run、目录同步、覆盖决策与文件拷贝 |
| [knowledge-link-paths.sh](lib/knowledge-link-paths.sh) | 清单所属工作区、占位路径与真实路径边界 |
| [knowledge-links-yaml.sh](lib/knowledge-links-yaml.sh) | 清单字段编解码、数组加载与序列化 |
| [path.sh](lib/path.sh) · [bash.sh](lib/bash.sh) | 路径基础操作；Bash 版本守卫 |
| [agents.sh](lib/agents.sh) · [agent-layout.sh](lib/agent-layout.sh) | IDE 名称与顺序；Agent 树和软链布局 |
| [resolve.sh](lib/resolve.sh) | 查找、选择及切换共享脚本副本 |
| [rewrite.sh](lib/rewrite.sh) | 知识库内 Agent 引用路径重写 |
| [git-remote.sh](lib/git-remote.sh) · [version.sh](lib/version.sh) | 远端地址读取；发布版本解析与比较 |
| [slot-softlink.sh](lib/slot-softlink.sh) | 旧槽位 API 兼容；与 docs-link 当前维护流程分开 |

依赖方向：Skill 编排 → 公共门面 → 职责模块 → 路径/日志等基础能力。测试设施可调用生产模块；生产模块不依赖测试。

## 兼容约束

- **换根加载**：先 `unset _AGENT_SHARED_DOCS_CONFIG_LOADED`，再 source 目标副本的 `docs-core.sh`。聚合入口清理已有门面哨兵；拆分实现不另设哨兵，随门面刷新。
- **轻量配置**：不要求先 source `docs-core.sh`；`WORK_SPACE`、`REPO_DIR`、`DOC_DIR`、`AGENT_*` 只赋值到当前 shell。
- **备份**：两个历史入口均保留备份 API；搬移软链本身，重名递增 `.__N`。
- **IO**：覆盖决策返回 `0/1/2/3`（覆盖/跳过/取消/未授权冲突），拷贝取消退出 `130`。非交互已有目标须设置 `IO_FORCE=1` 或 `IO_CONFLICT_MODE=overwrite_all`；安装器自行授权受管资源更新。目录同步在写前执行相同检查，授权后仍以 rsync 或 cp 回退替换目标内容。文件操作使用 `DRY_RUN` / `CFG[dry_run]` / `IO_DRY_RUN`，清单写入保留 `DRY`。
- **清单**：从所属库配置解析工作区；严格 loader 与维护容错只共享标量编解码，不合并错误策略。写前完整校验，同目录原子替换，失败保留原文件；格式与边界见 [联邦清单契约](../knowledge/federation-config.md#标量与写入保障)。
- **旧槽位**：保留现有函数名；只维护软链，遇普通文件或真实目录报错保留，删除不存在路径成功。当前 docs-link 仍使用自己的槽位流程。
- **Git 身份**：`git_remote_identity_key` 只忽略一个末尾 `/`，保留 `.git`、大小写与协议差异；HTTP 展示地址转换另行处理。远端读取优先 origin，兜底支持 worktree 的 `commondir`，只返回一个 URL。
- **版本**：[version.sh](lib/version.sh) 不改调用方 shell 选项；严格模式由执行入口设置。
- **安装**：同步 `scripts/` 运行资源，排除 `tests/`、`test-core.sh`、README 等研发材料，规则见 [安装器](../skills/agent-install/scripts/agent-install.sh)。隔离测试须另带入口及其依赖；兼容门面不是自包含文件。

## 校验与测试

| 工具 | 职责 |
| --- | --- |
| [validate-link-reachable.sh](tools/validate-link-reachable.sh) | 解析配置，调用 [Python 扫描器](tools/validate_link_reachable.py) 检查 Markdown 本地链接 |
| [forbidden-ref-outer.sh](tools/forbidden-ref-outer.sh) | 解析配置，调用 [引用隔离扫描器](tools/forbidden_file_refs.py)；覆盖隐藏和忽略的外部正文，排除会话内部、Git、其他 worktree 与依赖目录；退出 `0/1/2` 表示清洁/违规/工具错误 |
| [tests/lib/assertions.sh](tests/lib/assertions.sh) | 文件、目录、内容与软链断言 |
| [tests/lib/runner.sh](tests/lib/runner.sh) | 用例收集、Bash 选择与运行统计 |
| [tests/run.sh](tests/run.sh) | 单处登记聚合套件及 quick/full 分组 |

在仓库根使用 Bash 5+ 执行：

```bash
bash agent/scripts/tests/run.sh --quick
bash agent/scripts/tests/run.sh --full
bash agent/scripts/tests/run.sh --suite shared-config
bash agent/scripts/tests/run.sh --suite shared-io
bash agent/scripts/tests/run.sh --suite shared-runtime
bash agent/scripts/tests/run.sh --suite test-core
bash agent/scripts/tests/run.sh --suite docs-okf-browser
bash agent/scripts/tools/validate-link-reachable.sh
bash agent/scripts/tools/validate-link-reachable.sh --scope root-layers
bash agent/scripts/tools/forbidden-ref-outer.sh
```

`--quick` 保持共享能力与核心流程回归；`--full` 加入已登记的 Skill 测试，具体清单由 `--help` 展示。docs-tag 使用 pytest、Hypothesis、PyYAML，缺少依赖时报错，不以零用例通过。只有夹具而无可执行用例的目录不登记套件。

链接检查默认 `--scope agent`，保留 Agent 内互链、测试夹具排除与已登记模板输出位置校验。`--scope root-layers` 检查仓根及 application/system/solution/company 的 Markdown（含 TODO）；消费库使用其他 DOC_DIR 时也纳入该配置文档根。按当前文件相对路径核对本地目标及 Markdown 锚点，不以仓根同名文件兜底；消费库 `.agents` 链接仅允许进入配置指定的安装树。

新模式支持行内/引用式链接、URL 解码、ATX/Setext 标题、常用内联格式、重复标题后缀及显式 HTML ID。代码示例、frontmatter、注释和外部 URL 不作本地链接；不遍历 Agent、`.superpowers/` 会话材料、历史 `superpowers/`、依赖目录或软链目录，不读取联邦槽位中的外仓内容。显式会话材料文档根同样排除。EXAMPLE 与 assets 正文照常检查；未登记的动态模板目标、非 Markdown 锚点列为“待判断”并返回失败，排除项单独统计。`link-reachable` 套件先跑隔离回归，再检查当前元仓；已接入 quick，不依赖个人 WORK_SPACE 定位该检出。

浏览器回归单独选择 `docs-okf-browser`，需要 Node、Playwright、可用 Chrome/Chromium 和与生产 SRI 匹配的固定资源；通过 `NODE_PATH`、`OKF_BROWSER_EXECUTABLE`、`OKF_VIZ_ASSETS` 指定本地依赖。入口只校验、不下载；默认 full 显式跳过浏览器用例。旧 [OKF 夹具](tests/okf/fixtures-v1/) 保留为历史格式样例，不表示一个可通过当前校验的完整 bundle。
