# docs-install 工作流

## 执行前

参数选择见 [parameters.md](parameters.md)，授权与停止点见 [gates.md](gates.md)。先确认：

- **运行环境**：Bash 5+、Python 3、Git；Python 用于缺失路径与符号链接解析。技能须位于完整 Agent 树内，因为脚本复用 `scripts/docs-core.sh` 等共享库。knowledge 的路径改写和 README 注记需要 Perl，缺失时在任何写入前停止；config 不要求 Perl。
- **目标**：`--target` 是文档目录，须为工程根的子目录；工程根缺失时确认 `-r`。源与目标不能重叠。
- **Agent 路径**：已有有效 `AGENT_ROOT` + `AGENT_DIR` 则保留；否则依次探测 `.agents`、`.cursor`、`.codex`、`.claude`、`.trae`、`.kiro`。`AGENT_ROOT` 是父目录（如 `~`），不能直接指向实体树；全无则先解决 Agent 安装前置。
- **knowledge 专有前置**：源层目录存在，源 Git remote 可读；Agent 树 `configs` 的 `WORK_SPACE` 能覆盖源仓与目标工程。已有建联路径必须通过 [路径契约](../../../knowledge/knowledge-governance.md) 校验。

从已安装技能调用时，按 [parameters.md](parameters.md) 指定 knowledge 的元库；config 不依赖元库。

## 预览与执行

1. 使用已收口参数运行 `--dry-run`，展示模板源、目标、配置键、备份与建联影响。只有退出码为零才称预览通过。非空目标即使未传 `--force`，预览也会展示备份与重置计划，便于审阅；这不表示允许实跑，也不能据此推断环境变量生效。无 `--force` 的非空目标实跑会在写入前拒绝。用户要求保留正文时停在预览，并转向 `docs-upgrade`。
2. 按 [gates.md](gates.md) 核对授权，去掉 `--dry-run` 执行同一计划。参数或目标状态发生实质变化时重新预览。
3. 任一步失败即停，报告失败阶段、已写入范围与备份位置；修复原因后再决定重试，不能把局部完成当整单成功。路径改写或 README 注记失败返回非零，可能已复制模板、写入配置、登记 meta 并建链；保留这些事实及原文备份，不自动回滚或重复重装。

## 产物校核

| 范围 | 核对 |
| --- | --- |
| config | 仅工程根 `.docsconfig` 被重写；路径键与 `AGENT_*` 正确，不写 `KNOWLEDGE_TYPE`，不创建文档目录、软链或修改正文 |
| knowledge | 模板符合层级与模式；`.docsconfig` 含对应 `KNOWLEDGE_TYPE`；已有关系保留，安装源更新为一条 `type:meta` |
| knowledge 的设计入口 | 源有根级 `DESIGN.md` 时整文件同步，central 亦包含；源无则不造。语义真源仍为 `knowledge-governance.md` |
| knowledge 的 Agent 引用 | 非 meta：`DOC_DIR/.agents` 链到 `$AGENT_ROOT/$AGENT_DIR`；裸 `agent/`、`../agent/`、`~/.agents/` 按文件深度改为相对 `.agents/`。meta：不建链，以含 `agent/` 的仓根为锚改为深度相对 `agent/`。不改 IDE 段 |

只在 `--target` 同步文档；工程根的 `.docsconfig` 和备份目录是配套写入。不向目标安装 `docs-link.sh` / `link-config.sh`。

## 双轨装机

先核实可用 Agent 树与 `WORK_SPACE`。缺失时，须在获得 Agent 安装授权后先运行 `agent-install`，再运行 `docs-install`；已有前置时可直接初始化知识库，无须为凑顺序重装 Agent。仓根 `bootstrap.sh` 选择 both 时先安装 Agent、再初始化知识库，Agent 失败即停；单选 docs 不补装 Agent。仅初始化知识库的授权不等于授权修改全局 Agent 环境。

bootstrap 的 `--meta PATH` 复用已有元库，不克隆、不更新或清理它。未指定时，docs/both 将克隆的元库保留到 `WORK_SPACE/ai-knowledge`，作为 `type:meta` 的持久来源；已有该目录则停止，须显式选择 `--meta`。agent-only 未指定元库时仍使用临时克隆。docs-only 从已有 Agent 配置读取工作区；手动调用 docs-install 的 `--meta`、路径和授权规则不变。
