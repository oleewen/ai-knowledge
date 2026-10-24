# 25 个技能逐项审查

持续审查收口于 2026-10-24。依据用户指定的 grilling 与 skill-creator：保留职责及业务约束，按已授权的推荐方案修订；以实际问题决定改动，不机械增加规则或用例。未提交或推送 Git，未更新真实全局安装环境。

**25/25 已完成逐项审查；不等于所有模型用例通过。** 表中脚本回归、模型观察和未测项分别记录；历史失败、未测场景及冻结副本早于最终微调的限制保留在分项报告。脚本计数口径不同，不相加制造总通过率。

| 技能与证据 | 本轮结论 | 脚本验证 | 模型行为抽样 |
| --- | --- | --- | --- |
| [agent-install](agent-install/evals/evaluation-report.md) | 工作区冲突、共享链接、隐藏缓存过滤 | 18；bootstrap 14 | 3 场景；10 未测 |
| [docs-install](docs-install/evals/evaluation-report.md) | 环境变量不授予 force；依赖前置；真实改写错误传播 | 30 | 最终 3 场景；初次失败保留；15 未测 |
| [docs-upgrade](docs-upgrade/evals/evaluation-report.md) | 保留固定快照及来源；类型冲突在写入前阻塞 | 11 | 2 场景；15 未测 |
| [docs-link](docs-link/evals/evaluation-report.md) | 大小写别名重命名；清单解析拒绝歧义 | 33 | 2 场景；初次失败保留；26 未测 |
| [docs-publish](docs-publish/evals/evaluation-report.md) | 计划指纹绑定、版本与 rebase 冲突边界 | 6 | 2 场景；7 未测 |
| [docs-indexing](docs-indexing/evals/evaluation-report.md) | 锚点失败不跳过；正文定位排除代码示例 | 43 Python + 1 Bash | 2 场景；13 未测 |
| [docs-build](docs-build/evals/evaluation-report.md) | 真实区块定位；正文与 Unicode 偏移一致 | 21 | 2 场景；10 未测 |
| [docs-okf](docs-okf/evals/evaluation-report.md) | 输出路径预检；唯一数据节点；陈旧 viz 拒收 | 技能与共享回归通过；浏览器项跳过 | 2 场景；11 未测 |
| [docs-agent](docs-agent/evals/evaluation-report.md) | 按 output 校验；安装路径调用；移除孤立例外 | 3 + 5 | 1 场景；5 未测 |
| [docs-extract](docs-extract/evals/evaluation-report.md) | 去除短段双关键词误淘汰；语义落点；授权复用 | 无执行脚本 | 最终 2 场景；旧版失败保留；19 未测 |
| [docs-distill](docs-distill/evals/evaluation-report.md) | 文档目录与知识层分离；路径冲突及越界前置 | 12 | 2 项路径前置；9 未测，未证明语义蒸馏 |
| [docs-archive](docs-archive/evals/evaluation-report.md) | 写前版本核对；恢复不得覆盖后续编辑 | 59 个评测工具测试 | 2 项真实文件操作；并发恢复未测；旧回答套件未跑 |
| [docs-merge](docs-merge/evals/evaluation-report.md) | 保留成熟合入流程；修正评测数量漂移 | 26 个评测工具测试 | 1 场景；32 未测 |
| [docs-revise](docs-revise/evals/evaluation-report.md) | 评分绑定完整 suite 哈希；历史结果拒绝冒充新判据 | 11 个评分器测试 | 实际单例写入：2 个文件断言通过，工具轨迹断言未测；另 20 场景未跑 |
| [docs-simplify](docs-simplify/evals/evaluation-report.md) | 保留范围、约束及 SSOT 规则 | 14 个驱动测试 | 1 个三文件批次；27 场景未测 |
| [docs-tag](docs-tag/evals/evaluation-report.md) | HTML 锚点、单引号关键词、摘录表范围 | 87 | 1 场景；12 未测 |
| [skill-upgrade](skill-upgrade/evals/evaluation-report.md) | 保留流程；补实际离线失败即停及核验场景 | 无自有执行脚本 | 1 场景；13 未测；未调用真实生态 CLI |
| [sdx-analysis](sdx-analysis/evals/evaluation-report.md) | 保留已收敛的入口、事实及 ADR 约束 | 49 | 本轮未重跑；历史 6 场景单独保留 |
| [sdx-feature](sdx-feature/evals/evaluation-report.md) | 注释不能制造标题；六章顺序；保留注释外 ADR | 27 | 1 项严格结构调用；25 场景未测 |
| [sdx-prd](sdx-prd/evals/evaluation-report.md) | 保留阶段及上游边界；验证只读评审 | 37 | 1 场景；15 未测 |
| [sdx-architect](sdx-architect/evals/evaluation-report.md) | 中文及旧格式 IDEA-ID 同链校验 | 68 | 中文 ASD 真实结构调用；12 场景未测 |
| [sdx-design](sdx-design/evals/evaluation-report.md) | 中央 URL 路径百分号解码；保留同链检查 | 62 | 编码 URL 的真实结构调用；27 场景未测 |
| [sdx-test](sdx-test/evals/evaluation-report.md) | 必需小节父章、重复标题及 H1 边界 | 108 | 错父章真实结构调用；24 场景未测 |
| [sdx-solution](sdx-solution/evals/evaluation-report.md) | 保留事实边界；补独立发现正反场景 | 51 | 1 场景；6 行为及 2 发现场景未测 |
| [sdx-domains](sdx-domains/evals/evaluation-report.md) | 保留旧命名、实体事实和当前段边界 | 45 | 1 个旧稿续写；11 场景未测 |

全仓收尾验证：25 个技能均通过 skill-creator `quick_validate.py`；现行 Markdown 链接检查、`git diff --check`、Bash 5 下 `agent/scripts/tests/run.sh --quick` 全部通过。未运行全仓 full，也未将结构检查、评测运行器测试或历史成绩计作当前模型行为通过。

最终运行材料摘要见 [审查清单](review-manifest-2026-10-24.json)，用于识别后续文件变化；它不是每次模型运行副本的替代证据。

临时夹具日志不是永久归档；分项 JSON 留存关键响应、命令、退出码、文件差异或摘要。多数场景未导出完整工具转录，目录约束不是操作系统沙箱；证据不足的断言不冒充通过。仍可继续验证的范围已在各报告列明，不属于本轮按风险抽样的已验结论。
