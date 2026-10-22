# sdx-solution 工作流

主干：[SKILL.md](../SKILL.md)。推进 binding：[gates.md](gates.md)。

## 目标

按段形成可评审的交付包切分叙事；共享契约入口见 [gates.md](gates.md)。

## 参数向导

先读目标库 `.docsconfig`，解析 `DOC_DIR`、`KNOWLEDGE_TYPE`；不因元仓有 `solution/` 就把它视为当前文档根，不改配置来绕过层级限制。

收口下列参数；用户已明确的直接采用：

| 参数 | 处理 |
| --- | --- |
| 模式 | 新建首份、新建后继、续写指定草稿 |
| IDEA-ID / 标题 | 已给则沿用；未给按 [core-concepts.md](core-concepts.md) 提议，确认后使用 |
| 前驱 / 当前稿 | 新建确认首份或前驱 ID；续写读取指定稿及已确认段 |
| 当前段 | 默认从首段开始；续写恢复用户指定进度，不重写前文 |
| 输出 | `{DOC_DIR}/solutions/SOLUTION-{IDEA-ID}.md`；确认可写及是否已存在 |

读取 `solutions/` 内全部 SOLUTION 的 `id` / `parent`，按 [版本规则](core-concepts.md#多份与现行) 核对。续写须明确当前草稿身份，不能只凭 `status: draft` 推断授权。

从同库 knowledge 索引下钻本段所需实体与关系；仅列出 ID 不等于已核实内容。涉及技术例外时核实公司技术基准。本段所需实体、关系或基准缺失时停在缺口，不补造事实。

## 段落

1. 按模板选择当前段，输出公共六项澄清；额外说明实体证据、前驱增量与受影响前文。
2. 写前确认后，新建时填充 [模板](../assets/solution-template.md) 元数据并建立六段骨架，只写当前段正文；续写只更新当前段和必要日期。模板注释不进入成品。
3. 写完即烤干；收敛后等用户动作，再推进下一段。`F`、语义修订与前文重开均按共享推进协议处理。

## 写后默认表

| 对象 | 默认 | 核实重点 |
| --- | --- | --- |
| 每个当前段（含批量补齐） | 必须烤干 | 事实、关系、跨段一致性及 [受众 A/B/C/E](audience-and-language.md) |

## 校验与交付

在目标库或其子目录运行已安装的 `scripts/validate-solution.sh`（Bash 5+；依赖同一 Agent 树的 `scripts/lib/`）：

| 调用 | 范围 |
| --- | --- |
| `bash /path/to/sdx-solution/scripts/validate-solution.sh` | 全部 SOLUTION 的结构、正文禁区和版本链 |
| `bash /path/to/sdx-solution/scripts/validate-solution.sh --file <path>` | 指定文件的结构/正文；版本链仍检查整个 `solutions/`；相对路径基于调用目录 |
| `bash /path/to/sdx-solution/scripts/validate-solution.sh --help` | 查看参数，不要求当前目录已配置知识库 |

退出 `0` 表示未发现机器可检错误；`1` 表示参数、配置或校验失败。目录缺失或没有文件仅警告，不能据此宣称方案完成。

扫描跟随可解析软链，同一文件去重；每条别名仍须与 ID 同名，断链或目录环报错。

`id` / `parent` 沿用模板的未加引号键名，值为顶层单行标量；支持普通值、单双引号、行尾注释及空 `parent`，不使用转义、YAML 标签、锚点、别名或多行值。脚本不校验其余元数据的完整 YAML 语义；其他解析边界见 `--help`。

脚本检查六段标题及顺序、身份与版本链、正文禁区；允许草稿段留空。交付前还须人工核实：元数据与占位符已填、六段有实质内容、ID 与关系存在、公司技术基准及例外有依据、用户确认已收口。校验脚本只读文件，不授予写入或推进权限。
