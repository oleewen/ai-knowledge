# sdx-test 常见陷阱

---

## 输入与前置

**无 PRD 直接写 TDD**：PRD 文档是硬输入；缺失则终止并提示先执行 `sdx-prd`。用例无法追溯到 US-n / FR-n 时，评审与验收无锚点。

**无 ADD 仍按「完整接口覆盖」编造路径**：ADD 不存在时，在 TDD 概述中显式标注「缺少 ADD 基线」，接口类用例收缩为 PRD 已声明边界；待 ADD 补齐后再扩展 TC-API-*，不凭印象假设 API 路径与错误码。

---

## 用例与追溯

**臆测用例、无 US/API/BR 锚点**：每个 TC 至少关联 US-n、或 ADD 中 API 规约、或 BR-n；做不到则标为待澄清项，不填空或泛写。

**仅 happy path，忽略异常与边界**：§2.4、§2.5 若无 NFR 或未要求性能/安全测试，须显式写「不适用」及原因，不留空。按 `workflow-spec` 中 depth 要求覆盖异常与并发场景，否则上线后缺陷集中出现在这些场景。

**回归范围与 ADD 影响面脱节**：§2.6 须与 ADD 影响面分析对齐，标注直接影响 / 间接影响与优先级（P0 核心链优先），不写「全量回归」或泛泛列举模块。

---

## 范围与产出物

**在 TDD 中写自动化脚本或可执行测试代码**：仅产出 `TDD-*.md`；自动化实现留在开发流程与代码仓，否则混淆设计阶段与实现阶段，模板章节被代码挤占。

**跳过或重排模板章节**：严格遵循 [assets/tdd-template.md](assets/tdd-template.md)；无内容章节保留标题并写「不适用」或「待补充」，不删除。`validate-test.sh` 与门禁会检查章节完整性。

**忽略 `--depth` 参数**：`quick` 仅设计 P0 功能用例与核心接口用例；`standard` 完整六类用例；`deep` 额外增加性能与安全用例。`quick` 场景下展开完整矩阵成本过高，`deep` 场景下过薄则覆盖不足。

---

## 文档输出

**文档元数据位置错误或字段缺失**：勿在文件开头写 YAML frontmatter；仅在文末「## 文档元数据」fenced `yaml` 中填写字段；须包含 `id`、`title`、`version`、`status`、`created`、`updated`、`parent`、`mvp_phase`，初始 `status` 为 `draft`，`parent` 填写上游 PRD 编号。

**未执行质量门禁自查即宣称完成**：步骤 5 必须逐项检查 [reference/quality-checklist.md](reference/quality-checklist.md)；必要时运行 `validate-test.sh`，否则 frontmatter、子章节或追溯字段遗漏流入下游。

---

## 快速自查清单

- [ ] PRD 文档已落盘且可用，`parent` 与 `mvp_phase` 字段已填写
- [ ] ADD 缺失时已在概述中标注，接口用例已收缩为 PRD 边界
- [ ] 每个 TC 关联 US-n / API 规约 / BR-n，无孤立用例
- [ ] §2.4 异常场景已覆盖（或显式标注「不适用」）
- [ ] §2.5 性能用例已覆盖（或显式标注「不适用」）
- [ ] §2.6 回归范围与 ADD 影响面对齐
- [ ] 六章结构完整，无删除章节
- [ ] 文末元数据 YAML 字段完整（含 `parent`、`mvp_phase`）；文件开头无 `---` YAML
- [ ] TDD 中无自动化测试代码
- [ ] quality-checklist.md 已逐项勾选
