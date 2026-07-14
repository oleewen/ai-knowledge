# docs-pull 风险控制与确认点

[SKILL.md](../SKILL.md)；执行循环 [workflow.md](workflow.md)。

## 参数确认

参数向导至少收口以下内容：

- 运行模式：system 或 company
- `--app` / `--sys-name` / `--all`
- 当前轮是否只处理一个槽位还是准备批量继续

满足任一时，先澄清再执行：

- 用户只说“同步一下”但未说明 app/sys 范围
- `--all` 是否真要批量继续不清
- 当前运行模式（system 或 company）不清

## 风险确认

以下情况属于风险项，必须先给出结论、推荐方案与动作选项，再等待用户确认：

- 槽位目录不存在，需先 `docs-link`
- `path` 不存在或不是 Git 工作区
- 目标 `.docsconfig` 缺失或无法解析
- `knowledge-links.yaml` 缺字段
- `--all` 准备继续后续槽位

推荐会话格式：

```text
即将执行 /docs-pull，当前参数如下：
- mode: <system|company>
- selector: <--app X|--sys-name Y|--all>
- 当前槽位单元: <application-{app}|system-{sys}>

C 确认当前槽位单元 / M 修改参数 / S 跳过当前槽位 / F 补齐剩余槽位
```

## 默认授权边界

- 已收口参数下，可直接执行非语义性动作：读取 links、解析 `.docsconfig`、校核槽位存在性
- 涉及是否继续下一槽位、是否接受 `--all` 批量推进，按语义性处理

## 约束

- 必须先有 `docs-link` 创建槽位
- 同步写槽位根目录时排除 `README.md`、`index.md`、`changelogs/`
- 槽位 `CHANGE-LOG.md` 追溯记录必须跟随同步追加
