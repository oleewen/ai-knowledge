# sdx-solution 常见反模式

与 [design-principles.md](design-principles.md) 原则层互补；**操作层易错点**仍见 [../gotchas.md](../gotchas.md)。

---

## 反模式与纠正动作

1. **未确认先落盘 SOLUTION**
   - 表现：Qclose-1 未完成或 `PENDING` 未改 `CONFIRMED`，即写入 `{DOC_DIR}/solutions/SOLUTION-*.md` 终稿（且无合法例外依据）。
   - 纠正：回到会话 spec，完成总确认与门禁标记；或记录用户明示例外 / 环境变量依据。详见 [gates.md](gates.md)。

2. **用独立 brainstorming 终态替代本会话 spec**
   - 表现：以「已完成 brainstorming」为由跳过 Gn 收口、门禁标记或 Qclose-1；或默认创建 `*-design.md` 替代 `...-sdx-solution.md`。
   - 纠正：阶段二主产物仍为会话 spec + 门禁表；多方案对比留在 G{n} 内完成。见 [brainstorming-integration.md](brainstorming-integration.md)。

3. **G{n} 与 G-n 混用**
   - 表现：将流程门禁编号与模板 §1.3 业务目标条目编号写混，导致追溯混乱。
   - 纠正：**G{n}** = 流程步骤；**G-n** = 业务目标条目；二者不得互换。

4. **并行展开未收口的多门禁**
   - 表现：Gn 未收口即展开 G(n+1) 大段内容。
   - 纠正：一次一段或一点，收口后再进下一门禁（回跳按 [workflow.md](workflow.md) 处理）。

5. **回跳后未经评估即全部作废**
   - 表现：用户从 G{k} 回改后，无差别重填后续所有门禁。
   - 纠正：按强/弱/无依赖评估影响面，由用户选择重走范围。

6. **确认人或门禁标记占位**
   - 表现：确认人填「用户」、邮箱或显示名；spec 缺 `<!-- sdx-solution-gate -->` 或正文未出现目标 `SOLUTION-{IDEA-ID}.md` 文件名。
   - 纠正：确认人用 `$HOME` 末级目录名；补齐标记与文件名引用。见 [gates.md](gates.md)。

7. **误认为仅 G4 才需多方案比选**
   - 表现：在 G2/G3/G5/G6 等存在真实分叉时仍单线叙述、不对比即收口。
   - 纠正：任意 G{n} 存在 ≥2 条真实路径时，在本门禁内完成 2–3 套对比再写结论。

8. **技术语言污染业务章**
   - 表现：在 §1–§6 及 §7.1–§7.2 大量堆叠接口名、表名、中间件名。
   - 纠正：业务可读；技术线索收敛至 §7.3「内部参考」并标注待研发确认。见 [audience-and-language.md](audience-and-language.md)。

9. **虚假勾选 §7.4**
   - 表现：未逐项对照 [quality-checklist.md](quality-checklist.md) 即把 `- [ ]` 全改为 `- [x]`。
   - 纠正：逐项判定，未达标保持 `- [ ]`。

10. **无输入或吞没歧义闷写**
    - 表现：无原始业务材料即开写；或遇歧义不建 Q-n、自行假设继续。
    - 纠正：补足输入；歧义一律 Q-n 单题澄清。见 [workflow.md](workflow.md) Q-n 协议。

11. **影响面四维缺失或 quick 完全省略**
    - 表现：只列功能；或 `quick` 深度下影响面整段空白。
    - 纠正：须覆盖功能、数据、接口/对外承诺、下游协作；quick 可压缩但不得整段省略高影响项。见 [gotchas.md](../gotchas.md)。

12. **C-n 缺成本与残余风险**
    - 表现：冲突化解只有口号无成本档位与残余风险。
    - 纠正：每项 C-n 含策略、成本（高/中/低）、残余风险。

13. **不可测业务目标或 MVP 伪拆分**
    - 表现：目标只有「提升体验」等空话；MVP 按技术模块切无法向业务方独立演示价值。
    - 纠正：目标可验证或标「待澄清」；每 MVP 能回答「解决什么业务问题」。见 [design-principles.md](design-principles.md)。

14. **未校验即宣告完成**
    - 表现：未运行 `validate-solution.sh`（及按需 `--gate-check`）即结束。
    - 纠正：收尾必跑校验，失败则修复后重跑。见 [SKILL.md](../SKILL.md) 产出与校验节。
