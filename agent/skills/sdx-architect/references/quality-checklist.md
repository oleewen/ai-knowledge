# sdx-architect 质量检查

## 1) 结构

- [ ] `§1 设计概述`、`§2 架构设计`、`§3 需求规约`
- [ ] §1：目标、约束、关键决策（最小集）
- [ ] §2：边界、服务变更或交互至少一类
- [ ] §3：规约摘要表 + 下游入口指针
- [ ] 文末 YAML 元数据合法

## 2) 追溯

- [ ] 与 `PRD`、`ANALYSIS` 一致可追溯
- [ ] 无 DSD 展开：无实现级 API/DDL/规约全文塞进 ASD
- [ ] 术语与范围与上游一致

## 3) 命名与路径

- [ ] `ASD-{IDEA-ID}-{N}.md`；`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/`
- [ ] §3 路径可供 `sdx-design` 复用
- [ ] `{IDEA-ID}`、`{N}`、`{app-name}` 等占位已替换、风格一致

## 4) 门禁与校验

- [ ] 落盘前总确认或合法例外
- [ ] 已跑 `validate-asd.sh` 并处理失败项
