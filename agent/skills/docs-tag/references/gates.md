# docs-tag 风险控制与确认点

[SKILL.md](../SKILL.md)；命令 [workflow.md](workflow.md)。

## 参数确认

参数向导至少收口以下内容：

1. `--file`
2. `--phase`
3. `--keywords`（phase 含 `1` 或 `all` 时）
4. `--scan-dir`
5. `--top-n`

示例提示：

```text
--scan-dir 默认 docs/architecture/（回车确认或改路径）
--top-n 默认 30（回车确认或改数字）
```

然后一次性复述全部参数，再跑脚本或展示候选。

## 风险确认

以下情况属于语义性问题，必须先给出结论、推荐方案与动作选项，再等待用户确认：

- 当前 overview 是否适合继续下一 phase
- 候选词是否需要缩窄或扩展
- `scan-dir`、`top-n` 是否需要调整
- `phase 2` 无附录、`phase 3` 无 ✅、或结果明显越义

推荐会话格式：

```text
即将执行 /docs-tag，当前参数如下：
- file: <overview 路径>
- phase: <1-scan|1-write|2|3|all>
- keywords: <...|不需要>
- scan-dir: <路径>
- top-n: <数字>
- 当前单元: <overview 文件>

C 确认当前单元 / M 修改参数 / S 跳过当前单元或后续 phase / G 继续深挖 / F 补齐剩余 overview 文件
```

## 默认授权边界

- 已收口参数下，可直接执行**非语义性修订**：排版、编号、幂等附录刷新、空摘录占位
- 涉及是否继续下一 phase、是否调整关键词范围、是否处理下一 overview，按语义性处理

## 约束

- `phase 3` / `excerpt` 不需要 `keywords`
- `phase 2` 缺 `<!-- spec-tags -->` 时，不得静默继续；应提示先 `1-scan` + `1-write`
- 当前 overview 未收敛前，不得自动推进下一 overview 文件
