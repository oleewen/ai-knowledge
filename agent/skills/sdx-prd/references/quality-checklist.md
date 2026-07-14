# PRD 质量验收

终稿 **§11.3** 须与本清单及 [../assets/prd-template.md](../assets/prd-template.md) §11.3 **通过标准**一致；达标改 `- [x]`，不达标保持 `- [ ]`，禁止假勾选。原则见 [design-principles.md](design-principles.md)。

## 结构与完整性

- [ ] `## 1`–`## 11` 齐；Mermaid 可渲染；空章标「不适用/待补充」

## §1–§11（与 template 对齐）

- [ ] §1.1–§1.4：路径/MVP、成功标准、范围与角色对齐 §4
- [ ] §2：六要素主流程、EX-n、跨系统或「不适用」
- [ ] §3：核心交互与校验
- [ ] §4：用例图与 UC 要素；UC↔US
- [ ] §5：FR→US；GWT；含异常场景
- [ ] §6：业务域模块；映射 US
- [ ] §7：BR 汇总完整；互斥有策略
- [ ] §8：术语；状态与非法转换
- [ ] §9：仅本 MVP NFR；可度量或待澄清
- [ ] §10：AC 可测；NAC↔§9 或不适用
- [ ] §11：原型/变更史/§11.3

## 语言与一致

- [ ] 产品/业务表述为主；少散落成堆技术名词
- [ ] 与 ANALYSIS/SOLUTION 范围、MVP、目标无未解释冲突
- [ ] 与引用的 knowledge 矛盾则有盲区说明

## 可追溯与格式

- [ ] US→FR；UC↔US；BR 与 ANALYSIS 一致；AC/NAC、EX 可指回；编号连贯
- [ ] 文首 frontmatter 齐全；`id` 与路径一致
