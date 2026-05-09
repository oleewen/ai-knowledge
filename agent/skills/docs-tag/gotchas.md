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

## 7 TTY：`--phase 1`

`input()` 在 CI 挂起。**Skill 只用** `1-scan`+`1-write`。`--phase 1`/`all` 留本地 CLI。
