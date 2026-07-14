# docs-agent 风险控制与确认点

主干：[SKILL.md](../SKILL.md)。执行循环：[workflow.md](workflow.md)。

## 参数确认

参数向导至少收口以下内容：

- `output`: `readme` / `agents` / `both`
- `mode`: `create` / `update`
- 当前轮是否涉及覆盖已有内容

满足任一时，先澄清再写：

- 未说明输出范围
- 未说明 `create` / `update`
- 指令过宽，可能越出根入口双文件

## 风险确认

以下情况属于语义性或高风险写入，必须先给出结论、推荐方案与动作选项，再等待用户确认：

- `update` 与覆盖边界不清
- README 与 AGENTS 职责边界需要调整
- 已有内容是否保留存在歧义
- `output=both` 但用户只明确了一个文件

推荐会话格式：

```text
即将执行 /docs-agent，当前参数如下：
- output: <readme|agents|both>
- mode: <create|update>
- 当前单元: <README.md|AGENTS.md>
- 写入策略: <merge|overwrite|待确认>

C 确认当前单元 / M 修改参数或策略 / S 跳过当前单元
```

## 默认授权边界

- 已收口参数下，可直接执行**非语义性修订**：错别字、编号、排版、锚点修补
- 涉及内容保留/删除、职责迁移、覆盖已有段落，按语义性处理

## 与 INDEX 的关系

- INDEX 须已落盘；无 INDEX 不编造
- 本技能不替代 `docs-indexing`
- INDEX 落盘约束见 [execution-spec.md](execution-spec.md)，独立生效
