# DSD 质量验收（sdx-design）

## 1) 结构

- [ ] `§1 设计概述`、`§2 详细设计`、`§3 附录`
- [ ] `§1`：目标、约束、关键决策（最小集）
- [ ] `§2`：`§2.1-§2.5` 完整，且实现级契约集中在 `§2`
- [ ] `§3`：附录、自查与必要补充齐备
- [ ] 文首 frontmatter 合法

## 2) 追溯

- [ ] 与 `PRD`、`ASD`、`spec-asd` 一致可追溯
- [ ] `API/LOGIC/TBL` 编号与上游口径一致
- [ ] 无 DSD 外第二正文源
- [ ] 术语与范围与上游一致

## 3) 命名与路径

- [ ] `DSD-{IDEA-ID}-{N}.md`；`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/`
- [ ] `id`、`parent`、`architecture_ref` 与上游链路一致
- [ ] `{IDEA-ID}`、`{N}`、`{app-name}` 等占位已替换、风格一致

## 4) 当前段协议与校验

- [ ] 自动 grilling 已收敛后再停在 `C/M/G/F`
- [ ] 语义性改动已先确认，未越权直改
- [ ] 已跑 `validate-dsd.sh` 并处理失败项
