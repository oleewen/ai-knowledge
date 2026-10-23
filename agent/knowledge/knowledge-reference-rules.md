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
| 更低层实体 | 反向边 `children`、`implemented_by`、`mapped_by`、`supported_by`、`used_by` 及上层 `uses_to` 只写纯 ID | Markdown 链或 HTTP 指向下层；引用联邦槽位 |
| `resource` / 依据段的库外资产 | 外部 URI、表名、API 名、仓名 | Markdown 链或路径字面量指向库外文档文件；ADR 只摘录要点，无要点写尚无 |

`SYS` 的两条上游边固定纯 ID，按 [关系例外](entity-relations.md#例外与禁止)处理。

## 上游实体与目录宿主

首次定义在上层的实体，下层不建同 ID 的 reference 实体文件，不重复字段语义；目录宿主可留。首次定义层见 [治理规则](knowledge-governance.md#各层聚焦摘要)，实体落点与路径父级见 [知识布局](../references/knowledge-layout.md)。

## 读取与写入分离

技能可读取 solutions、阶段产物、联邦槽位等 knowledge 外源；写入 `knowledge/**` 的正文、链接、路径字面量及 frontmatter 外指须满足上表。读取外源不意味着可把源文档链接写入知识正文。

## 校验与违规修复

跨层 HTTP 使用统一生成函数，默认离线比对；清单解析与本机目标检查见 [联邦配置契约](federation-config.md)。

可机械修复时直接修复：库外/下层文档去链或改纯 ID；跨层手写路径改为生成 HTTP，无 parent 则纯 ID。目标层或实体不明时停止受影响写入，列清单交用户确认。不得把 `/knowledge/...` 回退到下游 bundle。
