# docs-archive 评测运行

使用 Python 3 标准库 runner [run_evals.py](../scripts/run_evals.py) 校验用例、执行适配器或重算评分。[evals.json](../evals/evals.json) 是提示词、期望与断言的唯一事实源；[grader.md](../agents/grader.md) 定义逐条判断方式。

## 命令

在技能目录运行：

```bash
python3 scripts/run_evals.py validate
python3 scripts/run_evals.py run \
  --executor '["python3","/abs/executor.py"]' \
  --grader '["python3","/abs/grader.py"]' \
  --timeout 60 > results.json
python3 scripts/run_evals.py score --results results.json
```

`run` 可使用下节内置 Codex 适配器，或将示例路径替换为自己的适配器。默认 suite 为技能内 `evals/evals.json`；自定义时把 `--suite PATH` 放在子命令前，例如 `python3 scripts/run_evals.py --suite /abs/evals.json validate`。

| 模式 | 用途 |
| --- | --- |
| `validate` | 只校验 suite 结构；输出 `status: "validated"` 与 `suite_sha256`，不输出行为通过结论 |
| `run` | 每个用例依次调用执行器、评分器，校验响应并汇总 |
| `score --results PATH` | 校验已有结果与 suite 的对应关系，重新计算通过状态，不调用适配器 |

stdout 仅输出 UTF-8 JSON，进度写 stderr。`--timeout` 默认每次适配器调用 60 秒，允许范围为大于 0、至多 3600 秒；超时停止该次调用并记录错误。适配器参数是 JSON 字符串数组，不经 shell 求值。runner 仅运行显式指定的可信命令，不构成 sandbox；自身不发起网络或模型调用，也不硬编码模型配置。

## 内置 Codex 适配器

[codex_adapter.py](../scripts/codex_adapter.py) 调用已登录的 Codex CLI。先用 `codex login status` 核对登录状态，将 `MODEL_ID` 替换为账号可用模型，再在技能目录运行：

```bash
python3 scripts/run_evals.py run \
  --executor '["python3","scripts/codex_adapter.py","executor","--model","MODEL_ID","--effort","low","--artifacts-dir","eval-artifacts"]' \
  --grader '["python3","scripts/codex_adapter.py","grader","--model","MODEL_ID","--effort","low","--artifacts-dir","eval-artifacts"]' \
  --timeout 240 > results.json
python3 scripts/run_evals.py score --results results.json
```

`--model`、`--artifacts-dir` 必填；`--effort` 可选 `low` / `medium` / `high`，省略时采用 CLI 默认值；`--codex-bin` 可指定可执行文件，含目录的相对路径按启动目录解析，纯命令名按 PATH 查找。执行器和评分器可配置不同模型，每次调用均使用新会话。

`--ignore-user-config` 不加载已有自定义 provider。若当前环境依赖 Responses 代理，在两类适配器的 argv 中均追加 `"--base-url","https://你的代理端点"`：只传端点地址，继续使用现有 Codex 登录，不加载其余用户 `config.toml` 配置。URL 须为 HTTP(S)，不得含凭据、query 或 fragment。

适配器向执行模型显式提交白名单运行资料和用户请求，移除 SKILL 中的评测链接，不注入期望、断言、evals 内容或原始用例 ID；模型返回 `response`，适配器再补 `eval_id`。评分器另开会话，显式提交当前用例、回答和 grader 规则。两者使用相同模型时属于分开调用，不构成跨模型验证。

CLI 在临时目录中运行，关闭工具相关功能，并拒收含工具事件的结果；选项只作用于本次进程，不修改全局配置。CLI 基础规则、全局 AGENTS 和已装技能描述仍可能参与，不能保证得到空白上下文；评测结论限定于记录的本机 CLI 环境。

本地核对的 CLI 版本为 `0.163.0-alpha.10.2`；其他版本须支持 `--ignore-user-config`、`--output-schema` 和 `features.skip_host_skill_discovery` 等选项。配置含义见 [官方配置参考](https://learn.chatgpt.com/docs/config-file/config-reference)。

在 macOS/Linux 上，runner 将实际进程组标识传给适配器；普通 shell 包装器可继承该组。受管时版本探测和模型调用统一受 runner 的 `--timeout` 限制，调用退出、超时或中断后回收组内子进程。主动脱离该组的程序不在此清理保证内。

独立调用时，适配器自行管理 CLI 进程组；`--timeout` 默认 180 秒，范围为大于 0、至多 3500 秒。模型调用采用该时限，版本探测采用其与 10 秒的较小值。

每次调用在 `--artifacts-dir` 下创建独立目录，保留首次结果和后续尝试：

| 产物 | 用途 |
| --- | --- |
| `manifest.json` | 用例、角色、模型、CLI 版本、调用参数、时间及显式资料/提示词/适配器 SHA-256 |
| `prompt.txt`、`schema.json` | 适配器显式提交的提示词与输出结构，不含 CLI 自动附加的全部上下文 |
| `events.jsonl`、`stderr.log` | 原始事件与诊断日志，失败时用于排查 |
| `version.txt`、`version-stderr.log` | CLI 版本探测的输出与诊断日志 |
| `model-output.json`、`response.json` | 模型最终输出与通过协议校验的适配器输出；未取得有效结果时可能缺失 |

外层强制停止时，manifest 可能停留在 `running`；以 runner 的错误结果判定该次调用。`score` 只重算已有判断，不重新调用模型；复现时同时保留 `results.json` 和调用产物。

## 适配器协议

每次调用从 stdin 读取一个 JSON 对象，向 stdout 输出一个 JSON 对象；日志写 stderr。两类适配器都须原样返回本次 `eval_id`。

| 适配器 | stdin | stdout |
| --- | --- | --- |
| 执行器 | `eval_id`、`prompt`、`skill_path` | `eval_id`、`response` |
| 评分器 | `case`、`response`、`grader_path` | `eval_id`、`judgments` |

- `skill_path` 为绝对 `SKILL.md` 路径。执行器读取技能并回答 `prompt`；输入不包含期望或断言。`response` 必须为非空字符串。
- `case` 为 suite 中的完整用例，包含期望和断言；`grader_path` 为绝对 `agents/grader.md` 路径。
- `judgments` 必须逐条覆盖当前用例所有断言，含 P1/P2。每条含 `id`、严格布尔值 `passed`、非空字符串 `evidence`。证据来自本次回答，不能只填断言 ID。
- 不允许漏项、重复项或未知 ID。同一断言 ID 出现在不同用例中合法；在单个用例内必须唯一。

## 结果与评分

`score` 接受一个 JSON 对象，含 `suite_sha256` 和 `results` 数组。数组必须覆盖 suite 的全部用例，每个用例恰好一次；每项采用以下一种结构：

| 结果 | 字段 |
| --- | --- |
| 成功取得回答及判断 | `eval_id`、非空 `response`、完整 `judgments` |
| 执行或评分错误 | `eval_id`、非空字符串 `error` |

`run` 输出同样的 `suite_sha256` 与 `results`，可直接作为 `score` 输入；另含 `mode`、`skill_name`、`suite_version`、`summary`、`cases`。这些汇总字段不替代原始回答和逐条判断。元数据模板 [eval-metadata-template.json](../evals/eval-metadata-template.json) 只引用用例，不是结果文件。

`suite_sha256` 绑定完整 suite 内容，计算方式为：

```python
hashlib.sha256(
    json.dumps(suite, sort_keys=True, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
).hexdigest()
```

先运行 `validate` 获取哈希。JSON 缩进或键顺序不影响哈希；修改用例内容后，旧结果不能直接用于新 suite。

runner 自行汇总通过状态，不采用评分器的整体 `passed`：

| 用例类别 | 通过规则 |
| --- | --- |
| `should-trigger` | P0 全过；存在 P1 时，至少一条 P1 通过 |
| `should-not-trigger` | P0 全过；P1 只报告，不阻断 |
| 全部类别 | P2 只报告，不阻断；P1/P2 仍必须提供逐条判断 |

| 退出码 | 含义 |
| --- | --- |
| `0` | `validate` 结构有效；或 `run`/`score` 全部用例通过 |
| `1` | 结果结构有效，但存在未通过的用例 |
| `2` | 输入或执行错误，如哈希不匹配、缺用例、漏断言、重复/未知 ID、空证据、非法 JSON 或超时 |

## 验证边界

当前用例评价加载技能后的回答语义：参数澄清、确认书门禁、分流、写入顺序和失败停顿。用例数量与阶段以 suite 为准；`should-trigger` / `should-not-trigger` 是用例类别，不能据此报告真实技能发现率或自动触发率。

阶段由用例的 `phase` 和 `prompt` 确定。参数不足时允许先澄清，不能据此免除写前确认或禁止越权的要求；完整六项确认、写后受众检查和收敛停顿各有阶段用例，不要求每条首轮回答复述全部流程。

用例未提供业务文件正文。回答描述动作，不等于动作已发生；真实归档、回写和失败恢复须在隔离工作区另验产物与执行轨迹。受控适配器测试只验证协议、汇总和错误处理，不能替代模型语义评测或文件归档验收。

独立文件场景见 [behavior-cases.json](../evals/behavior-cases.json)，不交给禁用工具的回答 runner。准备最小业务夹具、保存写前内容，将实际请求与运行技能交给独立执行者；评分者另核对实际 diff、文件权限及工具证据。每场景记录 `pass / fail / not_run`，未执行的恢复或并发场景不能由正常路径推定通过。原 suite、哈希绑定和校准数据保持独立。

在技能目录运行回归测试：`python3 -B -m unittest discover -s tests -v`。

## 评分器校准

[grader-calibration.json](../evals/grader-calibration.json) 保存预设的正负样本，与 suite 哈希绑定；它不是模型运行结果。覆盖正确/错误分流及合法澄清/越权完成，错误样本故意保留正确技能名和任务关键词，检查评分器是否判断实际行为。

对每条样本按 `case_id` 从 suite 取完整用例，用正常 grader 协议提交 `{case, response, grader_path}`。**不得发送 `expected_passed` 或 `rationale`**。取得完整 judgments 后，按断言 ID 与 `expected_passed` 比较并保存差异、原始评分和调用产物；全部匹配才算校准通过。自动化测试只校验样本结构和协议，真实校准必须调用评分模型。

修改判据后另存 suite 快照与新报告，保留旧轮结果；不同版本的通过率不作直接提升比较。
