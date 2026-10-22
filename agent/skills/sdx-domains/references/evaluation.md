# sdx-domains 评测

仅维护技能或执行评测时读取。业务执行不加载评测答案。

## 两类评测

| 套件 | 检查对象 | 证据 |
| --- | --- | --- |
| [trigger-eval.json](../evals/trigger-eval.json) | 是否正确选择、加载技能 | 完整工具轨迹中的技能加载记录 |
| [evals.json](../evals/evals.json) | 已加载后的实际行为、文件与边界 | 原始输入、工具轨迹、前后文件快照与差异 |

显式 `/sdx-domains` 在非公司库中被加载后停止写入，是正确边界行为。不能将它标成「不应触发」。`F` 用错时仍需处理用户的公司域架构意图；明确要求重写时应重开相应段。

## 准备与运行

1. 每例新建绝对路径临时容器，记作 `{{FIXTURE_ROOT}}`；在其下建立 `repo/` 作为执行工作区。`copy.source` 相对源仓库根，`copy.target`、`replace.path` 与普通 `write_files` 键相对 `repo/`。目录按普通文件复制，不能用可写软链指回真实库。
2. 先应用 `base_fixture`，再应用本例 `setup`：顺序均为 `copy`、`write_files`、`replace`。仅在 `write_files` 的键和值中，将唯一占位符 `{{FIXTURE_ROOT}}` 替换为容器绝对路径；替换后的绝对键用于容器内 `agent-home/.agents/configs`。其余相对路径不得逃出 `repo/`，绝对键不得逃出容器。`replace.old` 必须恰好命中一次，否则记为夹具错误。保留 `${WORK_SPACE}` 字面量，不作 shell 展开。
3. 在 `repo/` 用 Bash 5+ 的独立子进程加载共享 `docsconfig.sh` 并调用 `docsconfig_bootstrap_validate`；应解析到 `WORK_SPACE=<容器>`、`REPO_DIR=repo`、`DOC_DIR=corp`。`REPO_DIR=.` 被共享库禁止。夹具校验通过后，记录整个容器的文件快照，含 Agent configs；源材料使用运行时仓库版本并记录修订号。
4. 给独立执行者技能路径、本例 `prompt` 与临时工作区，不给 `expected_output`、断言、旧评分或修复结论。共享契约按技能链接读取；禁止对真实业务目录写入。
5. 执行到本轮自然停顿点。缺少必要用户回答时记录请求并停止，不替用户补确认；已在 prompt 明确给出的确认不重复索取。需要后续轮次时保存真实输入。
6. 保存完整轨迹、文件快照和差异，再交 [grader](../agents/grader.md) 评分；失败交 [analyzer](../agents/analyzer.md) 分析。

配置预检可从 `repo/` 调用源仓库共享库；使用真实绝对路径，不复制或改写共享库：

```bash
bash -c 'set -e; source "$1"; docsconfig_bootstrap_validate; docsconfig_doc_abs' _ /绝对源仓库/agent/scripts/lib/docsconfig.sh
bash /绝对源仓库/agent/skills/sdx-domains/scripts/validate-domains.sh --file corp/domains/DOMAIN-BD-EXAMPLE.md
```

第二条在对应产物存在后执行，替换成该例实际文件名；全库校验须有总图。非公司库例预期被技能校验拒绝。预检和结构校验不能代替模型行为评测；未生成产物的停顿用例不应被判为结构失败。

行为用例共 12 条。每例同时检查 `common_assertions` 和自身 `assertions`；`category` 仅标行为阶段，不能用来计算触发率。预期内容是评分依据，不是要求执行者背诵的答复。

## 记录与可信度

- 使用 [运行记录模板](../evals/eval-metadata-template.json) 记录真实运行；无结果时保留 `not_run`，不制造通过率。
- 文件断言以实际差异为准；「我会保留前文」不能替代前文确实未变的证据。只读或应停顿用例也要留存零差异证据。
- 未提供工具轨迹或文件证据时，相关断言为 `not_evaluable`；不得按响应承诺判通过。
- 触发套件仅观测技能选择。描述文本提到技能不等于加载，首次模型停顿也不等于本轮结束。
- [历史触发结果](../evals/trigger-eval-results.json) 只保留原始证据。它采用旧七章方案语义，不能用于当前套件验收；说明见 [TRIGGER-EVAL.md](../evals/TRIGGER-EVAL.md)。
