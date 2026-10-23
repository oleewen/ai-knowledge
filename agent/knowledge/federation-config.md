# 联邦清单与引用解析

> **职责**：`knowledge-links.yaml` 的字段、工作区路径解析、跨层 HTTP 生成与离线校验。
> **边界**：层级与实体归属见 [knowledge-governance.md](knowledge-governance.md)；允许引用什么见 [knowledge-reference-rules.md](knowledge-reference-rules.md)；槽位落点见 [knowledge-layout.md](../references/knowledge-layout.md)。本文不定义建联操作步骤。

## 清单结构

每个文档根使用 `knowledge-links.yaml`；`type` 必写，只允许 `parent`、`child`、`meta`。

| type | 字段 | 约束 |
| --- | --- | --- |
| `parent` | `repository`、`path`、`dir`、`name`、`label` | 下级登记上级；`dir` 为上级 DOC_DIR；恰好一条；公司无 parent |
| `child` | 同上 | 上级登记下级；`dir` 为下级 DOC_DIR |
| `meta` | `repository`、`path`、`dir` | `dir` 为本库 KNOWLEDGE_TYPE，指向元仓模板子树；不带 name/label |

`label` 缺省等于 `name`。层别由所在库的 KNOWLEDGE_TYPE 与条目 `type` 决定，键上不写层前缀。parent 只允许治理规定的相邻上层，一库一个 parent。

`docs-install` 重装保留已有清单。旧 `knowledge-parent.yaml` 可留盘，但不再读写。登记、换父与注销步骤见 [docs-link](../skills/docs-link/SKILL.md)。

## 标量与写入保障

清单字段使用单行字符串：双引号支持 `\\`、`\"` 转义，单引号以 `''` 表示一个单引号；裸值按字面读取。未闭合引号、未知双引号转义及控制字符报错；不支持多行、锚点、对象或字段行内注释语法。写入器统一输出双引号，保留中文、空格、反斜杠与引号。

严格读取校验全部条目；维护读取按选中条目汇总字段错误，`type` 歧义全局拒绝。两者共享标量编解码，各自保留结构与错误处理规则，不作为通用 YAML 解析器。

写入前校验全部字段、数组与路径，dry-run 同样校验。目标仅允许普通文件或不存在，末段软链（含失效链接）、目录及其他特殊文件均拒绝；合法父目录软链可用。先写同目录临时文件，再原子替换；校验或 IO 失败不截断原文件，已有权限位保留，新文件为 `0644`。

原子性只覆盖单份清单，不承诺两库同时提交、并发协调或掉电持久化；owner/ACL/扩展属性不在保留契约内。双边操作中断仍须核对两侧。

仓库身份比较只忽略单个末尾 `/`；`.git`、大小写与 SSH/HTTPS 差异不自动等价。下节 HTTP 展示转换不用于身份判重。

## knowledge-links 路径契约

所有条目的 `path` 只保存字面量 `${WORK_SPACE}/仓库相对路径`；工作区根可写 `${WORK_SPACE}`。

1. 从清单所属库的 `.docsconfig` 读取 `AGENT_ROOT`、`AGENT_DIR`。
2. 从该 Agent 树的 `configs` 读取 `WORK_SPACE`。不得用同名环境变量覆盖，不执行 `eval` 或任意变量展开。
3. 解析后校验工作区边界，包括 `..` 与符号链接。配置缺失、旧 `~/…` / 绝对路径、越界均报错停止。
4. 写入接口先校验本机路径，再转成占位符；双边建联分别使用各库配置。Bash 边界检查依赖 Python 3。

迁移旧清单时，仅把工作区前缀换成 `${WORK_SPACE}`，保留其余字段；越界项不迁移。读取器与已授权清单一起迁移；未迁移清单不再兼容。

## HTTP 生成

技能、docs-link 与校验共用同一生成规则，禁止手写不同的 href：

1. 输入实体 `id` 与[首次定义层](knowledge-governance.md#各层聚焦摘要)，沿 parent 链到该层。
2. 解析根优先 `{repository}/{dir}`，否则用 `{path}/{dir}` 本机定位。
3. `repository` 的 SSH 地址转 HTTPS、去 `.git`；HTTP `ref` 固定 `main`。
4. GitHub / Gitee 使用 `/blob/{ref}/`；GitLab 使用 `/-/blob/{ref}/`。
5. 文件相对路径使用**目标层**的 `entity_relpath`；不链中间层。目录规则见 [knowledge-layout.md](../references/knowledge-layout.md#文件与目录落点)。

未知宿主不生成 HTTP，只以 `path` + `dir` 定位；本机不存在时正文保持 ID。无 parent 的降级、向下反向边及可链接范围以[引用规范](knowledge-reference-rules.md)为准。

## 变更与离线校验

| 场景 | 要求 |
| --- | --- |
| 有 parent | href 必须等于推导的 web_base + 目标层 relpath；本机 path 存在时再查文件 |
| 无 parent | 跨层 HTTP 判失败；不得把 `/knowledge/...` 回退到下游 bundle |
| 校验方式 | 默认离线，不发 HTTP GET |
| repository / ref / dir 变化 | docs-link 扫描下级 `*/knowledge/**`，替换旧 web_base；换上级时须传 `--rewrite-http` 才替换旧 HTTP 前缀 |
| unlink | 能改为纯 ID 则改；否则停止并列待处理清单 |

本文规定结果契约；具体工具行为与授权仍以 [docs-link](../skills/docs-link/SKILL.md) 为准。
