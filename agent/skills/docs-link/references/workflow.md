# docs-link 工作流

当前单元与授权见 [gates.md](gates.md)。脚本 `--help` 给出完整 CLI；以下说明影响执行决策的语义。

先区分归属与消费：本 CLI 只处理 parent/child；消费定位、并发及恢复的目标契约见[联邦规范](../../../knowledge/federation-config.md)。含 dependency 的清单不得交现有 CLI 读写，不能改成 child 绕过兼容检查。

## 解析与预检

| 参数/状态 | 处理 |
| --- | --- |
| 源工作区 | cwd 必须为 company、solution 或 system 的 Git 根；核对 `.docsconfig` 与实际路径 |
| 动作 | `--link`、`--unlink`、`--check`、`--repair` 互斥；只有 check 可省略 target，表示全部 child |
| 本地 target | 首次 link 必须提供目标 Git 根；目标层级须恰好下一层，已有 `.docsconfig` 与 `knowledge-links.yaml` |
| 已登记目标 | check/repair 只按源清单的 `path` 定位；目标路径或已登记 URL 必须精确命中一个 child，不按目录名或名称猜选 |
| remote URL | 只能使用源清单已登记的 child URL，通过该条 `path` 定位本地仓；不发起网络操作 |
| 名称 | link 的 `--app-name` 对三种目标层均有效；优先级为显式值、已有 `name`、目标目录名；转小写，允许 `a-z0-9._-` 且首位为字母或数字 |
| 重复 link | 更新原 identity，不追加；保留已有 label。改名须预览旧软链移除和新软链建立，其他 child 占用名称则停止 |
| 配置与清单 | 双边工作区边界、必填字段、唯一 parent、child identity/name 均在写入前检查；check/repair 还要求反向 parent 与当前源一致 |
| 槽位冲突 | 普通文件/目录与槽位父目录软链均阻塞；link 对指向不符的软链停止，repair 可按登记修复 |

`--path` 是目标参数的弃用别名。重复目标、空值或非 link 搭配 `--app-name/--rewrite-http` 均失败。link/unlink/repair 省略 `--dry-run` 即写入；对话授权由调用方负责。

## 检查与修复

1. `--check` 不带 target 时遍历所有 child，即使一项失败也继续检查其余项，汇总逐项结果和总体状态；不自动转 repair。
2. `--check --target`、`--repair --target` 只处理所选登记。repair 必须有单一 target，不提供批量修复动作。
3. 缺仓、非 Git 目录、配置缺失/错配、身份冲突、反向 parent 不符均阻塞；不按 `dir` 猜路径，不搜索或 clone 替代仓，不自动补配置。
4. repair 预览须列出目标文档目录、槽位与拟操作。授权内仅补缺失软链或替换悬空/错误软链；正确软链（含相对链）不重写，真实文件/目录不替换。
5. 读回验证所选槽位；两侧 YAML、正文、HEAD、分支、Git index、FETCH_HEAD 与未选槽位均保持。dirty/detached 不阻塞，也不 stash/reset 或切分支。

缺仓或内容过旧时，转各仓普通 Git 工作流。槽位可达不证明内容已与远端同步；检查/修复不访问远端。

现有维护读取器只接受平面条目字段。嵌套结构、缩进不一致或重复 `type` 属于结构歧义，整份清单拒绝；其他重复/旧字段按条目报错，全量检查继续处理后续 child。dependency/entity_ids 属于待实现格式，不能据旧读取器拒绝结果断言新规范无效。

## 建联与注销

1. 运行兼容清单的单目标 `--dry-run`，列出源/目标 links 路径、identity、name、槽位映射。注销还须核实有效依赖、列出 HTTP 降级范围；脚本预览不覆盖此正文步骤，调用方须补齐计划。
2. 确认预览及授权覆盖清单、槽位与相关正文；按[并发与部分失败契约](../../../knowledge/federation-config.md#并发与部分失败)建立操作记录和冲突保护后执行。参数或文件基线变化须重新核对；缺少保障时不得将旧 CLI 当作完整执行器。
3. 读回验证：link 的源 child 与目标 parent 相互对应，槽位指向目标文档，改名后的旧槽位消失；unlink 的匹配 child/parent 与槽位消失，失去 parent 的 HTTP 已合法降级且有效依赖已解除或迁移。保留 meta 和无关条目；失联目标按下节报告。
4. 按[统一校验](../../../knowledge/knowledge-validation.md)分别报告登记/槽位、引用降级和跨库状态；全部适用项通过才称整体完成。受众 A/B 见 [audience-and-language.md](../../../references/audience-and-language.md)。

## 换父、失联与失败

- **换父**：目标 parent 会替换为当前源。旧源清单不在脚本单元内，须列为待注销项并在获授权的关联单元处理；旧登记和相关引用未闭合时不得宣称换父整体完成。不开启 `--rewrite-http` 时脚本保持正文原样，不能据此忽略引用失效。
- **HTTP 改写**：只调用 `docs-okf/scripts/okf_parent.py`；先预览，再在授权内执行。仅处理目标 `knowledge` 下 Markdown 的旧前缀，越界软链会被拒绝；无旧 parent 时没有改写来源。不能宣称扫描过的文件都已修改。
- **注销降级**：现有 unlink 没有正文改写能力；调用方须在同一授权计划中处理 HTTP 降级，不能传 `--rewrite-http` 给 unlink。无法确认原引用或降级后仍有有效依赖时停止相关步骤并保留未闭环状态。
- **失联 unlink**：目标路径、配置或清单缺失时，可在授权内按已登记 identity 处理源侧并移除槽位；明确标记“目标侧未更新、跨库待核实”，不称注销完成。目标配置存在但无效时停止，不假定其失联。此例外不适用于 check/repair。
- **中途失败**：保留实际状态并更新操作记录；重新核对两侧、槽位和正文后才续办未完成步骤，具体规则只在[联邦规范](../../../knowledge/federation-config.md#并发与部分失败)维护。不盲目重试或回滚；repair 建链失败也须报告未完成项。

不自动迁移旧格式、不删除真实槽位目录。环境与兼容问题见 [gotchas.md](../gotchas.md)。
