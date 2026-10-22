# sdx-analysis 评测

评测分三层；结构检查通过不代表行为正确，读到技能也不代表执行正确。

| 层 | 输入 | 证据 |
| --- | --- | --- |
| 发现 | [trigger-eval.json](../evals/trigger-eval.json) | 实际加载本技能的工具记录；不能只看回复是否提到技能名 |
| 路由 / 协议 | [evals.json](../evals/evals.json) 的 routing / protocol | 当前阶段、真实授权、停顿及操作范围 |
| 产物 | 同文件的 artifact | 前后 diff、生成文件、链接目标、校验输出 |

非法 F 在发现层为 should_trigger=true，执行层为 category=protocol。历史 ID solution-not-trigger-007 保留用于追溯，不代表不应加载。

## 隔离执行

1. 新建独立临时目录作为 `EVAL_ROOT`，使用其规范化绝对路径。目录结构如下；所有配置、产物都留在临时根内，不读取或改写用户全局配置。

   ```text
   <EVAL_ROOT>/
   ├── project/                 # 执行 cwd；REPO_DIR=project
   │   ├── .docsconfig          # 来自 fixture_files
   │   └── docs/               # DOC_DIR=docs，预先创建
   └── agent-root/agent/configs # 内容：WORK_SPACE=<EVAL_ROOT>
   ```

   先物化顶层 fixture_files，再应用案例同名文件覆盖；fixture 路径均相对 `project/`。将内容中的字面占位 `{{EVAL_ROOT}}` 替换为临时根绝对路径，不用 shell `eval` 或环境变量展开。创建 `agent-root/agent/configs`，写入 `WORK_SPACE=` 与同一临时根绝对路径。案例改变 KNOWLEDGE_TYPE 时须保留 AGENT_ROOT、AGENT_DIR、REPO_DIR、DOC_DIR；两条错误层级夹具已包含全部键。
2. 给执行代理当前技能及必要共享引用、夹具、conversation 历史，最后发送 prompt。不要提供 expected_output、断言、疑似问题或修复结论。
3. conversation 是该例已发生的会话；末尾 prompt 是本轮输入。代理停在合理澄清点即结束本轮，不自动回答新问题或补造授权。
4. 留存响应、工具记录、前后文件与 diff，再交 [grader.md](../agents/grader.md)。产物案例不能只做口头演练。从临时 `project/` 使用 Bash 5+ 调用真实技能位置的 `validate-analysis.sh --file <临时产物绝对路径>`；无需复制或安装 Agent 树。预期先通过配置加载，再得到产物检查结果；错误层级案例应在层级检查拒绝，不能误记为配置缺失。

只有本轮实际修改、检查的范围可宣称完成。夹具刻意包含未完成章节；局部续写不要求补全文，全文终检发现不足也不能未经确认回改。

## 记录与复跑

最近一次实测见 [审查与验证记录](../evals/evaluation-report.md) 和 [逐断言证据](../evals/behavior-results.json)。用例定义中的 not_run 是初始状态，实际执行结果单独记录。

结果沿用 [eval-metadata-template.json](../evals/eval-metadata-template.json)，记录技能版本/提交或内容摘要、运行时间、使用模型及证据位置。无记录用 null；未运行用 not_run，缺证据用 incomplete。

修改发现描述时跑相关发现案例；修改流程时跑对应协议案例；涉及路径、续写、F、指标或 ADR 时跑相关产物案例。JSON 解析、配置加载与结构校验均不计为代理行为通过；只做这些自检时，案例定义仍保持 not_run。

历史成绩及适用范围见 [TRIGGER-EVAL.md](../evals/TRIGGER-EVAL.md)。不要把历史结果标成当前版本通过，也不要将历史临时运行器当作现成依赖。
