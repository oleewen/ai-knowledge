# sdx-prd 维护者评测

评测分两层：脚本回归检查校验器；独立代理在临时工作区执行自然语言用例，检查技能行为。两者都不代表产品验收。用例与断言唯一来源是 [evals.json](../evals/evals.json)，最小输入在 [fixtures.json](../evals/fixtures.json)。

## 脚本回归

从仓库根执行：

```bash
bash agent/skills/sdx-prd/tests/run.sh
```

此命令运行确定性的校验器测试，不会执行自然语言用例。校验器入口为 `bash agent/skills/sdx-prd/scripts/validate-prd.sh --file <PRD路径>`，依赖 Python 3.8+；参数以 `--help` 为准。

| 退出码 | 解读 |
| --- | --- |
| `0` | 无结构错误；仍须报告 warning。若未找到扫描目标，则是未校验，不能称文档通过 |
| `1` | 文档结构或身份/路径校验失败 |
| `2` | 用法或执行环境错误，未取得有效校验结论 |

## 隔离复跑行为用例

1. 选取一个 `eval_id`。先跑变更涉及的用例；全量声明需跑完全部用例。保留原 ID；`prd-not-trigger-004` 已改为检验用户明确重开，类别以字段为准，不能从 ID 前缀猜测。
2. 从仓库根运行下列命令，为该用例展开 `fixture`。只写系统临时目录；不得把被测 PRD、快照或评分落入工作树。

```bash
case_id='prd-trigger-003'
run_root="$(mktemp -d "${TMPDIR:-/tmp}/sdx-prd-eval.XXXXXX")"
python3 - "$case_id" "$run_root" <<'PY'
import json
import shutil
import sys
from pathlib import Path

skill = Path('agent/skills/sdx-prd').resolve()
case_id, run_root = sys.argv[1], Path(sys.argv[2])
catalog = json.loads((skill / 'evals/evals.json').read_text())
case = next(item for item in catalog['evals'] if item['id'] == case_id)
fixtures = json.loads((skill / 'evals/fixtures.json').read_text())['fixtures']

def expand(name):
    fixture = fixtures[name]
    files = expand(fixture['extends']) if 'extends' in fixture else {}
    files.update(fixture['files'])
    return files

workspace = run_root / 'workspace'
for relative, content in expand(case['fixture']).items():
    path = workspace / relative
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding='utf-8')
shutil.copytree(workspace, run_root / 'before')
(run_root / 'prompt.txt').write_text(case['prompt'], encoding='utf-8')
shutil.copyfile(skill / 'evals/eval-metadata-template.json', run_root / 'metadata.json')
print(run_root)
PY
```

3. 给独立代理技能的绝对路径、`prompt.txt` 内容和临时 `workspace` 路径。允许它读取技能及必要共享引用；文件操作仅限该临时工作区。不要给断言、预期结果、旧评分或修复结论；不能让其读取其他用例。独立代理执行到请求完成或确实需用户决定处即停；不代用户补答、不暗示应如何过关。
4. 在工作区外保存完整对话与工具日志，包含实际读取/写入位置、校验命令、退出码、标准输出与错误。记录模型、时间、技能与 fixture 的版本标识；有未提交改动时保存相关输入快照或内容哈希，单记 Git HEAD 不足以复现。
5. 保存整个工作区的运行后快照并比较，不只截取目标段：

```bash
cp -R "$run_root/workspace" "$run_root/after"
diff -ru "$run_root/before" "$run_root/after" > "$run_root/diff.txt"
```

`diff` 退出 `1` 表示存在差异，不代表测试失败；退出大于 `1` 是比较错误。只读用例必须用完整快照证明未写入。若环境在工作区内产生辅助文件，也须记录，不能隐藏后再宣称无修改。

6. 另交裁判读取对应断言与证据，按 [grader.md](../agents/grader.md) 逐条判定。填写 [metadata 模板](../evals/eval-metadata-template.json) 的真实观测和证据路径；只通过 `eval_id` 引用断言，不复制期望正文。无日志、未运行、跳过分别保留状态与原因。

## 覆盖与报告

当前用例覆盖：FEATURE/MVP 边界、写前停问、自然语言授权、单段推进、局部改写、明确批量、F 保留前文、明确重开、其他阶段分流、受众修复、只读评审、公司到系统的路径缺失、语义冲突、校验失败。

报告分别列出静态检查、脚本回归和行为用例的已运行/未运行数量，并列 P0 失败、P1 发现与证据缺口。未运行项不能算通过；P1 不设置任意计分门槛。失败分析与回归选择见 [analyzer.md](../agents/analyzer.md)。
