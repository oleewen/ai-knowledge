# 业务 knowledge 引用规范

> **定位**：四层业务 `knowledge/**` 可引用的目标、跨层形态及写入边界唯一真源。不适用于 `agent/knowledge/**`；Agent 元知识可链规则与布局文档。联邦清单、HTTP 生成与校验算法见 [federation-config.md](federation-config.md)。

## 允许目标与形式

层级从高到低：`company`、`solution`、`system`、`application`。跨层只许向上链接；上层反向关系指向下层时只写纯 ID。

| 目标 / 情况 | 允许形式 | 禁止 |
| --- | --- | --- |
| 同层 `knowledge/**` | bundle-relative 链接 | 链同层 knowledge 外的 ADR、阶段产物、层根 INDEX/index 等文档 |
| 五份视角 meta | Markdown 链解析到 `agent/knowledge/{business,product,application,data,technical}-meta.md`，可带锚点；元库从当前文件深度相对到根，安装后重写到 DOC_DIR 下 `.agents/knowledge/` | 其他 `agent/**`；非白名单目标手写爬层路径 |
| 上层首次定义实体，已登记 `type: parent` | 按 [联邦配置契约](federation-config.md)生成首次定义层 SSOT 的 HTTP | 手写跨 DOC_DIR 相对路径、逻辑 `/company/knowledge/...` 前缀、与生成结果不同的 URL；不链中间层 |
| 无 `type: parent` 的上层实体 | 纯 ID | 跨层 HTTP 或文件路径 |
| 更低层实体 | 反向边 `children`、`implemented_by`、`mapped_by`、`supported_by`、`used_by` 及上层 `uses_to` 只写纯实体身份；MS/API 使用限定身份 | Markdown 链或 HTTP 指向下层；引用联邦槽位 |
| PD 消费跨方案 SYS | `uses_to` 写纯 SYS ID；目标 SSOT 由 [消费定位登记](federation-config.md) 解析 | 用 child 改变 SYS 归属；正文手写下层 HTTP；以消费登记代替业务关系 |
| `resource` / 依据段的库外资产 | 外部 URI、表名、API 名、仓名 | Markdown 链或路径字面量指向库外文档文件；ADR 只摘录要点，无要点写尚无 |

`SYS` 的两条上游边固定纯 ID，按 [关系例外](entity-relations.md#例外与禁止)处理。

表中纯 ID 均指 [命名规范](naming-conventions.md#身份范围与限定引用) 定义的完整身份；限定符中的 `/` 不是本地文件路径。完整身份与实际文件链接必须一致，不能凭显示文字掩盖错链。既有裸 MS/API ID 的消歧和工具兼容按命名规范处理。

业务正文可使用纯文本证据编号，指向本库 [证据登记](knowledge-evidence.md) 的记录键：实体放在“依据与证据”段，章节或 overview 放在对应事实处。不把登记文件路径、下层源文档链接或恢复日志写入 knowledge。证据元数据位于 knowledge 外，可保存来源定位信息，不能据此扩大业务正文的引用白名单。

## 上游实体与目录宿主

首次定义在上层的实体，下层不建同 ID 的 reference 实体文件，不重复字段语义；目录宿主可留。首次定义层见 [治理规则](knowledge-governance.md#各层聚焦摘要)，实体落点与路径父级见 [知识布局](../references/knowledge-layout.md)。

## 读取与写入分离

技能可读取 solutions、阶段产物、联邦槽位等 knowledge 外源；写入 `knowledge/**` 的正文、链接、路径字面量及 frontmatter 外指须满足上表。读取外源不意味着可把源文档链接写入知识正文。

## 校验与违规修复

跨层 HTTP 使用统一生成函数，默认离线比对；清单解析与本机目标检查见 [联邦配置契约](federation-config.md)。

在已有修订授权内，可机械修复的库外/下层文档去链或改完整身份；跨层手写路径改为生成 HTTP，无 parent 则完整身份。身份、目标层或实体不明时停止受影响写入，列清单交用户确认。不得把 `/knowledge/...` 回退到下游 bundle。

无 parent 的跨层 HTTP 是确定性违规；已登记但目标暂不可读是待核实，不能据此判目标不存在。外库不可读时报告本地与跨库结果，完成边界见 [统一校验](knowledge-validation.md)；不能仅凭 URL 格式正确宣称内容已核实。
