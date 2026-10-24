# docs-install 维护入口

修改 CLI 或安装行为时，同步 [参数选择](parameters.md)、[执行与验收](workflow.md)、[授权边界](gates.md)；故障指引见 [gotchas.md](../gotchas.md)。

修改脚本后，在元库根用 Bash 5+ 运行 `bash agent/skills/docs-install/tests/run.sh`。测试隔离目标与 HOME；[test-lib.sh](../tests/test-lib.sh) 也供 docs-link 使用，改接口须检查调用者。

技能判分见 [grader.md](../agents/grader.md) 与 [evals.json](../evals/evals.json)。静态校验不能代替实际预览、安装及失败场景验证。

## 独立行为评测

按变更风险选择用例。控制方在临时目录准备元库、工程和隔离 HOME，使用上述测试助手配置 Agent 树；给被测代理运行技能和当前用户请求，不提供测试、评分器、预期答案或未来消息。只允许通过绑定该临时目录的运行器调用安装器；访问约束不是操作系统沙箱。

保存安装器每次调用的参数、输出、退出码，以及项目操作前后的文件内容摘要和软链目标。多轮例须等首轮真实返回并保存快照后，才投递 `follow_up`。评分依据真实操作与响应；口头承诺不能代替零写入证明。

`docs-install-partial-failure` 的 `execution_variant` 在临时运行器中注入路径改写失败，验证已授权安装在部分写入后的处理；原日志诊断场景保留。报告记录技能版本、模型及代理 ID、实际输入、逐项状态和证据；未跑的用例标记 `not_run`，抽样不称全量通过。脚本改动同时运行 docs-upgrade 回归，因为两者共用路径改写库。
