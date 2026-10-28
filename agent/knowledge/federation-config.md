# 联邦清单与引用解析

> **职责**：`knowledge-links.yaml` 的归属与消费定位、工作区路径、跨层引用及联邦写入保障。
> **边界**：层级与实体归属见 [knowledge-governance.md](knowledge-governance.md)；允许引用什么见 [knowledge-reference-rules.md](knowledge-reference-rules.md)；槽位落点见 [knowledge-layout.md](../references/knowledge-layout.md)。本文不定义建联操作步骤。

## 清单结构

每个文档根使用 `knowledge-links.yaml`；`type` 必写，规范允许 `parent`、`child`、`meta`、`dependency`。`dependency` 是本次新增契约，现有读写器尚未支持，见[实现边界](#实现边界)。

| type | 字段 | 约束 |
| --- | --- | --- |
| `parent` | `repository`、`path`、`dir`、`name`、`label` | 下级登记唯一归属上级；`dir` 为上级 DOC_DIR；已建联时恰好一条，未建联时可无；公司无 parent |
| `child` | 同上 | 上级登记下级；`dir` 为下级 DOC_DIR |
| `meta` | `repository`、`path`、`dir` | `dir` 为本库 KNOWLEDGE_TYPE，指向元仓模板子树；不带 name/label |
| `dependency` | `repository`、`path`、`dir`、`name`、`label`、`target_layer`、`entity_ids` | 消费方单边登记外库 SSOT 定位；不建立归属或槽位 |

`label` 缺省等于 `name`。parent/child 层别由所在库的 KNOWLEDGE_TYPE 与条目 `type` 决定，键上不写层前缀。parent 只允许治理规定的相邻上层，一库最多一个 parent。

`docs-install` 重装保留已有清单。旧 `knowledge-parent.yaml` 可留盘，但不再读写。登记、换父与注销步骤见 [docs-link](../skills/docs-link/SKILL.md)。

### 消费定位

`dependency` 只解决纯 ID 定位，不重复业务关系。PD 维护共享 SYS 的消费关系；SYS 的消费方汇总由 PD 派生，规则见[治理](knowledge-governance.md)及[关系模型](entity-relations.md)。不得用 child 登记消费方，或为了消费 SYS 而换其 parent。

- `target_layer` 必须是四层之一，并与目标库配置、目标实体首次定义层相符；`dir` 是目标库实际 DOC_DIR。
- `entity_ids` 是非空、无重复的 YAML 单行字符串列表，保存目标的规范身份；APP/MS/API 使用[命名规范](naming-conventions.md)的限定身份。其余字段仍为单行字符串。
- 先按关系目标身份精确命中 `entity_ids`，再由 `path` + `dir` 定位目标库，读取目标实体核对身份与唯一正文。不得按文件名相似度、首个命中或目录名猜选；同一身份映射多个 SSOT 即冲突。
- 归属链已经唯一定位的实体不重复登记；跨归属树消费使用 dependency。登记不赋予写权限、不产生反向登记、不挂槽位、不进入上行蒸馏树。
- 外库不可读时可报告“本地通过、跨库待核实”，不得把纯 ID 当作已验证。相关删除、迁移或注销在跨库影响核实前不能闭环，按[统一校验](knowledge-validation.md)处理。

## 标量与写入保障

下述单行标量与旧读写器规则适用于 parent/child/meta；dependency 的 entity_ids 列表是新增格式例外，须由升级后的读写器处理。

清单字段使用单行字符串：双引号支持 `\\`、`\"` 转义，单引号以 `''` 表示一个单引号；裸值按字面读取。未闭合引号、未知双引号转义及控制字符报错；不支持多行、锚点、对象或字段行内注释语法。写入器统一输出双引号，保留中文、空格、反斜杠与引号。

严格读取校验全部条目；维护读取按选中条目汇总字段错误，`type` 歧义全局拒绝。两者共享标量编解码，各自保留结构与错误处理规则，不作为通用 YAML 解析器。

写入前校验全部字段、数组与路径，dry-run 同样校验。目标仅允许普通文件或不存在，末段软链（含失效链接）、目录及其他特殊文件均拒绝；合法父目录软链可用。先写同目录临时文件，再原子替换；校验或 IO 失败不截断原文件，已有权限位保留，新文件为 `0644`。

现有原子替换只覆盖单份清单；owner/ACL/扩展属性与掉电持久化不在保留契约内。目标契约要求下节的本机冲突检测与双边恢复，不承诺跨库同时提交。

仓库身份比较只忽略单个末尾 `/`；`.git`、大小写与 SSH/HTTPS 差异不自动等价。下节 HTTP 展示转换不用于身份判重。

### 并发与部分失败

以下为待实现的共同写入契约，不能由现有脚本退出码推定满足：

1. 按参与文档根的规范绝对路径排序取得本机排他锁，核对文件读取指纹后再写；写入和恢复均须保留他人的后续编辑。锁冲突、指纹变化或无法确认锁持有者时停止，不能覆盖或擅自清锁。
2. 写入前在发起库 `{DOC_DIR}/governance/operations/{operation_id}.yaml` 记录操作 ID、参与仓库、授权范围、目标文件、写前指纹、预期写后指纹和阶段。该容器是操作元数据，不复制实体正文；涉及另一库的更改仍须相应授权。
3. 每步完成后记录实际状态；失败时标记部分完成并保留现场。恢复须重新取得锁，核对两侧、槽位及相关正文；当前状态符合原计划才续办未完成步骤。冲突或范围变化先修订计划，不盲目重跑、回滚或覆盖。
4. 只有各步骤及受影响引用通过统一校验才标记完成；跨库待核实不能结束相关删除、迁移或注销。操作记录按本库 Git 管理，不能用完成即删的 TODO 代替。
5. 本机锁不协调不同机器。各仓按 Git 工作流集成后重新核对双边登记、消费定位、有效依赖与引用；Git 合并成功不等于语义通过。

## knowledge-links 路径契约

所有条目的 `path` 只保存字面量 `${WORK_SPACE}/仓库相对路径`；工作区根可写 `${WORK_SPACE}`。

1. 从清单所属库的 `.docsconfig` 读取 `AGENT_ROOT`、`AGENT_DIR`。
2. 从该 Agent 树的 `configs` 读取 `WORK_SPACE`。不得用同名环境变量覆盖，不执行 `eval` 或任意变量展开。
3. 解析后校验工作区边界，包括 `..` 与符号链接。配置缺失、旧 `~/…` / 绝对路径、越界均报错停止。
4. 写入接口先校验本机路径，再转成占位符；双边建联分别使用各库配置。Bash 边界检查依赖 Python 3。

迁移旧清单时，仅把工作区前缀换成 `${WORK_SPACE}`，保留其余字段；越界项不迁移。读取器与已授权清单一起迁移；未迁移清单不再兼容。

## HTTP 生成

技能、docs-link 与校验共用同一生成规则，禁止手写不同的 href：

1. 输入[完整身份](naming-conventions.md#身份范围与限定引用)与[首次定义层](knowledge-governance.md#各层聚焦摘要)，沿 parent 链到该层；裸 MS/API ID 仅在归属链及查找范围内已证明唯一时兼容补全。
2. 解析根优先 `{repository}/{dir}`，否则用 `{path}/{dir}` 本机定位。
3. `repository` 的 SSH 地址转 HTTPS、去 `.git`；HTTP `ref` 固定 `main`。
4. GitHub / Gitee 使用 `/blob/{ref}/`；GitLab 使用 `/-/blob/{ref}/`。
5. 先核对完整身份、归属链与实体台账，定位唯一 SSOT 文件，再编码该文件的仓内路径；不链中间层。新建落点按**目标层**布局推导，见 [knowledge-layout.md](../references/knowledge-layout.md#文件与目录落点)。既有 `entity_relpath` 仅可处理已支持且唯一的旧形态，不把限定身份的 `/` 当作实体路径传入。

未知宿主不生成 HTTP，只以 `path` + `dir` 定位；本机不存在时正文保持 ID。无 parent 的降级、向下反向边及可链接范围以[引用规范](knowledge-reference-rules.md)为准。

## 变更与离线校验

| 场景 | 要求 |
| --- | --- |
| 有 parent | href 必须等于推导的 web_base + 目标层 relpath；本机 path 存在时再查文件 |
| 无 parent | 跨层 HTTP 判失败；不得把 `/knowledge/...` 回退到下游 bundle |
| 校验方式 | 默认离线，不发 HTTP GET |
| repository / ref / dir 变化 | docs-link 扫描下级 `*/knowledge/**`，替换旧 web_base；换上级时须传 `--rewrite-http` 才替换旧 HTTP 前缀 |
| unlink | 先核实并解除或迁移有效依赖；在已授权范围内移除登记/槽位并将失去 parent 的 HTTP 降级纯 ID。不能合法降级或跨库影响未核实时保留未闭环状态 |

注销结果分别报告“登记/槽位已处理”“引用已降级”“跨库校验状态”；全部适用项通过才称注销完成。历史证据关联不阻止删除，仍生效的事实依赖须先处理，见[证据规范](knowledge-evidence.md)。

## 实现边界

现有清单读写器及 docs-link 仅支持 parent/child/meta；不支持 dependency/entity_ids、本机锁与操作恢复记录。含新条目的清单不得交旧 CLI 读写，也不得把 dependency 伪装成 child。须先完成工具升级，或由获授权的执行者按本规范维护并逐项校验；无法满足写入保障时停止写入。

新身份、消费登记与治理元数据的采用须按 [Profile v2](knowledge-profile-v2.md) 记录基线及兼容结果。现有 HTTP 生成器未接入完整身份时，不处理同名 MS 等有歧义输入，也不降级成可能错指的 URL。

现有 `--unlink` 只处理登记和槽位，不降级正文 HTTP；它的成功仅表示该局部步骤完成。调用方须把正文降级纳入已确认计划，并在校验后给出整体状态。现有 `--rewrite-http` 仅适用于 link，不能作为 unlink 参数。来源版本证据另按[证据规范](knowledge-evidence.md)保存，不以固定 `main` 链接冒充内容基线。
