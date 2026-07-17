# docs-indexing 反模式

| 问题 | 说明 |
| --- | --- |
| 参数未收口即写 INDEX/LOG | 先收口 `mode/depth/output/since` 与当前输出组，再意图澄清后写 INDEX/LOG |
| 跳过写前意图澄清 | 须六项清单 + 写前 `C`；见 [intent-clarify.md](../../../references/intent-clarify.md) |
| 路径/容器缺 INDEXING-LOG | 第 6 项须同时列出 `INDEX-GUIDE.md` 与 `changelogs/INDEXING-LOG.md` |
| spec 只有 basename | 须写 **`application/...` 级**根相对路径 |
| depth 3 少读 | 违 [scan-spec.md](scan-spec.md) |
| 无基线静默 full | 须用户 explicit full 或中止 |
| 写前 grilling 混名 | 写前=意图澄清；写后=烤干 |

操作：[gotchas.md](../gotchas.md)。
