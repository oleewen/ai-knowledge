---
name: docs-link
description: >
  登记或注销上下级知识库，更新双边 knowledge-links.yaml 与联邦槽位软链。
  用于 /docs-link、知识库建联、换父或注销登记。
  已登记槽位的回拉与修复用 docs-pull；规约设计由 sdx-design 只读引用中央来源，不提供跨仓下发。
---

# docs-link

在源 Git 根处理一个目标：`company → solution`、`solution → system` 或 `system → application`。入口脚本为 [docs-link.sh](scripts/docs-link.sh)，依赖同目录 `link-config.sh` 与 Agent 的 `docs-core.sh`；需要 Bash 5+、Git、Python 3。

## 执行

1. 读取源 `.docsconfig` 和登记清单，确认动作、目标、名称。当前工作区不是合法源 Git 根时停止，要求切换工作区；不代 `cd`。用户已提供的信息直接采用。
2. 按 [workflow.md](references/workflow.md) 解析本地目标或已登记 URL，执行单目标 `--dry-run`。展示双边清单、identity、名称、槽位及正文改写范围。
3. 按 [gates.md](references/gates.md) 核对授权，再用同一组参数真写。`--rewrite-http` 默认关，仅用户明确要求改正文并单独确认后使用。
4. 核对清单和软链；按联邦维护者的受众 A/B 输出结果。区分预览、双边完成、仅源侧完成和失败；推进动作见 [轻流程 C/M/S/F](../../references/light-flow-actions.md)。

```bash
# 将脚本路径替换为元库或已安装技能的实际位置；cwd 保持在源 Git 根。
bash <技能目录>/scripts/docs-link.sh --link --target <目标仓库根> --app-name <名称> --dry-run
bash <技能目录>/scripts/docs-link.sh --unlink --target <路径或已登记URL> --dry-run
```

## 必守边界

- 一个当前单元是一对源仓 × target；多目标逐个处理，授权范围以用户明确选择为准。
- `path` 只存 `${WORK_SPACE}/…`，分别按所属库配置展开。旧格式、缺配置或越界停止，不能用环境变量绕过；[路径契约](../../knowledge/knowledge-governance.md)是 SSOT。
- 普通文件/目录占用槽位、槽位指向不符、名称冲突时停止；不代删数据。`unlink` 只移除匹配 parent 与源 child，保留其他条目、正文 HTTP 及共用日志。
- 本技能不 clone/pull、不安装知识库、不提交 Git。失联注销、换父及中途失败的处理见工作流。

## 按需查阅

| 情况 | 参考 |
| --- | --- |
| 参数、执行与异常收口 | [workflow.md](references/workflow.md) |
| 预览确认、批次与 HTTP 授权 | [gates.md](references/gates.md) |
| 环境或旧数据异常 | [gotchas.md](gotchas.md) |
| 修改或验收技能 | [评测方法](references/evaluation.md)、[行为场景](evals/evals.json)、[评分规则](agents/grader.md) |
