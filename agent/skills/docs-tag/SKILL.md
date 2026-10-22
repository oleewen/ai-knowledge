---
name: docs-tag
description: >
  为四层知识库 overview 扫描候选关键词、维护关键词附录、标记相关表行并刷新架构摘录。
  用于 /docs-tag、给概览打标签、关键词相关度扫描，或 overview 的 phase 3/excerpt 刷新。
  第三列知识提炼用 docs-extract；全文术语修订用 docs-revise；索引重建用 docs-indexing。
---

# docs-tag

处理单个 `{DOC_DIR}/knowledge/overview/{NAME}-overview.md`；只执行用户选定的阶段。

## 执行契约

- **单元是文件**，phase 是内部阶段。先收口相关参数，再执行；当前文件未收敛不推进其他 overview。
- **轻流程**：每阶段报告统计、核对结果，再按已确认范围继续。动作 `C/M/S/F` 见 [轻流程协议](../../references/light-flow-actions.md)，无 `G`，不强制意图澄清或 grilling。
- 自动化只调用 `1-scan`、`1-write`、`2`、`3`/`excerpt`。用户说 `all` 时由 Agent 分步执行，候选词须经用户选择。
- 写入前核对 [knowledge 引用边界](../../knowledge/knowledge-governance.md#业务-knowledge-引用边界)：可读外源，不把外源文档链接、下层链接或手写爬层路径写进 overview；上层实体引用使用规定的生成函数，无 parent 时用纯 ID。脚本不替代引用审查。

## 按阶段加载

执行先读 [workflow.md](references/workflow.md) 的参数与对应阶段，以及 [gates.md](references/gates.md) 的授权和停顿条件。

| 请求 | 所需输入 | 结果 |
| --- | --- | --- |
| 扫描候选 `1-scan` | file、keywords；scan-dir 默认同库 knowledge/，top-n 默认 30 | stdout JSON；不写文件 |
| 写选词 `1-write` | file、keywords、用户选择的 selected | 替换关键词附录 |
| 标记表行 `2` | file、已有非空关键词附录 | 刷新副标题列 ✅ |
| 架构摘录 `3` / `excerpt` | file、已有摘录表和视角表 | 按 ✅ 行刷新摘录；不需 keywords |

候选质量不佳时读 [algorithm.md](references/algorithm.md)；格式、锚点或执行异常查 [gotchas.md](gotchas.md)。

## 脚本与验证

从仓库根调用；安装环境按当前技能目录定位 `scripts/keyword_tag.py`，不假设安装目录仍叫 `agent/`。

```bash
python3 agent/skills/docs-tag/scripts/keyword_tag.py --help
python3 -m pytest agent/skills/docs-tag/tests -q
```

脚本仅依赖 Python 3 标准库；测试依赖 pytest、hypothesis、PyYAML。
行为场景见 [evals.json](evals/evals.json)，评分见 [grader.md](agents/grader.md)，失败分析见 [analyzer.md](agents/analyzer.md)。
