# agent-install 陷阱

| 现象 | 处理 |
| --- | --- |
| Bash 版本错误或测试显示 SKIP | 使用 Bash 5+ 可执行文件；SKIP 不算通过 |
| 安装副本找不到元库 | 用 `--meta` 指向含 `agent/` 的源码仓库；见 [调用布局](references/parameters.md#安装副本调用) |
| 无法推断 workspace | 提供 `--workspace`；不要把 target 当 workspace，或为此创建 `.docsconfig` |
| 推断工作区与全局值冲突 | 展示旧值和候选值；用户选择后显式传 `--workspace`，不能自行补参绕过 |
| 预览出现第三方技能链接 | 所选分类会暴露共享树内已有资源；内容不覆盖，链接变化须纳入计划 |
| 未给 agents 却出现多个 IDE | 核对 `AGENTS_OPT` 与默认值；含义见 [参数表](references/parameters.md) |
| 目标缺少 README | 安装器排除各层 `README`、`README.md`、`readme.md`，这些文件是仓库导航 |
| 安装后找不到测试或评测资源 | 研发资源不安装；回到元库执行维护命令，范围见[安装过滤](references/parameters.md#安装过滤) |
| 重跑覆盖了本地定制 | 同名资源属于同步范围；冲突备份仅保护 IDE 项，见 [覆盖边界](references/gates.md#覆盖边界) |
