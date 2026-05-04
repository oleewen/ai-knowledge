# sdx-analysis 常见反模式

与 [design-principles.md](design-principles.md) 原则层互补；**操作层易错点**仍见 [../gotchas.md](../gotchas.md)。

---

## 反模式与纠正动作

1. **未确认先落盘 ANALYSIS**
   - 表现：Qclose-1 未完成或 `PENDING` 未改 `CONFIRMED`，即写入 `{DOC_DIR}/analysis/ANALYSIS-*.md` 终稿（且无合法例外依据）。
   - 纠正：回到会话 spec，完成总确认与门禁标记；或记录用户明示例外 / 环境变量依据。详见 [gates.md](gates.md)。

2. **无 SOLUTION 硬输入仍开写**
   - 表现：找不到或未对齐 `SOLUTION-{IDEA-ID}.md` 仍长篇写 ANALYSIS。
   - 纠正：终止并提示先执行 `sdx-solution`；或显式标注「基于不完整方案」并收窄承诺范围。见 [gotchas.md](../gotchas.md)。

3. **用独立 brainstorming 终态替代本会话 spec**
   - 表现：以「已完成 brainstorming」为由跳过 Gn 收口或 Qclose-1；默认 `*-design.md` 替代 `...-sdx-analysis.md`。
   - 纠正：阶段二主产物仍为会话 spec + 门禁表。见 [brainstorming-integration.md](brainstorming-integration.md)。

4. **G{n} 与 G-n 混用**
   - 表现：流程门禁编号与 §1.2 业务目标条目编号混写，追溯断裂。
   - 纠正：**G{n}** = 流程步骤；**G-n** = 业务目标条目；二者不得互换。

5. **并行展开未收口的多门禁**
   - 表现：Gn 未收口即展开 G(n+1) 大段。
   - 纠正：一次一段或一点；回跳按 [workflow.md](workflow.md) 影响面处理。

6. **回跳后未经评估即全部重填**
   - 表现：从 G{k} 回改后无差别重填后续所有门禁。
   - 纠正：按强/弱/无依赖说明并由用户选择重走范围。

7. **确认人或门禁标记占位**
   - 表现：确认人填占位词；spec 缺 `<!-- sdx-analysis-gate -->` 或未出现目标 `ANALYSIS-{IDEA-ID}.md`。
   - 纠正：确认人用 `$HOME` 末级目录名；补齐标记与文件名。见 [gates.md](gates.md)。

8. **误认为仅 G2/G4 才需多方案比选**
   - 表现：在 G1/G3/G5 等存在真实分叉时仍单线叙述。
   - 纠正：任意 G{n} 有 ≥2 条真实路径时，在本门禁内完成对比再收口。

9. **技术语言污染 §1–§5 与 §6.1–§6.2**
   - 表现：正文大量接口名、表名、中间件名。
   - 纠正：业务可读；线索进 §6.3 并标「待研发确认」。见 [audience-and-language.md](audience-and-language.md)。

10. **虚假勾选 §6.4**
    - 表现：未逐项对照 [quality-checklist.md](quality-checklist.md) 即全选通过。
    - 纠正：逐项判定，未达标保持 `- [ ]`。

11. **MVP 无业务价值或含环依赖**
    - 表现：按技术模块硬拆、无法独立演示；§4.3 依赖图有环。
    - 纠正：每 MVP 能回答业务价值问句；拆后验无环。见 [gotchas.md](../gotchas.md)。

12. **P0 需求落在后序 MVP**
    - 表现：P0 FR 未放入首个合理 MVP。
    - 纠正：P0 须随首个可交付 MVP；基础设施随首个消费方 MVP。

13. **IDEA-ID 与上游脱节**
    - 表现：ANALYSIS 所用 IDEA-ID 与 SOLUTION 文件名不一致。
    - 纠正：阶段一锁定与 `SOLUTION-{IDEA-ID}.md` 同链。见 [core-concepts.md](core-concepts.md)。

14. **未校验即宣告完成**
    - 表现：未运行 `validate-analysis.sh`（及按需 `--gate-check`）即结束。
    - 纠正：收尾必跑校验，失败则修复后重跑。见 [SKILL.md](../SKILL.md)。
