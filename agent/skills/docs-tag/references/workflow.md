# docs-tag 工作流

单文件分阶段执行；授权与异常停顿见 [gates.md](gates.md)。以下命令从仓库根运行，路径参数用引号包裹。

## 参数

| 参数 | 适用阶段 | 规则 |
| --- | --- | --- |
| `--file` | 全部 | 已存在的 overview Markdown 文件 |
| `--phase` | 全部 | Agent 用 `1-scan` / `1-write` / `2` / `3` / `excerpt` |
| `--keywords` | `1-scan`、`1-write`、本地 `1`/`all` | 空格分隔的种子词 |
| `--scan-dir` | 扫描阶段 | 显式值优先；默认从 `knowledge/overview/` 推断父级 `knowledge/`，适用于四层模板和安装后的任意 DOC_DIR；无法推断则要求显式路径 |
| `--top-n` | 扫描阶段 | 正整数，默认 30 |
| `--selected` | `1-write` | 逗号分隔的非空选中词；不支持词内含逗号 |

只收口当前阶段需要的参数，复述实际路径和默认值；用户已指定的值直接沿用。`2`、`3` 不依赖 scan-dir 或新传 keywords。

## 1 扫描与选择

```bash
python3 agent/skills/docs-tag/scripts/keyword_tag.py \
  --file "FILE" --phase 1-scan --keywords "计费" "结算" \
  --scan-dir "SCAN_DIR" --top-n 30
```

stdout 是单个 JSON 对象：`{"candidates":[{"term":"Invoice","count":3}]}`。扫描只读，不写缓存；读取失败非零退出，不把失败当成零候选。

展示编号、词和频次，轻量校核候选范围后等待选择。编号或 `all` 表示选词，`q` 表示取消；空候选先报告，不自行写入。调参依据见 [algorithm.md](algorithm.md)。

## 2 写入选词

```bash
python3 agent/skills/docs-tag/scripts/keyword_tag.py \
  --file "FILE" --phase 1-write --keywords "计费" "结算" \
  --selected "费用类型,Invoice"
```

本次种子与选中词稳定去重，种子优先；**替换**旧词，不累计旧列表。结果是 `## 附录` 下 `### 文档关键词` 的 YAML 列表；字符串加引号，其他附录正文保留。旧 `<!-- spec-tags … -->` 仅兼容读取，写入时迁移。

核对词列表与用户选择、重复块及无关正文是否保留。

## 3 标记表行

```bash
python3 agent/skills/docs-tag/scripts/keyword_tag.py --file "FILE" --phase 2
```

必须有非空的新式或旧式关键词附录。只处理以「主标题 / 副标题」开头的表，按副标题首个本地链接章节匹配；大小写不敏感，忽略 HTML 注释。仅刷新副标题列 ✅，保留其他列和架构摘录表。

报告命中与未命中行数，抽查明显过宽/过窄的结果；无附录时提示先扫描选词，不自动代选或续跑。

## 4 刷新架构摘录

```bash
python3 agent/skills/docs-tag/scripts/keyword_tag.py --file "FILE" --phase 3
```

`excerpt` 等价。前置：已有 `## 架构摘录` 及表头/分隔行，来源的视角 H2 必须是 Markdown 链接标题，例如「业务架构」。

固定顺序为业务、产品、应用、技术、数据。仅副标题列带 ✅ 的数据行入选；摘录不含第三列知识正文。脚本只替换摘录表数据，保留表前后说明；缺视角时警告，缺摘录表时失败。空集写 `<!-- excerpt:empty -->`，执行前核实空集是否符合意图。

报告各视角计数，核对摘录与 ✅ 一致。摘录数据行由脚本维护，不手工补行。

## 5 当前单元收口

每阶段校核统计、范围与异常；结果摘要通过 [受众 A/B](../../../references/audience-and-language.md#轻流程-ab含-okf)，只报告关键词命中与产物变化，不扩写无依据业务正文。

`all` 是本文件完整流程的授权：Agent 依次调用各非交互阶段，选词和异常处等待。未授权的阶段及下一文件按 [轻流程动作](../../../references/light-flow-actions.md) 等待用户选择。

本地兼容命令 `--phase 1` / `--phase all` 含终端输入；取消、EOF 或零候选停止后续阶段。Agent 不调用这两个交互入口。
