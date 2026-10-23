# Legacy v1 实体示例

`pass/` 保留 11 个早期实体样例，用于人工查看历史 frontmatter、英文 `Relations` / `Cross-perspective` / `Details` / `Evidence` 章节及关系表达。目录名 `pass` 是历史命名，不代表当前校验器认可的完整 bundle。

截至 2026-10-23，现有生产入口与测试 runner 均未加载本目录；链接扫描将其作为历史 fixture 排除，相关扫描回归只在临时消费仓验证这一排除规则。

这些文件缺少当前完整 bundle 的配置、目录布局与配套实体，不应直接传入当前 bundle 验证命令并期望通过。当前可执行行为以 `agent/scripts/tests/okf/` 的测试及 `agent/skills/docs-okf/tests/` 的临时夹具为准。保留此目录不承诺英文旧章节的解析兼容性。
