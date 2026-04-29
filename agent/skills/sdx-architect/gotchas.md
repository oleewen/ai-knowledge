# sdx-architect 常见陷阱

**未完成总确认即写 ASD**：会话 spec 须有 `CONFIRMED` + 文件名 `ASD-*`，否则会触发 preToolUse。

**越过边界写详设**：接口签名、DDL、规约 YAML 属于 **DSD**，勿写入 ASD。

**联邦库强写 DSD**：`KNOWLEDGE_TYPE` 为 `system`/`company` 时，应在**应用库**再跑 **`/sdx-design`**。
