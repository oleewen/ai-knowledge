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
| [federation-write.py](tools/federation-write.py) | docs-link/docs-install 共用写入引擎：增量消费登记、本机锁、指纹、操作记录与显式续办；对外参数见 [docs-link](../skills/docs-link/SKILL.md) |
| [validate-knowledge.sh](tools/validate-knowledge.sh) | 只读统一实体校验：结构、身份、确定性关系、引用与事实状态；强制配置、显式逻辑层、规则及源快照；JSON 与人读摘要 |
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

## 统一知识校验

从目标工程内运行已安装 Agent 树中的 `scripts/tools/validate-knowledge.sh`（Bash 5+、Python 3）。默认扫描配置的整个 DOC_DIR；元库须显式选择逻辑层和 bundle，不从目录名推断。

```bash
# 元仓示例
bash agent/scripts/tools/validate-knowledge.sh --layer solution --bundle solution
bash agent/scripts/tools/validate-knowledge.sh --layer solution --bundle solution --json
# 局部批次：file 相对调用目录；scope 相对选定文档根，可重复并取并集
bash agent/scripts/tools/validate-knowledge.sh --layer solution --bundle solution --scope knowledge/product
```

`--file PATH` 限定 Markdown 文件；`--scope DIR` 限定目录。为检查本库重复身份及目标关系，局部批次仍只读扫描本库实体上下文，并在结果中标记选择范围；不据此宣称全联邦完整。文件与范围不得越出 bundle，隐藏目录、目录软链及会话材料不作为扫描对象。

默认人读摘要；`--json` 的 stdout 是单一 JSON，包含 `schema_version`、`status`、`context`、`checks`、`summary`。每项包含 `domain/status/object/rule/evidence/limits`。分项五态见[统一规范](../knowledge/knowledge-validation.md)；汇总为 `PASS/FAIL/INCOMPLETE`。有 FAIL 返回 1，否则返回 0；退出 0 但 INCOMPLETE 不能用于宣称验收或迁移完成。配置/参数失败同样产生 FAIL 报告。

实体 frontmatter 使用受限 YAML 格式：顶层单行字段、字符串与行内列表；支持引号和行尾注释。字符串字段中的数值或布尔值须加引号。重复键、未闭合引号、嵌套映射、锚点、标签、块标量及多行列表会明确报错；当前解析器不支持完整 YAML 语法。

规则版本/commit、实际文件 SHA-256、配置及已读来源快照随 JSON 输出；来源在读取期间变化则相关通过结论降为待核实。工具按当前规则基线诊断，不自动批准 Profile 采用。事实真实性需人工核验；MS/API 根据已读归属链解析完整身份，局部重名保留多候选；依赖未核实时明确 UNVERIFIED。当前库、显式消费库及已登记 child 递归汇总 PD→SYS，父链/dependency 只读定位目标；全局覆盖不足仍为 UNVERIFIED。工具不改文件、不修复、不迁移。

`docs-build` 校验保留 README 台账及导航块检查；`docs-okf` 校验保留根索引元数据检查，两者的实体校验共用此核心。旧 Python `Validator` 类保留为底层兼容接口，其历史结果不代表统一校验通过；使用 CLI 取得新协议结果。

`--consumer-root PATH` 可重复追加消费库文档根（相对调用目录），递归已登记 child，按实际路径去重、防环。`context.identities` 列完整身份及证据，`context.coverage` 列读取范围，`context.consumption` 列 PD→SYS 派生结果。显式 dependency 精确指定 SSOT；离线或冲突不从其他库代选。升级后的 docs-link/docs-install 使用 Python 联邦写入器保留 dependency；未升级的六数组 Bash 写入 API 遇到 dependency 仍明确停止。

```bash
bash agent/scripts/tools/validate-knowledge.sh --layer system --bundle system --consumer-root /workspace/consumer/docs --json
# 仅预览归属变化，两个参数成对使用；不会执行文件迁移或引用改写
bash agent/scripts/tools/validate-knowledge.sh --layer system --bundle system --move-identity APP-A/MS-Q --to-owner APP-B --json
```

迁移预览位于 `context.migration`：列源/目标身份、候选文件路径、Markdown 引用、dependency.entity_ids 登记及阻塞，`executable` 固定为 false。归属变化连带下级 API；目标冲突、歧义、不可读库均阻塞。跨 APP 的 API 所在目标应用库须另行核实，所列当前库路径不表示获准迁移。覆盖外的引用和 Profile 采用仍须补核。

OKF 导航显示 APP/MS/API 完整身份，图保留实际文件节点键并展示纯 ID 关系、消费边、消费方及覆盖说明。`okf-indexing.sh`、`okf-validate.sh`、`visualize.py` 与 `validate_viz_index.py` 接受同一组 `--consumer-root`；生成与产物校验须使用相同范围。生成前检查完整身份冲突与清单错误；未核实节点明确标记。

## 证据与升级兼容

[knowledge-evidence.py](tools/knowledge-evidence.py) 按[证据登记契约](../knowledge/knowledge-evidence.md)维护治理元数据，使用现有锁、指纹与操作日志。Bash 5+ 须在 PATH 中，或设置 `KNOWLEDGE_VALIDATION_BASH` 为其绝对路径；Python 3 使用 `-B` 避免缓存写入。`--doc` 必须是配置对应的消费库文档根。

```bash
python3 -B /path/to/agent/scripts/tools/knowledge-evidence.py create --doc /workspace/consumer/docs --input /path/to/evidence.json
# 已授权写入时添加 --apply；默认预览不写任何文件
python3 -B /path/to/agent/scripts/tools/knowledge-evidence.py update --doc /workspace/consumer/docs --id EVID-000001 --input /path/to/changes.json --apply
python3 -B /path/to/agent/scripts/tools/knowledge-evidence.py refresh --doc /workspace/consumer/docs
python3 -B /path/to/agent/scripts/tools/knowledge-evidence.py check --doc /workspace/consumer/docs
python3 -B /path/to/agent/scripts/tools/knowledge-evidence.py resume --doc /workspace/consumer/docs --operation-id ORIGINAL_ID --apply
```

`create` 最小输入示例（实际身份、路径及范围须已读取核实）：

```json
{
  "target_identity": "consumer:docs/knowledge/target.md",
  "target_path": "docs/knowledge/target.md",
  "sources": [{
    "identity": "provider:docs/knowledge/source.md",
    "repository": {"path": "${WORK_SPACE}/provider", "dir": "docs"},
    "path": "docs/knowledge/source.md"
  }]
}
```

默认自动编号、计算原始字节哈希和带时区采集时间，记录待落盘/待核验。只有显式 `commit` 为完整 SHA 且该路径字节匹配，才登记指定 Git 版本可恢复；不搜索历史、不使用 HEAD 猜测。内联输入在该来源增加 `inline_text`，repository 为“不适用”、path 为 `message:` 定位；正文仅用于哈希比对，不写入元数据或操作日志。

`update` 输入可含 review_status、reviewer、conclusion、processing、buffer；首次落盘同时提供实际 target_sha256。来源状态按 `sources: [{"index": 1, "dependency": "有效"}]` 更新；解除另给 release_basis 和核验人。人提供 reviewer 的 name/带时区 at 及结论，工具不自动认可事实。已绑定来源/目标版本变化必须新建记录并填写 previous。`refresh` 只标记已登记且受影响的记录；`check` 的 PASS 不覆盖未登记事实，历史恢复在 sources.recovery_status 单列。FAIL 或 INCOMPLETE 返回 1；元数据写入命令退出零只表示该操作完成。

[upgrade-compat.py](tools/upgrade-compat.py) 只读输出五面兼容报告与 assessment_template：

```bash
python3 -B /path/to/agent/scripts/tools/upgrade-compat.py --doc /workspace/consumer/docs --diagnostic
python3 -B /path/to/agent/scripts/tools/upgrade-compat.py --doc /workspace/consumer/docs --assessment /path/to/assessment.json
```

诊断允许 INCOMPLETE 返回零；最终严格检查仅 `can_advance_version: true` 返回零。评估字段、旧基线报告及快照规则见[升级入口](../skills/docs-upgrade/references/workflow.md#兼容检查入口)。工具不执行业务实体迁移、不推进版本。自动化回归为 `bash agent/scripts/tests/run.sh --suite knowledge-evidence`，已纳入 quick/full；这不替代技能行为评测或真实消费环境验收。

## 隔离行为评测

[behavior-evals](tests/behavior-evals/README.md) 单独覆盖安装、旧格式、联邦消费、操作恢复、证据生命周期和升级门禁。每组场景都在临时 HOME、临时元库副本和临时文档根中执行，使用独立 Agent 实操及独立评分；脚本回归通过不能替代行为评测。结果只允许 `passed`、`failed` 或 `not_run`，超时、认证或夹具缺失统一记 `not_run`。2026-11-07 的 10 组尝试均在隔离执行窗口内超时，详见 [结果](tests/behavior-evals/results-2026-11-07.json)，未宣称行为通过。
