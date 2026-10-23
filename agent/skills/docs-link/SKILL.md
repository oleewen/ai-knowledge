---
name: docs-link
description: >
  登记或注销上下级知识库，更新双边 knowledge-links.yaml 与联邦槽位软链；
  检查已登记 child 槽位或单槽位修复。用于 /docs-link、知识库建联、换父、注销、
  槽位检查或修复。内容更新走各仓普通 Git 工作流；应用设计只读中央 ASD/spec-asd，见 sdx-design。
---

# docs-link

在源 Git 根处理相邻层：`company → solution`、`solution → system` 或 `system → application`。入口为 [docs-link.sh](scripts/docs-link.sh)，使用同目录脚本模块与 Agent 的 `docs-core.sh`；需要 Bash 5+、Git、Python 3。

## 选择动作

| 动作 | 范围与结果 |
| --- | --- |
| `--link --target` | 单目标建联或换父，更新双边清单与槽位；可用 `--app-name`，正文改写须另获授权 |
| `--unlink --target` | 单目标注销登记与槽位；保留无关条目和正文 |
| `--check [--target]` | 只读检查已登记 child；无目标检查全部，有目标检查单项，汇总全部结果 |
| `--repair --target` | 只修复一个已登记槽位的软链；可用 `--dry-run` 预览 |

四动作互斥；`--app-name`、`--rewrite-http` 仅限 link。脚本不 clone/pull、不安装知识库、不提交 Git。

## 执行

1. 读取源 `.docsconfig` 和登记清单，确认动作与范围。当前工作区不是合法源 Git 根时停止，要求切换工作区；不代 `cd`。用户已提供的信息直接采用。
2. 按 [workflow.md](references/workflow.md) 解析目标。check 直接只读执行；其余动作先 `--dry-run`，展示本次实际影响。
3. 按 [gates.md](references/gates.md) 核对授权，再用同一组参数真写。`--rewrite-http` 默认关，仅用户明确要求改正文并单独确认后使用。
4. 读回验证并汇总结果；区分检查、预览、已修复、双边完成、仅源侧完成和失败。推进动作见 [轻流程 C/M/S/F](../../references/light-flow-actions.md)。

```bash
# 替换脚本路径；cwd 保持在源 Git 根。
bash <技能目录>/scripts/docs-link.sh --link --target <目标仓库根> --app-name <名称> --dry-run
bash <技能目录>/scripts/docs-link.sh --unlink --target <路径或已登记URL> --dry-run
bash <技能目录>/scripts/docs-link.sh --check
bash <技能目录>/scripts/docs-link.sh --check --target <已登记路径或URL>
bash <技能目录>/scripts/docs-link.sh --repair --target <已登记路径或URL> --dry-run
```

## 必守边界

- 写入单元是一对源仓 × target；全量 check 不授权批量修复。
- `path` 只存 `${WORK_SPACE}/…`，分别按所属库配置展开。旧格式、缺配置或越界停止，不能用环境变量绕过；[路径契约](../../knowledge/knowledge-governance.md)是 SSOT。
- check/repair 依已有登记 `path` 精确定位；缺仓、配置/身份或反向 parent 不符均阻塞。不改清单、正文或 Git 元数据，不访问远端；dirty/detached 不阻塞槽位维护。
- 普通文件/目录占用槽位必须保留。repair 只建缺失软链或替换失效/错误软链，正确相对软链保持原样；不能用修复代替登记更名或换父。
- 内容更新遵循各仓普通 Git 工作流。失联注销、换父及中途失败见工作流。

## 按需查阅

| 情况 | 参考 |
| --- | --- |
| 参数、执行与异常收口 | [workflow.md](references/workflow.md) |
| 预览确认、批次与 HTTP 授权 | [gates.md](references/gates.md) |
| 环境或旧数据异常 | [gotchas.md](gotchas.md) |
| 修改或验收技能 | [评测方法](references/evaluation.md)、[行为场景](evals/evals.json)、[评分规则](agents/grader.md) |
