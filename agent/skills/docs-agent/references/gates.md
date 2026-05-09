# docs-agent 门禁与范围对齐

主干：[SKILL.md](../SKILL.md)。步骤 1–5：[workflow.md](workflow.md)。

## 步骤 0（HARD-GATE：参数确认书）

落盘或覆盖根 `README.md` / `AGENTS.md` **之前**：快速路径 **或** 澄清路径；未对齐不写。

### 快速路径

- `--output`、`--mode` 已给出或可唯一推断（如「只更新 AGENTS」→ `agents` + `update`）。
- 任务限于本仓库入口双文件，无「顺便重写他处」歧义。

### 澄清路径

满足任一：**未说明**输出范围；**未说明** create/update；指令过宽且未限定根入口。  
**一问一点**；可先给默认（如 `both` + `update`）请确认。对齐后进步骤 1。

### 确认书（会话内，不落盘）

```
即将执行 /docs-agent，参数如下：
- output: <readme|agents|both>
- mode: <create|update>
- 将写入: <文件路径列表>

C 确认执行 / M 修改参数 / S 跳过
```

收到 **C** 或 **S** 后方可写入。**禁止未确认覆盖**根 `README.md` / `AGENTS.md`。

### 与 Index 门禁的关系

步骤 0 管「写什么、如何合并」。Index 须落盘等规则见 [execution-spec.md](execution-spec.md)，独立生效。
