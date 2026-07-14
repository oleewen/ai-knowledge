# docs-indexing 反模式

| 问题 | 说明 |
| --- | --- |
| 参数未收口即写 INDEX/LOG | 先收口 `mode/depth/output/since` 与当前输出组，再写 INDEX/LOG |
| spec 只有 basename | 须写 **`application/...` 级**根相对路径 |
| depth 3 少读 | 违 [scan-spec.md](scan-spec.md) |
| 无基线静默 full | 须用户 explicit full 或中止 |

操作：[gotchas.md](../gotchas.md)。
