# docs-indexing 工作流

一个输出组只包含目标 `INDEX-GUIDE.md` 及其文内锚点。单元门禁见 [gates.md](gates.md)。

## 1. 确定输入

读取目标仓库约定、`.docsconfig` 和现有指南；采用用户已明确的参数，仅补影响执行的缺口。参数与预设见 [scan-config-onboarding.md](scan-config-onboarding.md)。

区分仓库根、`DOC_DIR` 扫描根和 `output` 位置，规则见 [参数规范](scan-config-onboarding.md#1-参数)。根仓库地图须由 Agent 在确认范围内补查源码与配置，不能把文档目录统计冒充全仓覆盖。

先只读检查路径、基线和工作区；incremental 缺少有效基线时，按 [基线选项](scan-config-onboarding.md#2-增量基线) 决策，不自行换模式。参数完整后进入写前意图澄清；预览无需写入授权。

## 2. 收集证据

按 [scan-spec.md](scan-spec.md) 确定深度、排除集和增量集合，再读取相应内容。脚本只辅助枚举候选，不能代替这一步。

```bash
# SKILL_DIR 为本次加载的 docs-indexing 目录；在目标仓库运行
bash "$SKILL_DIR/scripts/indexing.sh" --mode full --depth 2 --dry-run
```

命令参数以本轮已确认值替换。incremental 须带有效 `--since` 或从目标指南读取锚点；只读扫描不会自动推进基线。

## 3. 更新指南

获得当前单元写入授权后，按 [nine-chapter-spec.md](nine-chapter-spec.md) 和 [精简原则](../../../references/simplify-principles.md) 整理正文；新建时采用 [模板](../assets/index-guide-template.md)。

- 增量合并新增、修改、重命名和删除影响，保留未变章节。
- 原样保留 frontmatter、OKF 块及 `docs-build:entity-index:begin/end` 块；实体块内失效引用交给 docs-build 处理。
- 可选 `--rewrite` 仅更新扫描运行块；不要把运行块或文件数量当作九章指南。
- 按 [quality-standards.md](quality-standards.md) 检查正文、路径和覆盖声明。失败先修复，不写完成锚点。

## 4. 记录完成并烤干

指南成功后，用 [indexing-log-spec.md](indexing-log-spec.md) 的显式命令更新文内锚点。预览、仅扫描、更新运行块或失败不算索引完成。

单个指南及文内锚点必须烤干：覆盖面、增量依据、保留块、导航和受众。

按 [单元推进协议](../../../references/unit-cycle-protocol.md) 收敛后给出 `C/M/G/S/F` 并停住。其他输出组另行收口；OKF 刷新仅在用户需要时进入 [docs-okf](../../docs-okf/SKILL.md)。
