# docs-indexing 行为评分

用 [evals.json](../evals/evals.json) 的当前场景与 assertions 评分，不根据措辞或固定标题匹配通过。

- should-trigger：是否完成索引职责或准确说明执行所需缺口。
- should-not-trigger：是否识别实际产物并转入对应流程。
- 检查实际命令、文件差异与回复；计划不能代替已发生的行为证据。
- 任一适用断言失败则整例 fail；没有失败但存在未执行或无证据断言则 not_run；全部适用断言有证据通过才为 pass。
- 共享门禁仅在场景进入相应阶段时检查；只读预览不要求写后烤干。

输出 `text`、`status`（pass/fail/not_run）、`evidence`；evidence 逐项包含断言 id、状态及可定位证据。独立评测使用临时工作区；只提供运行技能、当前请求和原始指南，隐藏预期与评分器，保存实际命令、响应和前后字节。目录访问边界不等同操作系统沙箱。

脚本行为另跑 [tests/run.sh](../tests/run.sh)。无需为验证文档重新执行完整技能安装。
