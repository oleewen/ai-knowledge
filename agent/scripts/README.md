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
| [refresh-codex.sh](refresh-codex.sh) | 独立的 Codex 刷新流程；测试通过 stub 隔离外部操作 |

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
| [forbidden-ref-outer.sh](tools/forbidden-ref-outer.sh) | 单次扫描，按匹配位置计数；退出 `0/1/2` 表示清洁/违规/工具错误 |
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
bash agent/scripts/tools/forbidden-ref-outer.sh
```

`--quick` 保持共享能力与核心流程回归；`--full` 加入已登记的 Skill 测试，具体清单由 `--help` 展示。docs-tag 使用 pytest、Hypothesis、PyYAML，缺少依赖时报错，不以零用例通过。只有夹具而无可执行用例的目录不登记套件。

浏览器回归单独选择 `docs-okf-browser`，需要 Node、Playwright、可用 Chrome/Chromium 和与生产 SRI 匹配的固定资源；通过 `NODE_PATH`、`OKF_BROWSER_EXECUTABLE`、`OKF_VIZ_ASSETS` 指定本地依赖。入口只校验、不下载；默认 full 显式跳过浏览器用例。旧 [OKF 夹具](tests/okf/fixtures-v1/) 保留为历史格式样例，不表示一个可通过当前校验的完整 bundle。
