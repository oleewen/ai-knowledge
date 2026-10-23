# docs-extract 核心概念

| 术语 | 含义 |
| --- | --- |
| sources | 提供事实的文件、目录或内联文本；不是待回写的对象 |
| overview | 当前唯一写入容器；四层路径与表行见 [knowledge-layout.md](../../../references/knowledge-layout.md) |
| 关键词附录 | 关键词附录中的 YAML 词表或章节映射表；筛选依据，不是来源正文 |
| 知识正文 | overview 行链接指向的章节/小节；判断是否已覆盖的依据 |
| 第三列 | 尚待归档的 delta；旧项存在不代表知识正文已覆盖 |
| A/U/D | 本轮新增、更新、删除说明；定义见 [federation-spec.md](../../docs-distill/references/federation-spec.md) |

来源归一化与提炼见 [extract-spec.md](extract-spec.md)。本技能不维护 distill 锚点或 `DISTILL-LOG`。
