# sdx-prd 常见反模式

与 [design-principles.md](design-principles.md) 中表格级「禁止」清单互补；**操作层易错点**仍见 [../gotchas.md](../gotchas.md)。

---

## 反模式与纠正动作

1. **未确认先落盘 PRD**
   - 表现：Qclose-1 未完成或 `PENDING` 未改 `CONFIRMED`，即写入 `{DOC_DIR}/requirements/**/PRD-*.md` 终稿（且无合法例外依据）。
   - 纠正：回到会话 spec，完成总确认与门禁标记；或记录用户明示例外 / 环境变量依据。详见 [gates.md](gates.md)。

2. **无 ANALYSIS 或未限定 MVP 仍开写**
   - 表现：缺少 `ANALYSIS-{IDEA-ID}.md` 或未锁定 `--mvp` 范围即长篇写 PRD。
   - 纠正：终止并提示先执行 `sdx-analysis`；严格仅纳入当前 MVP 的 FR-n。见 [gotchas.md](../gotchas.md)。

3. **用独立 brainstorming 终态替代本会话 spec**
   - 表现：跳过 Gn 收口或 Qclose-1；默认 `*-design.md` 替代 `...-sdx-prd.md`。
   - 纠正：阶段二主产物仍为会话 spec + 门禁表。见 [brainstorming-integration.md](brainstorming-integration.md)。

4. **实现细节泄漏进 PRD 正文**
   - 表现：写接口 Path、表字段、中间件选型作为「需求」。
   - 纠正：PRD 只写「做什么」与业务规则；技术归宿留给 **DSD**。见 [design-principles.md](design-principles.md)。

5. **臆测需求或吞没歧义**
   - 表现：无 FR-n 引用即编用户故事；歧义不标 Q-n 自行补全。
   - 纠正：证据优先；一律 Q-n 单题澄清。

6. **模板跳章或空章提交**
   - 表现：删改十一章顺序；标题下空白且未标「不适用」。
   - 纠正：严格 `prd-template.md` 结构，空章须标注。

7. **MVP 越界**
   - 表现：把后续 MVP 的 FR/US 纳入当前 PRD。
   - 纠正：对照 ANALYSIS §4 当前阶段范围裁剪。

8. **UC / US 脱节**
   - 表现：无双向映射、缺前后置或缺扩展场景。
   - 纠正：UC-n ↔ US-n 互标；用例描述要素齐全。

9. **§9 NFR 与 §10.2 NAC 脱节**
   - 表现：NAC 无法指回 §9 或应标「不适用」却留空。
   - 纠正：逐条互链或可解释不适用。

10. **业务规则散落未进 §7**
    - 表现：BR 只写在流程/故事里，§7 汇总缺失。
    - 纠正：§7 集中表 + 与 UC 关联列完整。

11. **虚假勾选 §11.3**
    - 表现：未对照 [quality-checklist.md](quality-checklist.md) 即全选 `- [x]`。
    - 纠正：逐项判定，未达标保持 `- [ ]`。

12. **元数据位置或字段错误**
    - 表现：文件头 `---` frontmatter；缺 `parent` / `mvp_phase` 等。
    - 纠正：仅文末 fenced yaml，字段齐全。见 [workflow.md](workflow.md)。

13. **Mermaid 语法错误导致评审图不可渲染**
    - 表现：混用图类型或语法不合法。
    - 纠正：输出前自检；按图类型选用正确声明。

14. **未校验即宣告完成**
    - 表现：未运行 `validate-prd.sh`（及按需 `--gate-check`）即结束。
    - 纠正：收尾必跑校验，失败则修复后重跑。见 [SKILL.md](../SKILL.md)。
