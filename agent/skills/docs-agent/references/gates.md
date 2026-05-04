# docs-agent 门禁与范围对齐

[SKILL.md](../SKILL.md) 为主干；步骤 1～5 节奏见 [workflow.md](workflow.md)。

---

## 步骤 0：范围对齐（HARD-GATE：参数确认书）

在**任何**落盘或覆盖根目录 `README.md`、`AGENTS.md` 之前，先判断走快速路径还是澄清路径（与 brainstorming 类流程对齐：**未对齐范围前不执行「生成」**）。

### 快速路径（默认）

同时满足时可跳过逐轮提问，直接进入 [workflow.md](workflow.md) 步骤 1：

- 用户给出或自然语言可**唯一推断** `--output` 与 `--mode`（含明确同义表述，如「只更新 AGENTS」→ `agents` + `update`）。
- 任务范围明确指向本仓库入口文档，无「顺便重写其他目录文档」等歧义。

### 澄清路径（条件触发）

出现以下任一情况时进入澄清路径，**HARD-GATE**：未完成本节对齐前**不得**写入或覆盖 README/AGENTS：

- 未说明输出范围（只 README、只 AGENTS 或两者）。
- 未说明 `create` 与 `update`（首次初始化 vs 在已有文件上增量合并）。
- 指令过宽（如「整理一下项目文档」）且未限定为根目录 README/AGENTS。

**分步提问**：每次只问一个点；可先给出推荐（例如 `both` + `update`）请用户二选一或确认。对齐后再进入步骤 1。

### 参数确认书格式（会话内，无需落盘 spec 文件）

```
即将执行 /docs-agent，参数如下：
- output: <readme|agents|both>
- mode: <create|update>
- 将写入: <文件路径列表>

C 确认执行 / M 修改参数 / S 跳过
```

收到 **C** 或 **S** 后方可写入。**禁止**在未收到确认前写入或覆盖根目录 `README.md` / `AGENTS.md`。

### 与 Index 技术门禁的关系

[execution-spec.md](execution-spec.md) 中 Index 落盘检测（无 INDEX 则终止）仍然独立成立；步骤 0 解决的是**写哪些文件、以何种合并策略**，不替代 Index 解析。
