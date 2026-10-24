# 第四章导航归并

实体与视角 README 预检通过后，只更新 `{DOC_DIR}/INDEX-GUIDE.md` 的 `docs-build:entity-index` 块。该块为静态导航，不扫描 concept、不承载实体台账。

## 运行

`SKILL_DIR` 为已核实的技能绝对目录；在目标仓运行。`--bundle` 是文档目录，`--layer-scope` 是知识层，两者不可混用。

```bash
# 消费仓：.docsconfig 已解析 DOC_DIR=docs、KNOWLEDGE_TYPE=application
python3 "$SKILL_DIR/scripts/generate_knowledge_index.py" --bundle docs --layer-scope application --dry-run
python3 "$SKILL_DIR/scripts/generate_knowledge_index.py" --bundle docs --layer-scope application

# 元库：目标目录名本身即知识层，兼容原命令
python3 "$SKILL_DIR/scripts/generate_knowledge_index.py" --bundle application --dry-run
```

| 参数 | 行为 |
| --- | --- |
| `--bundle` | 必填，目标仓内已有相对目录；拒绝越界与不存在目录 |
| `--repo` | 可选目标仓绝对根；默认从当前目录上溯 `.docsconfig` / `.git` |
| `--layer-scope` | company / solution / system / application；bundle 为标准层名时可省略，其他名字必须指定 |
| `--dry-run` | 校验目标与标记后，仅向 stdout 输出导航块 |

Python 生成器不解析 `.docsconfig`；调用前从目标仓配置取得参数。Bash 校验入口自动读取该配置。两者均须指向同一目标仓，运行环境需要 Python 3；Bash 入口需要 Bash 5+。校验器复用相邻 docs-okf 的 `okf_lib.py` 与 Agent 树的 `docsconfig.sh`，不要单独复制技能脚本运行。

导航定位复用相邻 docs-indexing 的正文区域解析器，排除 frontmatter、围栏与缩进代码；运行时须保留 Agent 树中的这两个技能。生成器和校验器共用导航定位，示例标记不满足真实导航要求。

## 更新边界

1. 唯一完整的新标记块：仅替换块内内容。
2. 唯一完整的旧标记块 `<!-- docs-build:entity-index -->` / `<!-- /docs-build:entity-index -->`：迁为新标记。
3. 无标记：仅替换唯一 `### 4.5` 正文，保留下一同级/上级标题及内容；标题空白支持空格与 Tab，替换终点不得越出第四章。
4. 残缺、重复、倒置、混用或跨章标记，以及未闭合 frontmatter/代码围栏：报错且不写；4.5 与标记均须位于唯一第四章。缺主 INDEX 时先 docs-indexing。

保留原文件换行方式与块外内容。生成器不删除 `knowledge/KNOWLEDGE-INDEX.md` 或 `knowledge/INDEX-GUIDE.md`。旧文件迁移另行确认。

## 内容与终检

导航模板见 [knowledge-index-template.md](../assets/knowledge-index-template.md)：职责短注、层范围与 knowledge 总入口/目录索引/五视角 README。脚本使用该模板渲染。

运行完整模式 `validate-extraction.sh`，并人工确认未改标记外内容、导航与当前层一致。实体结构见 [okf-spec.md](../../../knowledge/okf-spec.md)，实体台账见 [readme-fill-spec.md](readme-fill-spec.md)。
