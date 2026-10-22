# docs-distill 推进协议（binding）

主干：[SKILL.md](../SKILL.md)。本文件只声明本技能的单元、追加字段、风险和原子性；共通动作与状态机见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)。

## 当前单元

一个 `{NAME}-overview.md` 加一次全量范围。一次只处理一个源名称；收敛前不得自动切换另一源或另一边。

## 写前追加字段

公共六项之外，澄清必须包含：

- `DOC_DIR`、`--name`、源槽位和目标 overview
- 正式写入或 `--dry-run`
- overview 是新建还是更新
- 职责、表行粒度、跨层收束摘要及其契约锚点

未获写前 `C`，不得写入或输出正式预览结论。

## 高风险

先给结论、推荐项和数字选项，再执行：

- 首次创建 overview 或覆盖已有第三列
- 跳过预览直接写入
- 槽位缺失、为空、未 pull 或缺 README
- 职责/粒度契约缺失、模糊或双边冲突
- 目标层与槽位内容冲突且无法按既有规则消解

职责/粒度未闭合时必须先落盘契约；在此之前不得 dry-run。

## 原子性

- 仅写目标 overview 第三列；新建时允许从模板复制并替换 `{NAME}`。
- `--dry-run` 不写 overview。
- 不写 `DISTILL-LOG`，不接受 `--since` 或 `--full`。
- 槽位前置条件不满足就停，不用源仓直读绕过。
- 写入或预览后必须烤干；未收敛不得宣称完成。
