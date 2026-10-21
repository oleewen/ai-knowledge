# docs-indexing 行为评分

用 [evals.json](../evals/evals.json) 的当前场景与 assertions 评分，不根据措辞或固定标题匹配通过。

- should-trigger：是否完成索引职责或准确说明执行所需缺口。
- should-not-trigger：是否识别实际产物并转入对应流程。
- 检查实际命令、文件差异与回复；计划不能代替已发生的行为证据。
- P0 任一失败则整例失败；未执行或无证据的断言标记未验证，不伪造通过。
- 共享门禁仅在场景进入相应阶段时检查；只读预览不要求写后烤干。

输出 `text`、`passed`、`evidence`；evidence 逐项包含断言 id、结果及可定位证据。独立评测使用临时工作区，避免污染仓库或真实指南。

脚本行为另跑 [tests/run.sh](../tests/run.sh)。无需为验证文档重新执行完整技能安装。
