# Gotchas

[gates.md](references/gates.md)、[workflow.md](references/workflow.md)。

## 1 锚点

GitHub 去标点≠直觉；手动链易空。脚本双规则尝试。**查**：`/tmp/keyword_tag_cache.json`。

## 2 YAML 附录

勿叠多个 `<!-- spec-tags -->`。`write_tags_to_file` 先删旧块再写，幂等。

## 3 扫描排除

须排除 `--file` 所在**直接子目录**，防目标污染共现。**注**：目标是 scan-dir **根下** md 时不排除子树。

## 4 `--selected`

逗号分列；脚本 `strip()` 各词。

## 5 无附录跑 phase 2

缺 `<!-- spec-tags -->` 会报错。 Skill `all` 须先阶段 1；单跑 2 失败则提示先 `1-scan`+`1-write`。

## 6 表格列

行首 `\|`→空 `parts[0]`，副标题多在 `parts[2]`。列不足 3 跳过。

## 6b phase 2 与 HTML 注释

相关性只查链接章节**去掉 `<!-- … -->` 后**的文本。注释里的关键词（如模板「应写内容」占位）**不会**打 ✅；正文与代码块仍参与匹配。

## 7 TTY：`--phase 1`

`input()` 在 CI 挂起。**Skill 只用** `1-scan`+`1-write`+`2`+`3`。`--phase 1`/`all` 留本地 CLI。

## 8 架构摘录节边界

五视角节止于下一 `##`、`---` 或 `## 附录`。缺某视角 H2 时 stderr 警告并跳过。

## 9 勿手改摘录表

`## 架构摘录` 下数据行由 `--phase 3` 生成；维护说明 blockquote 可手改。

## 10 `3` 与 `excerpt`

`--phase 3` 与 `--phase excerpt` 等价；`3` 不需 keywords 附录。
