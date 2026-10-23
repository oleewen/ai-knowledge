# docs-install 维护入口

修改 CLI 或安装行为时，同步 [参数选择](parameters.md)、[执行与验收](workflow.md)、[授权边界](gates.md)；故障指引见 [gotchas.md](../gotchas.md)。

修改脚本后，在元库根用 Bash 5+ 运行 `bash agent/skills/docs-install/tests/run.sh`。测试隔离目标与 HOME；[test-lib.sh](../tests/test-lib.sh) 也供 docs-link 使用，改接口须检查调用者。

技能判分见 [grader.md](../agents/grader.md) 与 [evals.json](../evals/evals.json)。静态校验不能代替实际预览、安装及失败场景验证。
