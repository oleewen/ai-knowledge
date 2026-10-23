---
name: docs-upgrade
description: >
 将已有知识库按元库模板升级，保留本库正文；支持整树预览与指定文件、目录对齐。
 用户要求升级知识库、刷新骨架、对齐 meta 模板或只升级某路径时使用。
 首次初始化、Agent 安装及生态技能追新分别用 docs-install、agent-install、skill-upgrade。
---

# docs-upgrade

**结构与模板跟元库，业务正文留本库。**一次处理一个工程的 `文档目录`，先预览、确认后写盘。

## 选择模式

| 输入 | 模式与执行者 |
| --- | --- |
| 未指定文件或目录 | 整树：脚本扫描、备份、写骨架；Agent 重填正文 |
| 指定可解析的文件或目录（含 IDE 附件路径） | 指定路径：Agent 只对齐名单；目录须取两侧文件并集，含 `meta-only` |
| 像路径但无法解析 | 先澄清；不得默选整树 |

两模式互斥，不要求 `@` 前缀。脚本没有 `--path`。

## 执行入口

1. 读 [parameters.md](references/parameters.md) 收口工程、元库、ref 与指定路径；缺配置不得猜测。
2. 按 [workflow.md「源解析」](references/workflow.md#源解析) 校验本层来源，再进入对应模式。整树有版本号时只读取目标发布快照，发布后的 HEAD 内容不入范围。
3. 按 [merge-rules.md](references/merge-rules.md) 分类并生成预览；写盘前执行 [gates.md](references/gates.md) 的 `C/M/S/F` 确认。有未落位时，`C` 后再选并入策略。
4. 完成写后校核与受众 A/B；整单成功才按 workflow 推进版本。

## 必守边界

- 不调用会清空 `DOC_DIR` 的 `docs-install.sh --scope=knowledge`，不删除本库独有文件，不用元库覆盖 `knowledge-links.yaml`。
- 两模式均只升级本库 `KNOWLEDGE_TYPE` 对应层；`meta.dir` 错配须在快照解析、目录展开和写盘前停止。
- 软链及其下路径不跟随；槽位真文件可按普通路径升级，槽位维护用 [docs-link](../docs-link/SKILL.md)，内容更新遵循目标仓普通 Git 工作流。
- 整树缺失示例按 [真实实例规则](references/merge-rules.md#31-整树缺失示例与真实实例) 去重；指定路径模式仍补齐缺失示例。
- 根级 `DESIGN.md` 是整文件覆盖特例；版本推进独立于 scaffold。结构重填与未落位处理由 Agent 完成，脚本不自动合正文。

首次装机用 [docs-install](../docs-install/SKILL.md)；Agent 树用 [agent-install](../agent-install/SKILL.md)；生态技能用 [skill-upgrade](../skill-upgrade/SKILL.md)。联邦登记用 [docs-link](../docs-link/SKILL.md)；规约设计由 [sdx-design](../sdx-design/SKILL.md) 只读引用中央来源，不提供跨仓下发。

## 按需查阅

| 当前工作 | 读取 |
| --- | --- |
| 执行整树命令、核对参数 | [脚本帮助](scripts/docs-upgrade.sh)：Bash 5+ 执行 `-h`；在目标工程运行 |
| 重填 md、处置未落位 | [merge-rules.md §5–§6](references/merge-rules.md#5-结构重填agent) |
| 处理版本、备份、路径重写或重试 | [workflow.md](references/workflow.md)；异常定位见 [gotchas.md](gotchas.md) |
| 维护或评测技能 | [evals.json](evals/evals.json)、[grader.md](agents/grader.md)、[测试入口](tests/run.sh) |
