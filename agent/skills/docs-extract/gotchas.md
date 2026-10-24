# docs-extract 常见陷阱

按症状定位，不把执行失败解释成“无命中”。

| 症状 | 处理 |
| --- | --- |
| 附录缺失、空表或章节不对应 | 停在澄清；检查 [关键词附录格式](references/extract-spec.md#关键词附录格式) |
| “系统”“数据”等宽词导致大量候选 | 展示影响，建议收窄来源或关键词；确认前不改附录 |
| 缺失路径、读取失败、目标混入 sources | 按 [sources 归一化](references/extract-spec.md#sources-归一化) 报告并处理 |
| 单关键词短句或偶然字面命中 | 按业务语义与目标行要求判断，不以词数直接淘汰或入选 |
| 只有标题/代码出现关键词 | 按 [段落筛选](references/extract-spec.md#段落筛选) 排除，不能凑业务事实 |
| 锚点不可读 | 回退主标题章；两者均不可读则待核实，不认定新增 |
| 第三列有未归档要点 | 按 [提炼写入](references/extract-spec.md#提炼写入) 保留；与新内容冲突才请求决策 |
| 写入失败或检测到并发编辑 | 按 [落盘与失败](references/workflow.md#落盘与失败) 恢复或停顿，不强行覆盖 |

结束前用 [quality-checklist.md](references/quality-checklist.md) 验收；门禁不另起一套，见 [gates.md](references/gates.md)。
