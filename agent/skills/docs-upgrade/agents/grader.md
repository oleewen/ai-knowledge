# docs-upgrade Grader

据 **evals/evals.json** 输出 JSON：`text`、`passed`、`evidence`。

## 判定

1. 读 `category`：`should-trigger` / `should-not-trigger`
2. **硬门**：以本 eval 的 `assertions`（按 `priority`）为准；`evidence` 映射 `assertions[].id`
3. **协议释义**（assertions 覆盖时强制）：轻流程 → 整树 dry-run 清单或文件总览 → `C/M/S/F`；`C`=可处理项（对齐节按 H2至H6 元库结构重填；根级 `DESIGN.md` 整文件覆盖），有未落位则 `C` 后出策略三档（批量文件并入 / 单文件批量并入 / 逐项并入），`M` 可下钻单文件；禁清空式 `docs-install --scope=knowledge`；`--apply-scaffold` 收尾须体现 `.agents` 软链 + `agent/`→深度相对 `.agents/` 路径重写（同 docs-install；不改 IDE 段；dry-run 不做）；结构重填=同标题不比层级、正文相对元库标题级平移（级封顶 H6）；并入=原父级（同标题并入、层级递增；父消失→追加文末）；根级 `CONTRIBUTING.md` 未落位与普通 md 同策略；写后受众维 A/B（见 [audience-and-language.md](../../../references/audience-and-language.md)）；整树与指定路径文件模式互斥（不依赖 `@` 前缀）；根级 `CONTRIBUTING.md` 按普通 md 升级；根级 `DESIGN.md` 整文件覆盖；`*-slots` 根真文件可升级、软链跳过、顶层遗留槽位名仍忽略。见 [light-flow-actions.md](../../../references/light-flow-actions.md)、[gates.md](../references/gates.md)、[merge-rules.md](../references/merge-rules.md)
3.1 指定目录协议硬断言：总览名单必须来自本库与元库同相对路径并集；显式列出 `meta-only` scaffold 文件，并断言动作数覆盖并集总数。只扫描 `DOC_ROOT` 判错。

4. **P0** 任一失败 → `passed: false`
