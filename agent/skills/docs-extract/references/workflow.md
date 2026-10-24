# docs-extract 工作流

完成一个 overview 的一批提炼后停下。单元、澄清与推进动作见 [gates.md](gates.md)；筛选与写入口径见 [extract-spec.md](extract-spec.md)。

## 参数向导

收口 `--sources`、`--overview`、关键词范围和是否 `--dry-run`；已给出的参数直接采用，缺失或歧义项才问。

先只读核对目标、附录及来源。dry-run 参数明确即可进入预览；正式写入按 gates 完成写前意图清单并核对授权。仅缺失或歧义会影响结果时停问。

## 执行

1. **筛选**：按 extract-spec 归一化 sources，生成带来源位置、命中词与目标章节的候选。无命中时报告原因、保持目标不变，结束单元。
2. **比对**：读取命中章节的要求与知识正文，形成 delta 和 A/U/D。保留旧待归档项；缺失依据或冲突先澄清。
3. **预览或写入**：dry-run 用下表输出；正式模式只改确认的第三列，处理方式见「落盘与失败」。全部已覆盖时不产生文件修改。
4. **验收与烤干**：按 [quality-checklist.md](quality-checklist.md) 检查实际产物；收敛后停等用户动作，不自动扩到另一个 overview 或另一批来源。

## dry-run 输出

| 分区 | 内容 |
| --- | --- |
| 将写入 | 目标行、A/U/D、新 delta；已有待归档内容时说明保留/替换范围 |
| 跳过（已覆盖） | 要点与知识正文的覆盖依据；旧第三列已有相同待归档项须单独说明，不能称为正文已覆盖 |
| 无命中 | 无候选的来源/目标行及简短原因 |

空分区写「无」。已覆盖超过 10 行时输出统计与样例，用户 `M` 可展开。不可读、二进制、隐藏路径等扫描排除项另附说明，不混作“语义无命中”。预览不写目标、附录或日志。

## 落盘与失败

- 写前保留目标快照；先在内存或临时副本构造完整结果，核对差异仅涉及本轮第三列，再一次替换目标。
- 替换前确认目标仍与快照一致；已被他人修改则停止，重读后重新核对，不覆盖并发编辑。
- 写入失败或验收发现部分落盘，撤销本轮改动；仅在目标未被他人继续修改时还原快照，否则停下并报告冲突。
- 无命中、全部已覆盖、dry-run 都不执行替换。不写 `DISTILL-LOG`，不代做归档或改知识正文。

## 写后默认表

| 对象 | 默认烤干 | 检查重点 |
| --- | --- | --- |
| 单个 overview 提炼结果，含 dry-run | 必须 | 范围与依据、delta/旧项、引用边界、受众 A/B/C/E |

按 [grilling-skill.md](../../../references/grilling-skill.md) 调用已安装的 grilling 或其 fallback。受众要求见 [audience-and-language.md](audience-and-language.md)；全过可静默，不以打印维度名称代替检查。

## 命令示例

以下为会话调用，不在终端执行：

```text
/docs-extract --sources docs/design.md docs/adr/ --overview system/knowledge/overview/billing-overview.md --dry-run
/docs-extract --sources "退款申请须先审批，审批完成后通知申请人。" --overview application/knowledge/overview/order-overview.md --dry-run
```
