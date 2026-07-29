# sdx-test 质量验收

## 1) 结构

- [ ] `§1 概述`、`§2 测试用例`、`§3 测试数据`、`§4 测试环境`、`§5 测试进出标准`、`§6 附录`
- [ ] `§1`：目标、范围、策略（最小集）
- [ ] `§2`：功能、接口、业务规则、异常、回归至少覆盖当前变更需要的维度
- [ ] `§5`：进入/退出标准可检查、可度量
- [ ] 文首 frontmatter 合法

## 2) 追溯

- [ ] 与 `PRD`、`DSD`、`ASD` 一致可追溯
- [ ] `TC` 编号与 `US/BR/API/影响面` 对齐
- [ ] 回归范围与变更影响面一致
- [ ] 术语与范围与上游一致

## 3) 命名与路径

- [ ] `TDD-{IDEA-ID}-{N}.md`；`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/`
- [ ] `id`、`parent` 与上游链路一致
- [ ] `{IDEA-ID}`、`{N}` 等占位已替换、风格一致

## 4) 当前段协议与校验

- [ ] 自动 grilling 已收敛后再停在 `C/M/G/F`
- [ ] 已按 [audience-and-language.md](../../../references/audience-and-language.md) + 本地 [audience-and-language.md](audience-and-language.md) 通过烤干受众维 A/B/C/E
- [ ] 语义性改动已先确认，未越权直改
- [ ] 已跑 `validate-test.sh` 并处理失败项
