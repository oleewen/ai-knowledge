# docs-simplify 工作流

须与 [gates.md](gates.md) binding 一致。

契约：

- 写前澄清：[intent-clarify.md](../../../references/intent-clarify.md)
- 单元推进 / `C/M/G/S/F`：[unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)
- 写后烤干：[grilling-skill.md](../../../references/grilling-skill.md)
- 写作原则：[docs-simplify.md](../../../references/docs-simplify.md)

## 参数向导

按序收口；用户已明确时可跳过对应项：

1. 主目标文件或候选范围
2. 是否包含默认排除类（索引/日志/生成物）；点名则纳入
3. 是否允许扩批
4. 与术语统一是否并存（并存则确认串行顺序）
5. 当前轮起始单元

参数未收口前，不进入单元推进。

## 当前单元

主文件 / 已确认扩批；一次一个。定义见 [gates.md](gates.md)。

## 写后默认表

| 对象 | 默认烤干 | 强制升级 |
| --- | --- | --- |
| 单个主文件或扩批 | **必须** | 未确认决策写入；疑似 SSOT 处理；C4 契约面变更；导航路径/相对链接/`#anchor` 变更；范围/目标口径变更 |

启发式只可升级为必须，不可把默认「必须」降为跳过。

## 技能步骤

推进环见 [unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)；本技能只补精简特有步骤：

### 1. 锁定目标

解析路径；无时先搜候选，多候选**列选项**。若用户同时要术语统一 → 先问主目标 / 串行顺序（见原则契约分流）。

### 2. 澄清

输出公共六项，标明「当前阶段：意图澄清」：

| 公共六项 | simplify 落点示例 |
| --- | --- |
| 本段/单元目标 | 本轮要精简/重组/去重什么 |
| 范围 / 非范围 | 主文件；是否含排除类；是否扩批 |
| 已知缺口 | 疑似重复候选、契约面风险；无则写「无」 |
| 禁止臆测项 | 不得编造他处 SSOT 路径；不得未确认删约束 |
| 写后烤干预判 | 按上表；当前单元默认必须烤干 |
| 写入路径/容器 | 主目标路径 + 本批次扩批清单（若有） |

可用 [docs-simplify-scope-ack-template.md](../assets/docs-simplify-scope-ack-template.md)。未获写前 `C` 不得写入。

### 3. 生成（改写）

写前读 [docs-simplify.md](../../../references/docs-simplify.md)。按 A→B→C 顺序处理当前单元：

1. **A**：结论上提、MECE 分组、渐进披露、表/列表替换长散文；**若属模板硬结构**，保留章号与节标题，只在节内 BLUF  
2. **B**：激进删套话与装饰例；保留约束/例外/验收与必要表行；不期待表密文档大幅降行数  
3. **C**：全仓语义相似扫疑似重复 → **列出候选等人确认** → 仅改当前文件为引用/摘要（默认不改 SSOT 正文）；守 C4（可刷新 `updated`）

### 4. 烤干

按 [quality-checklist.md](quality-checklist.md) 与原则验法检查；语义问题先给结论、推荐与数字选项。  
表密/模板文档：勿用「行数几乎没变」单独判失败；查散文是否仍啰嗦、编号实体与验收是否仍在。

### 5. 扩批（下一单元）

仅在当前单元烤干收敛且用户写后 `C` 确认允许扩批时，将下一批定为新当前单元并重走澄清→生成→烤干。

用户动作见 unit-cycle-protocol；本技能 `S` 补充语义见 [gates.md](gates.md)。

## 不确定

仓内无法核实疑似 SSOT → **停**、编号选项 → 用户选后再动。
