# docs-tag 门禁

[SKILL.md](../SKILL.md)；命令 [workflow.md](workflow.md)。

## 步骤 1：参数（已提供则跳过问）

1. `--file`（必填）  
2. `--phase`：`1`/`2`/`all`；自动化用 `1-scan`/`1-write`/`2`  
3. `--keywords`：phase 含 1 或 all 时必填  
4. `--scan-dir`：默认展示，可改（默认 `docs/architecture/`）  
5. `--top-n`：默认展示，可改（默认 `30`）

示例提示：

```
--scan-dir 默认 docs/architecture/（回车确认或改路径）
--top-n 默认 30（回车确认或改数字）
```

**然后一次性复述全部参数**，再跑脚本或展示候选。

## CONVENTIONS

**低风险**：会话内确认即可；无需中间 spec。**未完成本节前**勿对 `--file` 执行写入。
