---
type: Change Log
title: 文档变更索引
---
# 文档变更索引

本文件由 **docs-change** 聚合 Git、`CHANGELOG*` 与本地 mtime 变更；增量基线见文末注释。

## 元信息

| 字段 | 值 |
|------|-----|
| 生成时间 | 2026-06-18 11:55:15.314 |
| 基线时间 | 2020-01-01 08:00:00.000 |
| 收录阈值 | 2026-06-18 11:53:31.000 |
| Git 仓库 | 是 |
| 变更总数 | 379 |

## 统计


- 总变更: 379
- Git: 379 · CHANGELOG: 0 · 本地: 0

### 2026-06-22 · rename
- **类型**: 命名统一
- **说明**: 三文档根 `docs_meta.md` → `docs-meta.md`；`naming-conventions.md` 修正为 `docs-meta.md`；`docs-install` 安装契约同步；OKF viz 再生。
- **文件**:
  - `application/docs-meta.md`（自 `docs_meta.md` 重命名）
  - `system/docs-meta.md`（自 `docs_meta.md` 重命名）
  - `company/docs-meta.md`（自 `docs_meta.md` 重命名）
  - `agent/knowledge/naming-conventions.md`
  - `scripts/docs-install.sh`
  - `scripts/okf/inject_frontmatter.py`
  - 各文档根 INDEX/DESIGN/README/index/manifest/knowledge-meta 引用
  - `application/viz.html`、`system/viz.html`、`company/viz.html`

### 2026-06-26 · chore
- **类型**: 脚本退役
- **说明**: 退役一次性命名迁移守护脚本 `scripts/check-docs-meta-naming.sh`（由 `a7feaac` 引入）。当前仓库零违规、迁移已彻底完成。**调整后范围**：仅删除脚本本体，保留测试套件 `scripts/tests/docs-meta-naming/` 与 `scripts/tests/run.sh` 中 `docs-meta-naming` 注册项；test case 改为 skip 行为以维持套件可调度。保留 `a7feaac` 迁移条目与 git rename 历史作为可追溯 SSOT。若未来再次出现命名迁移，按 `a7feaac` 同样的模式新建一份一次性检查器。
- **文件**:
  - `scripts/check-docs-meta-naming.sh`（删除）
  - `scripts/tests/docs-meta-naming/cases/01_clean_repo.sh`（改为 skip 占位）
  - `scripts/tests/docs-meta-naming/`（保留）
  - `scripts/tests/run.sh`（注册项保留）

## Git (379)

### 2026-06-18 11:53:31.000 · git
- **提交**: `d3605b5b62ee`
- **作者**: ouliyuan0129
- **信息**: docs(update): 添加从零落地指南并更新相关文档
- **文件**:
  - `AGENTS.md`
  - `README.md`
  - `application/DESIGN.md`
  - `company/DESIGN.md`
  - `company/ea/technical/technical-overview.md`
  - `docs/sharing/Harness工程实践：SSOT知识库+Skills链让AI交付可控.md`
  - `quick-start.md`
  - `system/DESIGN.md`
  - `system/architecture/README.md`
  - `system/architecture/application/README.md`
  - `system/architecture/application/application-adr.md`
  - `system/architecture/business/business-capability-map.md`
  - `system/architecture/data/README.md`
  - `system/architecture/data/data-analytics.md`
  - `system/architecture/overview/NAME-overview.md`
  - `system/architecture/technical/README.md`
  - `system/architecture/technical/technical-ha-and-dr.md`
  - `system/architecture/technical/technical-observability.md`
  - `system/architecture/technical/technical-overview.md`
  - `system/architecture/technical/technical-performance-scalability.md`

### 2026-06-17 17:02:47.000 · git
- **提交**: `260884d25ed9`
- **作者**: ouliyuan0129
- **信息**: docs(sharing): 完善 Harness 工程实践分享文档并更新 README
- **文件**:
  - `README.md`
  - `docs/sharing/Harness工程实践：SSOT知识库+Skills链让AI交付可控.md`
  - `docs/sharing/ai-knowledge-github-qr.png`

### 2026-06-16 08:50:43.000 · git
- **提交**: `e3bfdfde1d62`
- **作者**: ouliyuan0129
- **信息**: docs(update): 更新知识库文档以反映应用侧知识主库的结构与内容
- **文件**:
  - `index.md`
  - `README.md`
  - `agent/knowledge/naming-conventions.md`
  - `agent/skills/docs-pull/SKILL.md`
  - `application/DESIGN.md`
  - `application/index.md`
  - `application/README-c.md`
  - `application/README-s.md`
  - `application/README.md`
  - `application/analysis/README.md`
  - `application/knowledge/README.md`
  - `application/knowledge/application/README.md`
  - `application/knowledge/application/application-meta.md`
  - `application/knowledge/business/README.md`
  - `application/knowledge/business/business-meta.md`
  - `application/knowledge/data/README.md`
  - `application/knowledge/data/data-meta.md`
  - `application/knowledge/product/README.md`
  - `application/knowledge/product/product-meta.md`
  - `application/knowledge/technical/README.md`
  - `application/knowledge/technical/technical-meta.md`
  - `application/requirements/README.md`
  - `application/solutions/README.md`
  - `system/DESIGN.md`
  - `system/index.md`
  - `system/application-APPNAME/README.md`

### 2026-06-15 20:13:13.000 · git
- **提交**: `d4e2d4414ac6`
- **作者**: ouliyuan0129
- **信息**: docs(update): 更新知识库与设计文档以反映五视角结构
- **文件**:
  - `agent/knowledge/glossary.md`
  - `application/DESIGN.md`
  - `application/index.md`
  - `application/README-c.md`
  - `application/README-s.md`
  - `application/analysis/README.md`
  - `application/docs_meta.yaml`
  - `application/knowledge/README.md`
  - `application/knowledge/business/README.md`
  - `application/solutions/README.md`

### 2026-06-15 20:04:33.000 · git
- **提交**: `f893119f8d8b`
- **作者**: ouliyuan0129
- **信息**: docs(update): 更新索引指南与会话 spec 路径契约以提升一致性与清晰度
- **文件**:
  - `index.md`
  - `agent/hooks/sdx_gate_common.py`
  - `agent/hooks/session_spec_paths.py`
  - `agent/hooks/tests/test_sdx_gate_common.py`
  - `agent/hooks/tests/test_session_spec_paths.py`
  - `agent/references/session-spec-path.md`
  - `agent/rules/CONVENTIONS.md`
  - `agent/skills/docs-indexing/references/gates.md`
  - `company/DESIGN.md`
  - `company/README.md`
  - `company/analysis/README.md`
  - `company/system-SYSNAME/README.md`
  - `system/DESIGN.md`
  - `system/index.md`
  - `system/README.md`
  - `system/application-APPNAME/README.md`
  - `system/architecture/application/application-adr.md`
  - `system/architecture/application/application-domain-capability.md`
  - `system/architecture/application/application-domain-model.md`
  - `system/architecture/application/application-integration.md`
  - `system/architecture/application/application-inter-service.md`
  - `system/architecture/application/application-interface-management.md`
  - `system/architecture/application/application-multi-tenant-environment.md`
  - `system/architecture/application/application-service-design.md`
  - `system/architecture/business/business-glossary.md`
  - `system/architecture/business/business-processes.md`
  - `system/architecture/business/business-rules-and-strategies.md`
  - `system/architecture/data/data-analytics.md`
  - `system/architecture/data/data-flow.md`
  - `system/architecture/data/data-model.md`
  - … 另有 10 个文件

### 2026-06-15 19:36:45.000 · git
- **提交**: `e85b334f6a97`
- **作者**: ouliyuan0129
- **信息**: docs(update): 更新设计文档与结构以提升一致性与清晰度
- **文件**:
  - `company/DESIGN.md`
  - `company/README.md`
  - `company/analysis/README.md`
  - `company/ea/README.md`

### 2026-06-15 19:29:33.000 · git
- **提交**: `3a5306b6a2a7`
- **作者**: ouliyuan0129
- **信息**: docs(knowledge-update): 更新知识库结构与文档以支持新视角与治理规范
- **文件**:
  - `AGENTS.md`
  - `index.md`
  - `README.md`
  - `agent/README.md`
  - `agent/hooks/sdx_gate_common.py`
  - `agent/hooks/tests/test_sdx_gate_common.py`
  - `agent/knowledge/README.md`
  - `agent/knowledge/adr-guidelines.md`
  - `agent/knowledge/adr-template.md`
  - `agent/knowledge/architecture-principles.md`
  - `agent/knowledge/glossary.md`
  - `agent/knowledge/knowledge-governance.md`
  - `agent/knowledge/naming-conventions.md`
  - `agent/references/knowledge-layout.md`
  - `agent/rules/CONVENTIONS.md`
  - `agent/skills/README.md`
  - `agent/skills/docs-agent/assets/agents-skeleton.md`
  - `agent/skills/docs-archive/SKILL.md`
  - `agent/skills/docs-archive/evals/evals.json`
  - `agent/skills/docs-archive/references/core-concepts.md`
  - `agent/skills/docs-archive/references/gates.md`
  - `agent/skills/docs-build/SKILL.md`
  - `agent/skills/docs-build/assets/docs-build-session-spec-template.md`
  - `agent/skills/docs-build/assets/knowledge-index-template.md`
  - `agent/skills/docs-build/assets/knowledge-schema-template.json`
  - `agent/skills/docs-build/gotchas.md`
  - `agent/skills/docs-build/references/builtin-config.md`
  - `agent/skills/docs-build/references/consolidation-spec.md`
  - `agent/skills/docs-build/references/core-concepts.md`
  - `agent/skills/docs-build/references/extraction-rules.md`
  - … 另有 160 个文件

### 2026-06-15 18:04:12.000 · git
- **提交**: `07ff956f644c`
- **作者**: ouliyuan0129
- **信息**: docs(architecture-update): 更新公司架构文档以提升一致性与清晰度
- **文件**:
  - `README.md`
  - `company/DESIGN.md`
  - `company/README.md`
  - `company/architecture/README.md`
  - `company/architecture/application/README.md`
  - `company/architecture/application/application-adr.md`
  - `company/architecture/application/application-architecture.md`
  - `company/architecture/application/application-domain-capability.md`
  - `company/architecture/application/application-domain-model.md`
  - `company/architecture/application/application-integration.md`
  - `company/architecture/application/application-inter-service.md`
  - `company/architecture/application/application-interface-management.md`
  - `company/architecture/application/application-multi-tenant-environment.md`
  - `company/architecture/application/application-service-design.md`
  - `company/architecture/business/README.md`
  - `company/architecture/business/business-capability.md`
  - `company/architecture/business/business-glossary.md`
  - `company/architecture/business/business-model.md`
  - `company/architecture/business/business-processes.md`
  - `company/architecture/business/business-rules-and-strategies.md`
  - `company/architecture/business/business-value-chain.md`
  - `company/architecture/data/README.md`
  - `company/architecture/data/data-analytics.md`
  - `company/architecture/data/data-flow.md`
  - `company/architecture/data/data-model.md`
  - `company/architecture/data/data-storage.md`
  - `company/architecture/overview/NAME-overview.md`
  - `company/architecture/product/README.md`
  - `company/architecture/product/product-feature.md`
  - `company/architecture/product/product-information-architecture.md`
  - … 另有 29 个文件

### 2026-06-15 15:58:44.000 · git
- **提交**: `b8cca23e14a1`
- **作者**: ouliyuan0129
- **信息**: docs(sharing): 更新 AI 知识库分享文档以提升内容清晰度与一致性
- **文件**:
  - `docs/sharing/用企业AI知识库底座，激活组织知识-slides.md`
  - `docs/sharing/用企业AI知识库底座，激活组织知识.md`

### 2026-06-15 15:58:26.000 · git
- **提交**: `99aba07cd8a9`
- **作者**: ouliyuan0129
- **信息**: docs(architecture-update): 更新架构文档以统一标准与结构
- **文件**:
  - `agent/skills/docs-archive/references/core-concepts.md`
  - `agent/skills/docs-distill/gotchas.md`
  - `agent/skills/docs-distill/references/federation-spec.md`
  - `agent/skills/docs-extract/references/extract-spec.md`
  - `company/architecture/ARCHITECTURE-OVERVIEW.md`
  - `company/architecture/README.md`
  - `company/architecture/application/README.md`
  - `company/architecture/application/application-adr.md`
  - `company/architecture/application/application-architecture.md`
  - `company/architecture/application/application-domain-capability.md`
  - `company/architecture/application/application-domain-model.md`
  - `company/architecture/application/application-integration.md`
  - `company/architecture/application/application-inter-service.md`
  - `company/architecture/application/application-interface-management.md`
  - `company/architecture/application/application-landscape.md`
  - `company/architecture/application/application-multi-tenant-environment.md`
  - `company/architecture/application/application-overview.md`
  - `company/architecture/application/application-service-design.md`
  - `company/architecture/business/README.md`
  - `company/architecture/business/business-capability-map.md`
  - `company/architecture/business/business-domain-division.md`
  - `company/architecture/business/business-domain.md`
  - `company/architecture/business/business-glossary.md`
  - `company/architecture/business/business-model-and-value-chain.md`
  - `company/architecture/business/business-overview.md`
  - `company/architecture/business/business-processes.md`
  - `company/architecture/business/business-roles-and-organization.md`
  - `company/architecture/business/business-rules-and-strategies.md`
  - `company/architecture/data/README.md`
  - `company/architecture/data/data-analytics.md`
  - … 另有 84 个文件

### 2026-06-13 18:41:59.000 · git
- **提交**: `5f2a13de4c16`
- **作者**: ouliyuan0129
- **信息**: docs(sharing): 新增企业 AI 知识库分享文档及相关资源
- **文件**:
  - `README.md`
  - `docs/getting-started.md`
  - `docs/sharing/41417a6d6246306f23a7d2da07fd9045.jpg`
  - `docs/sharing/rebate-image.png`
  - `docs/sharing/spec-image.png`
  - `docs/sharing/vas-image.png`
  - `docs/sharing/用企业AI知识库底座，激活组织知识-slides.md`
  - `docs/sharing/用企业AI知识库底座，激活组织知识.md`

### 2026-06-12 17:06:42.000 · git
- **提交**: `d2912781c8a3`
- **作者**: ouliyuan0129
- **信息**: docs(readme-cleanup): 移除 README.md 中的生成信息以简化内容
- **文件**:
  - `README.md`

### 2026-06-12 17:05:35.000 · git
- **提交**: `f1c38dc286b9`
- **作者**: ouliyuan0129
- **信息**: docs(readme-update): 清理 README.md 中的文档链接
- **文件**:
  - `README.md`

### 2026-06-12 16:58:44.000 · git
- **提交**: `6bc96bcce30f`
- **作者**: ouliyuan0129
- **信息**: docs(spec-path-update): 更新会话 spec 路径契约以支持新结构
- **文件**:
  - `AGENTS.md`
  - `README.md`
  - `agent/hooks/README.md`
  - `agent/hooks/sdx_gate_common.py`
  - `agent/hooks/session_spec_paths.py`
  - `agent/hooks/tests/test_sdx_gate_common.py`
  - `agent/hooks/tests/test_session_spec_paths.py`
  - `agent/references/session-spec-path.md`
  - `agent/rules/CONVENTIONS.md`
  - `agent/scripts/check-session-spec-gate.sh`
  - `agent/skills/README.md`
  - `agent/skills/docs-agent/references/gates.md`
  - `agent/skills/docs-archive/SKILL.md`
  - `agent/skills/docs-archive/assets/archive-template.md`
  - `agent/skills/docs-archive/assets/docs-archive-session-spec-template.md`
  - `agent/skills/docs-archive/evals/eval-metadata-template.json`
  - `agent/skills/docs-archive/references/brainstorming-integration.md`
  - `agent/skills/docs-archive/references/gates.md`
  - `agent/skills/docs-build/SKILL.md`
  - `agent/skills/docs-build/assets/docs-build-session-spec-template.md`
  - `agent/skills/docs-build/references/brainstorming-integration.md`
  - `agent/skills/docs-build/references/gates.md`
  - `agent/skills/docs-build/references/interaction-gate.md`
  - `agent/skills/docs-change/references/gates.md`
  - `agent/skills/docs-distill/SKILL.md`
  - `agent/skills/docs-distill/assets/docs-distill-session-spec-template.md`
  - `agent/skills/docs-distill/references/brainstorming-integration.md`
  - `agent/skills/docs-distill/references/gates.md`
  - `agent/skills/docs-distill/references/interaction-gate.md`
  - `agent/skills/docs-extract/SKILL.md`
  - … 另有 54 个文件

### 2026-06-12 09:06:22.000 · git
- **提交**: `4d6203ef6d4c`
- **作者**: ouliyuan0129
- **信息**: docs(application-knowledge-update): 更新应用知识库结构与文档以支持新视角
- **文件**:
  - `AGENTS.md`
  - `index.md`
  - `README.md`
  - `agent/hooks/tests/test_sdx_gate_common.py`
  - `agent/skills/README.md`
  - `agent/skills/docs-build/SKILL.md`
  - `agent/skills/docs-build/assets/docs-build-session-spec-template.md`
  - `agent/skills/docs-build/assets/knowledge-schema-template.json`
  - `agent/skills/docs-build/evals/evals.json`
  - `agent/skills/docs-build/references/builtin-config.md`
  - `agent/skills/docs-build/references/consolidation-spec.md`
  - `agent/skills/docs-build/references/core-concepts.md`
  - `agent/skills/docs-build/references/extraction-rules.md`
  - `agent/skills/docs-build/references/readme-fill-spec.md`
  - `agent/skills/docs-build/references/workflow.md`
  - `agent/skills/docs-build/scripts/validate-extraction.sh`
  - `application/DESIGN.md`
  - `application/index.md`
  - `application/README-s.md`
  - `application/analysis/README.md`
  - `application/constitution/GLOSSARY.md`
  - `application/constitution/constitution_meta.yaml`
  - `application/constitution/standards/naming-conventions.md`
  - `application/docs_meta.yaml`
  - `application/knowledge/index.md`
  - `application/knowledge/README.md`
  - `application/knowledge/application/README.md`
  - `application/knowledge/application/application_knowledge.json`
  - `application/knowledge/application/application_meta.yaml`
  - `application/knowledge/business/README.md`
  - … 另有 13 个文件

### 2026-06-02 11:07:30.000 · git
- **提交**: `45ca68db248d`
- **作者**: ouliyuan0129
- **信息**: docs(session-spec-path-update): 更新会话 spec 路径契约以支持新结构
- **文件**:
  - `.gitignore`
  - `AGENTS.md`
  - `agent/hooks/README.md`
  - `agent/hooks/sdx_gate_common.py`
  - `agent/hooks/session_spec_paths.py`
  - `agent/hooks/tests/test_sdx_gate_common.py`
  - `agent/hooks/tests/test_session_spec_paths.py`
  - `agent/references/session-spec-path.md`
  - `agent/rules/CONVENTIONS.md`
  - `agent/scripts/check-session-spec-gate.sh`
  - `agent/skills/README.md`
  - `agent/skills/docs-agent/references/gates.md`
  - `agent/skills/docs-archive/SKILL.md`
  - `agent/skills/docs-archive/assets/archive-template.md`
  - `agent/skills/docs-archive/assets/docs-archive-session-spec-template.md`
  - `agent/skills/docs-archive/evals/eval-metadata-template.json`
  - `agent/skills/docs-archive/references/brainstorming-integration.md`
  - `agent/skills/docs-archive/references/gates.md`
  - `agent/skills/docs-build/SKILL.md`
  - `agent/skills/docs-build/assets/docs-build-session-spec-template.md`
  - `agent/skills/docs-build/references/brainstorming-integration.md`
  - `agent/skills/docs-build/references/gates.md`
  - `agent/skills/docs-build/references/interaction-gate.md`
  - `agent/skills/docs-change/references/gates.md`
  - `agent/skills/docs-distill/SKILL.md`
  - `agent/skills/docs-distill/assets/docs-distill-session-spec-template.md`
  - `agent/skills/docs-distill/references/brainstorming-integration.md`
  - `agent/skills/docs-distill/references/gates.md`
  - `agent/skills/docs-distill/references/interaction-gate.md`
  - `agent/skills/docs-extract/SKILL.md`
  - … 另有 50 个文件

### 2026-06-02 10:53:37.000 · git
- **提交**: `e215679301a7`
- **作者**: ouliyuan0129
- **信息**: docs(session-spec-path-update): 更新会话 spec 路径契约以支持新结构
- **文件**:
  - `AGENTS.md`
  - `agent/hooks/README.md`
  - `agent/hooks/sdx_gate_common.py`
  - `agent/hooks/session_spec_paths.py`
  - `agent/hooks/tests/test_sdx_gate_common.py`
  - `agent/hooks/tests/test_session_spec_paths.py`
  - `agent/references/session-spec-path.md`
  - `agent/rules/CONVENTIONS.md`
  - `agent/scripts/check-session-spec-gate.sh`
  - `agent/skills/README.md`
  - `agent/skills/docs-agent/references/gates.md`
  - `agent/skills/docs-archive/SKILL.md`
  - `agent/skills/docs-archive/assets/archive-template.md`
  - `agent/skills/docs-archive/assets/docs-archive-session-spec-template.md`
  - `agent/skills/docs-archive/evals/eval-metadata-template.json`
  - `agent/skills/docs-archive/references/brainstorming-integration.md`
  - `agent/skills/docs-archive/references/gates.md`
  - `agent/skills/docs-build/SKILL.md`
  - `agent/skills/docs-build/assets/docs-build-session-spec-template.md`
  - `agent/skills/docs-build/references/brainstorming-integration.md`
  - `agent/skills/docs-build/references/gates.md`
  - `agent/skills/docs-build/references/interaction-gate.md`
  - `agent/skills/docs-change/references/gates.md`
  - `agent/skills/docs-distill/SKILL.md`
  - `agent/skills/docs-distill/assets/docs-distill-session-spec-template.md`
  - `agent/skills/docs-distill/references/brainstorming-integration.md`
  - `agent/skills/docs-distill/references/gates.md`
  - `agent/skills/docs-distill/references/interaction-gate.md`
  - `agent/skills/docs-extract/SKILL.md`
  - `agent/skills/docs-extract/assets/docs-extract-session-spec-template.md`
  - … 另有 49 个文件

### 2026-05-29 14:48:02.000 · git
- **提交**: `b0617d21660d`
- **作者**: ouliyuan0129
- **信息**: docs(structure-update): 重构文档结构以提升一致性与可读性
- **文件**:
  - `application/DESIGN.md`
  - `application/README-c.md`
  - `application/README-s.md`
  - `application/analysis/README.md`
  - `application/analysis/analysis_meta.yaml`
  - `application/constitution/standards/naming-conventions.md`
  - `application/docs_meta.yaml`
  - `application/knowledge/knowledge_meta.yaml`
  - `application/manifest.yaml`
  - `application/requirements/README.md`
  - `application/requirements/requirements_meta.yaml`
  - `application/solutions/README.md`
  - `company/analysis/README.md`
  - `company/analysis/analysis_meta.yaml`
  - `company/changelogs/CHANGE-LOG.md`
  - `company/changelogs/INDEXING-LOG.md`
  - `company/changelogs/README.md`
  - `company/changelogs/changelogs_meta.yaml`
  - `company/requirements/README.md`
  - `company/requirements/REQUIREMENT-EXAMPLE/README.md`
  - `company/solutions/README.md`
  - `company/solutions/solutions_meta.yaml`
  - `system/index.md`
  - `system/analysis/README.md`
  - `system/analysis/analysis_meta.yaml`
  - `system/changelogs/README.md`
  - `system/changelogs/changelogs_meta.yaml`
  - `system/docs_meta.yaml`
  - `system/requirements/README.md`
  - `system/requirements/requirements_meta.yaml`
  - … 另有 2 个文件

### 2026-05-22 17:14:10.000 · git
- **提交**: `a4a54470ef9f`
- **作者**: ouliyuan0129
- **信息**: docs(template-update): 更新需求与设计文档模板以提升一致性与可读性
- **文件**:
  - `agent/skills/sdx-analysis/assets/analysis-template.md`
  - `agent/skills/sdx-architect/assets/asd-template.md`
  - `agent/skills/sdx-design/assets/dsd-template.md`
  - `agent/skills/sdx-prd/assets/prd-template.md`
  - `agent/skills/sdx-solution/assets/solution-template.md`

### 2026-05-20 14:09:33.000 · git
- **提交**: `7f79cd1d88f3`
- **作者**: ouliyuan0129
- **信息**: docs(docs-tag): 增强关键词标记功能与架构摘录支持
- **文件**:
  - `agent/skills/README.md`
  - `agent/skills/docs-tag/SKILL.md`
  - `agent/skills/docs-tag/evals/evals.json`
  - `agent/skills/docs-tag/gotchas.md`
  - `agent/skills/docs-tag/references/gates.md`
  - `agent/skills/docs-tag/references/workflow.md`
  - `agent/skills/docs-tag/scripts/keyword_tag.py`
  - `agent/skills/docs-tag/tests/test_phase3.py`
  - `agent/skills/docs-tag/tests/test_unit.py`
  - `system/architecture/overview/NAME-overview.md`

### 2026-05-20 10:11:44.000 · git
- **提交**: `2c92be6f6f76`
- **作者**: ouliyuan0129
- **信息**: docs(architecture-overview): 增加架构摘录以提升文档结构与可读性
- **文件**:
  - `system/architecture/overview/NAME-overview.md`

### 2026-05-18 17:41:50.000 · git
- **提交**: `12c6b5a39bc3`
- **作者**: ouliyuan0129
- **信息**: docs(session-spec-path): 更新会话 spec 路径契约与相关文档
- **文件**:
  - `AGENTS.md`
  - `index.md`
  - `agent/hooks/README.md`
  - `agent/hooks/sdx_gate_common.py`
  - `agent/hooks/sdx_session_gate.py`
  - `agent/hooks/sdx_session_state.py`
  - `agent/hooks/session_spec_paths.py`
  - `agent/hooks/tests/test_sdx_gate_common.py`
  - `agent/hooks/tests/test_session_spec_paths.py`
  - `agent/references/session-spec-path.md`
  - `agent/rules/CONVENTIONS.md`
  - `agent/scripts/check-session-spec-gate.sh`
  - `agent/skills/README.md`
  - `agent/skills/docs-agent/references/gates.md`
  - `agent/skills/docs-archive/SKILL.md`
  - `agent/skills/docs-archive/assets/archive-template.md`
  - `agent/skills/docs-archive/assets/docs-archive-session-spec-template.md`
  - `agent/skills/docs-archive/evals/eval-metadata-template.json`
  - `agent/skills/docs-archive/references/brainstorming-integration.md`
  - `agent/skills/docs-archive/references/gates.md`
  - `agent/skills/docs-build/SKILL.md`
  - `agent/skills/docs-build/assets/docs-build-session-spec-template.md`
  - `agent/skills/docs-build/references/brainstorming-integration.md`
  - `agent/skills/docs-build/references/gates.md`
  - `agent/skills/docs-build/references/interaction-gate.md`
  - `agent/skills/docs-change/references/gates.md`
  - `agent/skills/docs-distill/SKILL.md`
  - `agent/skills/docs-distill/assets/docs-distill-session-spec-template.md`
  - `agent/skills/docs-distill/references/brainstorming-integration.md`
  - `agent/skills/docs-distill/references/gates.md`
  - … 另有 66 个文件

### 2026-05-13 14:13:17.000 · git
- **提交**: `d0a83a331d07`
- **作者**: ouliyuan0129
- **信息**: docs(dsd-template-update): 更新设计文档以提升一致性与可读性
- **文件**:
  - `agent/skills/sdx-design/assets/dsd-template.md`
  - `scripts/docs-install.sh`

### 2026-05-09 17:29:53.000 · git
- **提交**: `9d5506bdf54c`
- **作者**: ouliyuan0129
- **信息**: docs(docs-update): 更新文档以提升一致性与可读性
- **文件**:
  - `README.md`
  - `agent/skills/README.md`
  - `agent/skills/docs-push/SKILL.md`
  - `agent/skills/docs-push/references/parameters.md`
  - `agent/skills/sdx-architect/SKILL.md`
  - `agent/skills/sdx-architect/assets/asd-spec-template.md`
  - `agent/skills/sdx-architect/assets/asd-stub-sections-federated.md`
  - `agent/skills/sdx-architect/assets/asd-template.md`
  - `agent/skills/sdx-architect/evals/evals.json`
  - `agent/skills/sdx-architect/references/knowledge-type-modes.md`
  - `agent/skills/sdx-design/SKILL.md`
  - `agent/skills/sdx-design/agents/analyzer.md`
  - `agent/skills/sdx-design/agents/grader.md`
  - `agent/skills/sdx-design/assets/design-session-spec-template.md`
  - `agent/skills/sdx-design/assets/dsd-spec-template.md`
  - `agent/skills/sdx-design/assets/dsd-template.md`
  - `agent/skills/sdx-design/evals/eval-metadata-template.json`
  - `agent/skills/sdx-design/evals/evals.json`
  - `agent/skills/sdx-design/gotchas.md`
  - `agent/skills/sdx-design/references/README.md`
  - `agent/skills/sdx-design/references/anti-patterns.md`
  - `agent/skills/sdx-design/references/audience-and-language.md`
  - `agent/skills/sdx-design/references/brainstorming-integration.md`
  - `agent/skills/sdx-design/references/design-principles.md`
  - `agent/skills/sdx-design/references/gates.md`
  - `agent/skills/sdx-design/references/knowledge-type-modes.md`
  - `agent/skills/sdx-design/references/quality-checklist.md`
  - `agent/skills/sdx-design/references/workflow.md`
  - `agent/skills/sdx-design/scripts/validate-dsd.sh`
  - `application/DESIGN.md`
  - … 另有 2 个文件

### 2026-05-09 16:46:36.000 · git
- **提交**: `dba6473f5f90`
- **作者**: ouliyuan0129
- **信息**: docs(docs-update): 更新文档以提升一致性与可读性
- **文件**:
  - `agent/skills/docs-upgrade/SKILL.md`
  - `agent/skills/docs-upgrade/agents/analyzer.md`
  - `agent/skills/docs-upgrade/agents/grader.md`
  - `agent/skills/docs-upgrade/agents/openai.yaml`
  - `agent/skills/docs-upgrade/assets/docs-upgrade-scope-ack-template.md`
  - `agent/skills/docs-upgrade/evals/eval-metadata-template.json`
  - `agent/skills/docs-upgrade/evals/evals.json`
  - `agent/skills/docs-upgrade/gotchas.md`
  - `agent/skills/docs-upgrade/references/README.md`
  - `agent/skills/docs-upgrade/references/anti-patterns.md`
  - `agent/skills/docs-upgrade/references/brainstorming-integration.md`
  - `agent/skills/docs-upgrade/references/core-concepts.md`
  - `agent/skills/docs-upgrade/references/design-principles.md`
  - `agent/skills/docs-upgrade/references/gates.md`
  - `agent/skills/docs-upgrade/references/quality-checklist.md`
  - `agent/skills/docs-upgrade/references/related-doc-discovery.md`
  - `agent/skills/docs-upgrade/references/semantic-keyword-discovery.md`
  - `agent/skills/docs-upgrade/references/workflow.md`

### 2026-05-09 16:46:23.000 · git
- **提交**: `c4405b464458`
- **作者**: ouliyuan0129
- **信息**: docs(docs-tag): 更新文档以提升一致性与可读性
- **文件**:
  - `agent/skills/docs-tag/SKILL.md`
  - `agent/skills/docs-tag/agents/analyzer.md`
  - `agent/skills/docs-tag/agents/grader.md`
  - `agent/skills/docs-tag/evals/eval-metadata-template.json`
  - `agent/skills/docs-tag/evals/evals.json`
  - `agent/skills/docs-tag/gotchas.md`
  - `agent/skills/docs-tag/references/algorithm.md`
  - `agent/skills/docs-tag/references/gates.md`
  - `agent/skills/docs-tag/references/workflow.md`
  - `agent/skills/docs-tag/scripts/keyword_tag.py`
  - `agent/skills/docs-tag/tests/test_integration.py`
  - `agent/skills/docs-tag/tests/test_properties.py`
  - `agent/skills/docs-tag/tests/test_unit.py`

### 2026-05-09 16:45:49.000 · git
- **提交**: `5545aa42e13a`
- **作者**: ouliyuan0129
- **信息**: docs(docs-push): 更新文档以提升一致性与可读性
- **文件**:
  - `agent/skills/docs-push/SKILL.md`
  - `agent/skills/docs-push/evals/evals.json`
  - `agent/skills/docs-push/gotchas.md`
  - `agent/skills/docs-push/references/README.md`
  - `agent/skills/docs-push/references/gates.md`
  - `agent/skills/docs-push/references/parameters.md`
  - `agent/skills/docs-push/references/workflow.md`
  - `agent/skills/docs-push/scripts/push-specs.sh`

### 2026-05-09 16:44:57.000 · git
- **提交**: `e6df2c1cbe0f`
- **作者**: ouliyuan0129
- **信息**: docs(docs-pull): 更新文档以提升一致性与可读性
- **文件**:
  - `agent/skills/docs-pull/SKILL.md`
  - `agent/skills/docs-pull/agents/analyzer.md`
  - `agent/skills/docs-pull/agents/grader.md`
  - `agent/skills/docs-pull/assets/docs-pull-run-checklist.md`
  - `agent/skills/docs-pull/assets/pull-log-template.md`
  - `agent/skills/docs-pull/evals/eval-metadata-template.json`
  - `agent/skills/docs-pull/evals/evals.json`
  - `agent/skills/docs-pull/gotchas.md`
  - `agent/skills/docs-pull/references/README.md`
  - `agent/skills/docs-pull/references/anti-patterns.md`
  - `agent/skills/docs-pull/references/brainstorming-integration.md`
  - `agent/skills/docs-pull/references/core-concepts.md`
  - `agent/skills/docs-pull/references/design-principles.md`
  - `agent/skills/docs-pull/references/gates.md`
  - `agent/skills/docs-pull/references/manifest-spec.md`
  - `agent/skills/docs-pull/references/quality-checklist.md`
  - `agent/skills/docs-pull/references/workflow.md`
  - `agent/skills/docs-pull/scripts/pull-docs.sh`

### 2026-05-09 16:44:48.000 · git
- **提交**: `de89f50eaa3a`
- **作者**: ouliyuan0129
- **信息**: docs(docs-indexing): 更新文档以提升一致性与可读性
- **文件**:
  - `agent/skills/docs-indexing/SKILL.md`
  - `agent/skills/docs-indexing/agents/analyzer.md`
  - `agent/skills/docs-indexing/agents/grader.md`
  - `agent/skills/docs-indexing/assets/docs-indexing-session-spec-template.md`
  - `agent/skills/docs-indexing/assets/index-guide-template.md`
  - `agent/skills/docs-indexing/evals/eval-metadata-template.json`
  - `agent/skills/docs-indexing/evals/evals.json`
  - `agent/skills/docs-indexing/gotchas.md`
  - `agent/skills/docs-indexing/references/README.md`
  - `agent/skills/docs-indexing/references/anti-patterns.md`
  - `agent/skills/docs-indexing/references/brainstorming-integration.md`
  - `agent/skills/docs-indexing/references/gates.md`
  - `agent/skills/docs-indexing/references/indexing-log-spec.md`
  - `agent/skills/docs-indexing/references/interaction-gate.md`
  - `agent/skills/docs-indexing/references/nine-chapter-spec.md`
  - `agent/skills/docs-indexing/references/quality-standards.md`
  - `agent/skills/docs-indexing/references/scan-config-onboarding.md`
  - `agent/skills/docs-indexing/references/scan-spec.md`
  - `agent/skills/docs-indexing/references/workflow.md`
  - `agent/skills/docs-indexing/scripts/indexing.sh`
  - `agent/skills/docs-indexing/scripts/indexing_log.py`

### 2026-05-09 16:44:27.000 · git
- **提交**: `e0e41a0677a2`
- **作者**: ouliyuan0129
- **信息**: docs(docs-extract): 精简与更新文档以提升一致性与可读性
- **文件**:
  - `agent/skills/docs-extract/SKILL.md`
  - `agent/skills/docs-extract/agents/analyzer.md`
  - `agent/skills/docs-extract/agents/grader.md`
  - `agent/skills/docs-extract/assets/docs-extract-session-spec-template.md`
  - `agent/skills/docs-extract/evals/eval-metadata-template.json`
  - `agent/skills/docs-extract/evals/evals.json`
  - `agent/skills/docs-extract/gotchas.md`
  - `agent/skills/docs-extract/references/README.md`
  - `agent/skills/docs-extract/references/anti-patterns.md`
  - `agent/skills/docs-extract/references/brainstorming-integration.md`
  - `agent/skills/docs-extract/references/core-concepts.md`
  - `agent/skills/docs-extract/references/design-principles.md`
  - `agent/skills/docs-extract/references/extract-spec.md`
  - `agent/skills/docs-extract/references/gates.md`
  - `agent/skills/docs-extract/references/interaction-gate.md`
  - `agent/skills/docs-extract/references/quality-checklist.md`
  - `agent/skills/docs-extract/references/workflow.md`

### 2026-05-09 16:43:49.000 · git
- **提交**: `6d2b6b52ceb9`
- **作者**: ouliyuan0129
- **信息**: docs(docs-distill): 更新文档以提升清晰度与一致性
- **文件**:
  - `agent/skills/docs-distill/SKILL.md`
  - `agent/skills/docs-distill/agents/analyzer.md`
  - `agent/skills/docs-distill/agents/grader.md`
  - `agent/skills/docs-distill/assets/docs-distill-session-spec-template.md`
  - `agent/skills/docs-distill/evals/eval-metadata-template.json`
  - `agent/skills/docs-distill/evals/evals.json`
  - `agent/skills/docs-distill/gotchas.md`
  - `agent/skills/docs-distill/references/README.md`
  - `agent/skills/docs-distill/references/anti-patterns.md`
  - `agent/skills/docs-distill/references/brainstorming-integration.md`
  - `agent/skills/docs-distill/references/core-concepts.md`
  - `agent/skills/docs-distill/references/design-principles.md`
  - `agent/skills/docs-distill/references/distill-log-spec.md`
  - `agent/skills/docs-distill/references/distill-spec.md`
  - `agent/skills/docs-distill/references/federation-spec.md`
  - `agent/skills/docs-distill/references/gates.md`
  - `agent/skills/docs-distill/references/interaction-gate.md`
  - `agent/skills/docs-distill/references/quality-checklist.md`
  - `agent/skills/docs-distill/references/workflow.md`
  - `agent/skills/docs-distill/scripts/append-change-log.sh`
  - `agent/skills/docs-distill/scripts/run-docs-distill.sh`

### 2026-05-09 16:43:20.000 · git
- **提交**: `ad8e20b438b3`
- **作者**: ouliyuan0129
- **信息**: docs(docs-change): 更新文档以提升清晰度与一致性
- **文件**:
  - `agent/skills/docs-change/SKILL.md`
  - `agent/skills/docs-change/agents/analyzer.md`
  - `agent/skills/docs-change/agents/grader.md`
  - `agent/skills/docs-change/assets/changes-index-template.md`
  - `agent/skills/docs-change/evals/eval-metadata-template.json`
  - `agent/skills/docs-change/evals/evals.json`
  - `agent/skills/docs-change/gotchas.md`
  - `agent/skills/docs-change/references/README.md`
  - `agent/skills/docs-change/references/anti-patterns.md`
  - `agent/skills/docs-change/references/collection-rules.md`
  - `agent/skills/docs-change/references/core-concepts.md`
  - `agent/skills/docs-change/references/design-principles.md`
  - `agent/skills/docs-change/references/gates.md`
  - `agent/skills/docs-change/references/quality-checklist.md`
  - `agent/skills/docs-change/references/workflow.md`
  - `agent/skills/docs-change/scripts/change-indexing.sh`

### 2026-05-09 16:42:13.000 · git
- **提交**: `121b9bfc214b`
- **作者**: ouliyuan0129
- **信息**: docs(docs-build): 更新文档以提升清晰度与一致性
- **文件**:
  - `agent/skills/docs-build/SKILL.md`
  - `agent/skills/docs-build/agents/analyzer.md`
  - `agent/skills/docs-build/agents/grader.md`
  - `agent/skills/docs-build/assets/docs-build-session-spec-template.md`
  - `agent/skills/docs-build/assets/knowledge-index-template.md`
  - `agent/skills/docs-build/assets/knowledge-schema-template.json`
  - `agent/skills/docs-build/evals/eval-metadata-template.json`
  - `agent/skills/docs-build/evals/evals.json`
  - `agent/skills/docs-build/gotchas.md`
  - `agent/skills/docs-build/references/README.md`
  - `agent/skills/docs-build/references/anti-patterns.md`
  - `agent/skills/docs-build/references/brainstorming-integration.md`
  - `agent/skills/docs-build/references/builtin-config.md`
  - `agent/skills/docs-build/references/consolidation-spec.md`
  - `agent/skills/docs-build/references/core-concepts.md`
  - `agent/skills/docs-build/references/design-principles.md`
  - `agent/skills/docs-build/references/extraction-rules.md`
  - `agent/skills/docs-build/references/gates.md`
  - `agent/skills/docs-build/references/interaction-gate.md`
  - `agent/skills/docs-build/references/quality-checklist.md`
  - `agent/skills/docs-build/references/readme-fill-spec.md`
  - `agent/skills/docs-build/references/workflow.md`
  - `agent/skills/docs-build/scripts/validate-extraction.sh`

### 2026-05-09 16:41:03.000 · git
- **提交**: `cdce1755bfde`
- **作者**: ouliyuan0129
- **信息**: docs(docs-archive): 更新文档以提升清晰度与一致性
- **文件**:
  - `agent/skills/docs-archive/SKILL.md`
  - `agent/skills/docs-archive/agents/analyzer.md`
  - `agent/skills/docs-archive/agents/grader.md`
  - `agent/skills/docs-archive/assets/archive-template.md`
  - `agent/skills/docs-archive/assets/docs-archive-session-spec-template.md`
  - `agent/skills/docs-archive/evals/eval-metadata-template.json`
  - `agent/skills/docs-archive/evals/evals.json`
  - `agent/skills/docs-archive/gotchas.md`
  - `agent/skills/docs-archive/references/README.md`
  - `agent/skills/docs-archive/references/anti-patterns.md`
  - `agent/skills/docs-archive/references/brainstorming-integration.md`
  - `agent/skills/docs-archive/references/core-concepts.md`
  - `agent/skills/docs-archive/references/design-principles.md`
  - `agent/skills/docs-archive/references/gates.md`
  - `agent/skills/docs-archive/references/links-and-index.md`
  - `agent/skills/docs-archive/references/quality-checklist.md`
  - `agent/skills/docs-archive/references/workflow.md`

### 2026-05-09 16:40:35.000 · git
- **提交**: `615967439704`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-architect): 更新文档以提升清晰度与一致性
- **文件**:
  - `agent/skills/sdx-architect/SKILL.md`
  - `agent/skills/sdx-architect/agents/analyzer.md`
  - `agent/skills/sdx-architect/agents/grader.md`
  - `agent/skills/sdx-architect/assets/architect-session-spec-template.md`
  - `agent/skills/sdx-architect/assets/asd-spec-template.md`
  - `agent/skills/sdx-architect/assets/asd-stub-sections-federated.md`
  - `agent/skills/sdx-architect/assets/asd-template.md`
  - `agent/skills/sdx-architect/assets/samples/mini-asd-example.md`
  - `agent/skills/sdx-architect/evals/eval-metadata-template.json`
  - `agent/skills/sdx-architect/evals/evals.json`
  - `agent/skills/sdx-architect/references/anti-patterns.md`
  - `agent/skills/sdx-architect/references/gates.md`
  - `agent/skills/sdx-architect/references/knowledge-type-modes.md`
  - `agent/skills/sdx-architect/references/quality-checklist.md`
  - `agent/skills/sdx-architect/references/workflow.md`
  - `agent/skills/sdx-architect/scripts/validate-asd.sh`

### 2026-05-09 16:36:00.000 · git
- **提交**: `281e294e4b74`
- **作者**: ouliyuan0129
- **信息**: docs(docs-agent): 更新文档以提升清晰度与一致性
- **文件**:
  - `agent/skills/docs-agent/SKILL.md`
  - `agent/skills/docs-agent/agents/analyzer.md`
  - `agent/skills/docs-agent/agents/grader.md`
  - `agent/skills/docs-agent/assets/agents-skeleton.md`
  - `agent/skills/docs-agent/assets/readme-skeleton.md`
  - `agent/skills/docs-agent/evals/eval-metadata-template.json`
  - `agent/skills/docs-agent/evals/evals.json`
  - `agent/skills/docs-agent/gotchas.md`
  - `agent/skills/docs-agent/references/execution-spec.md`
  - `agent/skills/docs-agent/references/gates.md`
  - `agent/skills/docs-agent/references/quality-standards.md`
  - `agent/skills/docs-agent/references/three-file-spec.md`
  - `agent/skills/docs-agent/references/workflow.md`
  - `agent/skills/docs-agent/scripts/validate-guide.sh`

### 2026-05-09 16:22:31.000 · git
- **提交**: `a951ab9ef3c4`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-test): 更新文档以提升清晰度与一致性
- **文件**:
  - `agent/skills/sdx-test/SKILL.md`
  - `agent/skills/sdx-test/agents/analyzer.md`
  - `agent/skills/sdx-test/agents/grader.md`
  - `agent/skills/sdx-test/assets/tdd-template.md`
  - `agent/skills/sdx-test/assets/test-session-spec-template.md`
  - `agent/skills/sdx-test/evals/eval-metadata-template.json`
  - `agent/skills/sdx-test/evals/evals.json`
  - `agent/skills/sdx-test/gotchas.md`
  - `agent/skills/sdx-test/references/anti-patterns.md`
  - `agent/skills/sdx-test/references/audience-and-language.md`
  - `agent/skills/sdx-test/references/brainstorming-integration.md`
  - `agent/skills/sdx-test/references/core-concepts.md`
  - `agent/skills/sdx-test/references/design-principles.md`
  - `agent/skills/sdx-test/references/gates.md`
  - `agent/skills/sdx-test/references/quality-checklist.md`
  - `agent/skills/sdx-test/references/workflow.md`
  - `agent/skills/sdx-test/scripts/validate-test.sh`

### 2026-05-09 16:22:04.000 · git
- **提交**: `132cbcd305b0`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-prd): 更新文档以提升清晰度与一致性
- **文件**:
  - `agent/skills/sdx-prd/SKILL.md`
  - `agent/skills/sdx-prd/agents/analyzer.md`
  - `agent/skills/sdx-prd/agents/grader.md`
  - `agent/skills/sdx-prd/assets/prd-session-spec-template.md`
  - `agent/skills/sdx-prd/assets/samples/mini-prd-example.md`
  - `agent/skills/sdx-prd/evals/eval-metadata-template.json`
  - `agent/skills/sdx-prd/evals/evals.json`
  - `agent/skills/sdx-prd/gotchas.md`
  - `agent/skills/sdx-prd/references/anti-patterns.md`
  - `agent/skills/sdx-prd/references/audience-and-language.md`
  - `agent/skills/sdx-prd/references/brainstorming-integration.md`
  - `agent/skills/sdx-prd/references/core-concepts.md`
  - `agent/skills/sdx-prd/references/design-principles.md`
  - `agent/skills/sdx-prd/references/gates.md`
  - `agent/skills/sdx-prd/references/quality-checklist.md`
  - `agent/skills/sdx-prd/references/workflow.md`
  - `agent/skills/sdx-prd/scripts/validate-prd.sh`

### 2026-05-09 16:17:33.000 · git
- **提交**: `42490c3acb75`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-analysis): 更新文档以提升清晰度与一致性
- **文件**:
  - `agent/skills/sdx-analysis/SKILL.md`
  - `agent/skills/sdx-analysis/agents/analyzer.md`
  - `agent/skills/sdx-analysis/agents/grader.md`
  - `agent/skills/sdx-analysis/assets/analysis-session-spec-template.md`
  - `agent/skills/sdx-analysis/assets/analysis-template.md`
  - `agent/skills/sdx-analysis/assets/samples/mini-analysis-example.md`
  - `agent/skills/sdx-analysis/evals/eval-metadata-template.json`
  - `agent/skills/sdx-analysis/evals/evals.json`
  - `agent/skills/sdx-analysis/gotchas.md`
  - `agent/skills/sdx-analysis/references/anti-patterns.md`
  - `agent/skills/sdx-analysis/references/audience-and-language.md`
  - `agent/skills/sdx-analysis/references/brainstorming-integration.md`
  - `agent/skills/sdx-analysis/references/core-concepts.md`
  - `agent/skills/sdx-analysis/references/design-principles.md`
  - `agent/skills/sdx-analysis/references/gates.md`
  - `agent/skills/sdx-analysis/references/quality-checklist.md`
  - `agent/skills/sdx-analysis/references/workflow.md`
  - `agent/skills/sdx-analysis/scripts/validate-analysis.sh`

### 2026-05-09 15:57:57.000 · git
- **提交**: `9075501647bc`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-solution): 更新文档以增强清晰度与一致性
- **文件**:
  - `agent/skills/sdx-solution/SKILL.md`
  - `agent/skills/sdx-solution/agents/analyzer.md`
  - `agent/skills/sdx-solution/agents/grader.md`
  - `agent/skills/sdx-solution/assets/solution-session-spec-template.md`
  - `agent/skills/sdx-solution/assets/solution-template.md`
  - `agent/skills/sdx-solution/evals/eval-metadata-template.json`
  - `agent/skills/sdx-solution/evals/evals.json`
  - `agent/skills/sdx-solution/gotchas.md`
  - `agent/skills/sdx-solution/references/anti-patterns.md`
  - `agent/skills/sdx-solution/references/audience-and-language.md`
  - `agent/skills/sdx-solution/references/brainstorming-integration.md`
  - `agent/skills/sdx-solution/references/core-concepts.md`
  - `agent/skills/sdx-solution/references/design-principles.md`
  - `agent/skills/sdx-solution/references/gates.md`
  - `agent/skills/sdx-solution/references/quality-checklist.md`
  - `agent/skills/sdx-solution/references/workflow.md`
  - `agent/skills/sdx-solution/scripts/validate-solution.sh`

### 2026-05-09 15:50:27.000 · git
- **提交**: `1ea233d528df`
- **作者**: ouliyuan0129
- **信息**: docs(docs-push): 更新文档以反映新的规约路径与文件处理逻辑
- **文件**:
  - `agent/skills/docs-push/SKILL.md`
  - `agent/skills/docs-push/evals/evals.json`
  - `agent/skills/docs-push/gotchas.md`
  - `agent/skills/docs-push/references/parameters.md`
  - `agent/skills/docs-push/references/workflow.md`
  - `agent/skills/docs-push/scripts/push-specs.sh`
  - `scripts/tests/docs-push/cases/05_spec_asd_relocate_dry_run.sh`
  - `scripts/tests/docs-push/cases/06_spec_asd_mirror_requirements_prefix.sh`

### 2026-05-09 15:48:30.000 · git
- **提交**: `a73b76991b56`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-design): 更新文档以增强一致性与清晰度
- **文件**:
  - `agent/skills/sdx-design/SKILL.md`
  - `agent/skills/sdx-design/agents/analyzer.md`
  - `agent/skills/sdx-design/agents/grader.md`
  - `agent/skills/sdx-design/assets/design-session-spec-template.md`
  - `agent/skills/sdx-design/assets/dsd-spec-template.md`
  - `agent/skills/sdx-design/evals/eval-metadata-template.json`
  - `agent/skills/sdx-design/evals/evals.json`
  - `agent/skills/sdx-design/gotchas.md`
  - `agent/skills/sdx-design/references/README.md`
  - `agent/skills/sdx-design/references/anti-patterns.md`
  - `agent/skills/sdx-design/references/audience-and-language.md`
  - `agent/skills/sdx-design/references/brainstorming-integration.md`
  - `agent/skills/sdx-design/references/design-principles.md`
  - `agent/skills/sdx-design/references/gates.md`
  - `agent/skills/sdx-design/references/knowledge-type-modes.md`
  - `agent/skills/sdx-design/references/quality-checklist.md`
  - `agent/skills/sdx-design/references/schemas.md`
  - `agent/skills/sdx-design/references/workflow.md`
  - `agent/skills/sdx-design/scripts/validate-dsd.sh`

### 2026-05-09 14:46:34.000 · git
- **提交**: `6f92f7853a56`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-architect): 更新架构设计文档以增强清晰度与一致性
- **文件**:
  - `agent/skills/sdx-architect/SKILL.md`
  - `agent/skills/sdx-architect/agents/analyzer.md`
  - `agent/skills/sdx-architect/agents/grader.md`
  - `agent/skills/sdx-architect/assets/architect-session-spec-template.md`
  - `agent/skills/sdx-architect/assets/asd-spec-template.md`
  - `agent/skills/sdx-architect/assets/asd-stub-sections-federated.md`
  - `agent/skills/sdx-architect/assets/asd-template.md`
  - `agent/skills/sdx-architect/assets/samples/mini-asd-example.md`
  - `agent/skills/sdx-architect/evals/eval-metadata-template.json`
  - `agent/skills/sdx-architect/evals/evals.json`
  - `agent/skills/sdx-architect/references/anti-patterns.md`
  - `agent/skills/sdx-architect/references/gates.md`
  - `agent/skills/sdx-architect/references/knowledge-type-modes.md`
  - `agent/skills/sdx-architect/references/quality-checklist.md`
  - `agent/skills/sdx-architect/references/workflow.md`
  - `agent/skills/sdx-architect/scripts/validate-asd.sh`

### 2026-05-09 14:18:02.000 · git
- **提交**: `8fe29b98df67`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-design): 更新 dsd-spec-template.md 以增强业务逻辑与清晰度
- **文件**:
  - `agent/skills/sdx-design/assets/dsd-spec-template.md`

### 2026-05-09 11:59:37.000 · git
- **提交**: `a398c2cbb78a`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-architect, sdx-design): 更新文档以反映详设需求规约的新路径与结构要求
- **文件**:
  - `agent/skills/README.md`
  - `agent/skills/docs-push/SKILL.md`
  - `agent/skills/sdx-architect/SKILL.md`
  - `agent/skills/sdx-architect/assets/asd-spec-template.md`
  - `agent/skills/sdx-architect/assets/asd-stub-sections-federated.md`
  - `agent/skills/sdx-architect/assets/asd-template.md`
  - `agent/skills/sdx-architect/assets/samples/mini-asd-example.md`
  - `agent/skills/sdx-architect/evals/evals.json`
  - `agent/skills/sdx-architect/references/knowledge-type-modes.md`
  - `agent/skills/sdx-design/SKILL.md`
  - `agent/skills/sdx-design/agents/analyzer.md`
  - `agent/skills/sdx-design/agents/grader.md`
  - `agent/skills/sdx-design/assets/dsd-spec-template.md`
  - `agent/skills/sdx-design/assets/dsd-template.md`
  - `agent/skills/sdx-design/evals/eval-metadata-template.json`
  - `agent/skills/sdx-design/evals/evals.json`
  - `agent/skills/sdx-design/gotchas.md`
  - `agent/skills/sdx-design/references/anti-patterns.md`
  - `agent/skills/sdx-design/references/audience-and-language.md`
  - `agent/skills/sdx-design/references/design-principles.md`
  - `agent/skills/sdx-design/references/gates.md`
  - `agent/skills/sdx-design/references/knowledge-type-modes.md`
  - `agent/skills/sdx-design/references/quality-checklist.md`
  - `agent/skills/sdx-design/references/workflow.md`
  - `agent/skills/sdx-design/scripts/validate-dsd.sh`
  - `application/DESIGN.md`

### 2026-05-08 19:15:28.000 · git
- **提交**: `9f43cbecb9fa`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-architect, sdx-design): 更新文档以反映新的规约路径与结构要求
- **文件**:
  - `agent/skills/README.md`
  - `agent/skills/docs-push/SKILL.md`
  - `agent/skills/sdx-architect/SKILL.md`
  - `agent/skills/sdx-architect/assets/asd-spec-template.md`
  - `agent/skills/sdx-architect/assets/asd-stub-sections-federated.md`
  - `agent/skills/sdx-architect/assets/asd-template.md`
  - `agent/skills/sdx-architect/assets/samples/mini-asd-example.md`
  - `agent/skills/sdx-architect/evals/evals.json`
  - `agent/skills/sdx-architect/references/knowledge-type-modes.md`
  - `agent/skills/sdx-design/SKILL.md`
  - `agent/skills/sdx-design/agents/analyzer.md`
  - `agent/skills/sdx-design/agents/grader.md`
  - `agent/skills/sdx-design/assets/dsd-spec-template.md`
  - `agent/skills/sdx-design/assets/dsd-template.md`
  - `agent/skills/sdx-design/evals/eval-metadata-template.json`
  - `agent/skills/sdx-design/evals/evals.json`
  - `agent/skills/sdx-design/gotchas.md`
  - `agent/skills/sdx-design/references/anti-patterns.md`
  - `agent/skills/sdx-design/references/audience-and-language.md`
  - `agent/skills/sdx-design/references/brainstorming-integration.md`
  - `agent/skills/sdx-design/references/design-principles.md`
  - `agent/skills/sdx-design/references/gates.md`
  - `agent/skills/sdx-design/references/knowledge-type-modes.md`
  - `agent/skills/sdx-design/references/quality-checklist.md`
  - `agent/skills/sdx-design/references/workflow.md`
  - `agent/skills/sdx-design/scripts/validate-dsd.sh`
  - `agent/skills/sdx-solution/SKILL.md`
  - `agent/skills/sdx-test/gotchas.md`
  - `agent/skills/sdx-test/references/workflow.md`
  - `application/DESIGN.md`

### 2026-05-08 16:35:57.000 · git
- **提交**: `888aa71263f5`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-design): 更新详细设计文档以增强一致性与准确性
- **文件**:
  - `agent/skills/README.md`
  - `agent/skills/sdx-architect/assets/asd-template.md`
  - `agent/skills/sdx-design/SKILL.md`
  - `agent/skills/sdx-design/agents/analyzer.md`
  - `agent/skills/sdx-design/agents/grader.md`
  - `agent/skills/sdx-design/assets/dsd-spec-template.md`
  - `agent/skills/sdx-design/assets/dsd-template.md`
  - `agent/skills/sdx-design/evals/evals.json`
  - `agent/skills/sdx-design/gotchas.md`
  - `agent/skills/sdx-design/references/anti-patterns.md`
  - `agent/skills/sdx-design/references/audience-and-language.md`
  - `agent/skills/sdx-design/references/design-principles.md`
  - `agent/skills/sdx-design/references/quality-checklist.md`
  - `agent/skills/sdx-design/references/workflow.md`
  - `application/DESIGN.md`

### 2026-05-08 16:19:07.000 · git
- **提交**: `5d1ef0a4b9ab`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-architect): 更新架构设计技能文档以增强清晰度与准确性
- **文件**:
  - `agent/skills/sdx-architect/SKILL.md`
  - `agent/skills/sdx-architect/assets/architect-session-spec-template.md`
  - `agent/skills/sdx-architect/references/gates.md`
  - `agent/skills/sdx-architect/references/workflow.md`

### 2026-05-08 16:14:17.000 · git
- **提交**: `371f1883d39a`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-design): 更新技能文档与模板以增强结构与可读性
- **文件**:
  - `agent/skills/sdx-design/SKILL.md`
  - `agent/skills/sdx-design/assets/dsd-template.md`
  - `agent/skills/sdx-design/evals/eval-metadata-template.json`
  - `agent/skills/sdx-design/references/README.md`
  - `agent/skills/sdx-design/references/schemas.md`
  - `agent/skills/sdx-design/scripts/validate-design.sh`

### 2026-05-08 15:40:48.000 · git
- **提交**: `fc7e1cc8ba08`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-design): 更新文档以反映新的规约路径与结构要求
- **文件**:
  - `agent/skills/README.md`
  - `agent/skills/sdx-architect/SKILL.md`
  - `agent/skills/sdx-architect/assets/asd-stub-sections-federated.md`
  - `agent/skills/sdx-architect/assets/asd-template.md`
  - `agent/skills/sdx-architect/evals/evals.json`
  - `agent/skills/sdx-architect/references/knowledge-type-modes.md`
  - `agent/skills/sdx-design/SKILL.md`
  - `agent/skills/sdx-design/agents/analyzer.md`
  - `agent/skills/sdx-design/agents/grader.md`
  - `agent/skills/sdx-design/assets/design-session-spec-template.md`
  - `agent/skills/sdx-design/assets/dsd-template.md`
  - `agent/skills/sdx-design/assets/spec-template.md`
  - `agent/skills/sdx-design/evals/eval-metadata-template.json`
  - `agent/skills/sdx-design/evals/evals.json`
  - `agent/skills/sdx-design/gotchas.md`
  - `agent/skills/sdx-design/references/anti-patterns.md`
  - `agent/skills/sdx-design/references/audience-and-language.md`
  - `agent/skills/sdx-design/references/brainstorming-integration.md`
  - `agent/skills/sdx-design/references/design-principles.md`
  - `agent/skills/sdx-design/references/gates.md`
  - `agent/skills/sdx-design/references/knowledge-type-modes.md`
  - `agent/skills/sdx-design/references/quality-checklist.md`
  - `agent/skills/sdx-design/references/workflow.md`
  - `agent/skills/sdx-design/scripts/validate-dsd.sh`
  - `agent/skills/sdx-solution/SKILL.md`
  - `agent/skills/sdx-test/gotchas.md`
  - `agent/skills/sdx-test/references/workflow.md`
  - `application/DESIGN.md`

### 2026-05-06 09:51:37.000 · git
- **提交**: `f0ee4d5cc493`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-design): 更新技能文档以增强上游输入与结构要求
- **文件**:
  - `agent/skills/sdx-design/SKILL.md`
  - `agent/skills/sdx-design/agents/analyzer.md`
  - `agent/skills/sdx-design/agents/grader.md`
  - `agent/skills/sdx-design/evals/eval-metadata-template.json`
  - `agent/skills/sdx-design/evals/evals.json`
  - `agent/skills/sdx-design/references/anti-patterns.md`
  - `agent/skills/sdx-design/references/audience-and-language.md`
  - `agent/skills/sdx-design/references/design-principles.md`
  - `agent/skills/sdx-design/references/quality-checklist.md`
  - `agent/skills/sdx-design/references/workflow.md`
  - `agent/skills/sdx-design/scripts/validate-dsd.sh`

### 2026-05-05 15:15:43.000 · git
- **提交**: `9e1d98fd0a0f`
- **作者**: ouliyuan0129
- **信息**: docs(docs-push): 更新文档与脚本以增强功能与路径解析
- **文件**:
  - `agent/README.md`
  - `agent/scripts/docs-core.sh`
  - `agent/skills/docs-push/SKILL.md`
  - `agent/skills/docs-push/references/parameters.md`
  - `agent/skills/docs-push/scripts/push-specs.sh`
  - `scripts/README.md`
  - `scripts/docs-link.sh`
  - `scripts/lib/knowledge-links-read.sh`
  - `scripts/link-config.sh`
  - `scripts/tests/docs-push/cases/03_resolve_from_cwd_fake_cursor_layout.sh`
  - `scripts/tests/docs-push/cases/04_agents_layout_relative_links_cwd.sh`
  - `system/index.md`
  - `system/analysis/README.md`
  - `system/specs/README.md`

### 2026-05-05 14:21:13.000 · git
- **提交**: `6915d41975c1`
- **作者**: ouliyuan0129
- **信息**: docs(docs-push): 新增 docs-push 功能与文档
- **文件**:
  - `agent/skills/README.md`
  - `agent/skills/docs-push/SKILL.md`
  - `agent/skills/docs-push/evals/evals.json`
  - `agent/skills/docs-push/gotchas.md`
  - `agent/skills/docs-push/references/README.md`
  - `agent/skills/docs-push/references/gates.md`
  - `agent/skills/docs-push/references/parameters.md`
  - `agent/skills/docs-push/references/workflow.md`
  - `agent/skills/docs-push/scripts/push-specs.sh`
  - `scripts/README.md`
  - `scripts/docs-link.sh`
  - `scripts/lib/knowledge-links-read.sh`
  - `scripts/tests/docs-push/cases/01_copy_dry_run.sh`
  - `scripts/tests/docs-push/cases/02_strict_missing_app.sh`
  - `scripts/tests/docs-push/run.sh`

### 2026-05-04 21:03:54.000 · git
- **提交**: `6f3eee2426c0`
- **作者**: ouliyuan0129
- **信息**: merge: 合并 feature-1.2.0 到 main

### 2026-05-04 12:06:53.000 · git
- **提交**: `97c30cb36365`
- **作者**: ouliyuan0129
- **信息**: docs(docs-indexing): 更新索引指南以增强文档结构与信息完整性
- **文件**:
  - `index.md`
  - `application/index.md`
  - `scripts/agent-config.sh`
  - `scripts/agent-install.sh`
  - `system/index.md`
  - `system/changelogs/INDEXING-LOG.md`

### 2026-05-04 11:52:15.000 · git
- **提交**: `48c65b5c76d6`
- **作者**: ouliyuan0129
- **信息**: docs(docs-indexing): 增强文档结构与功能性
- **文件**:
  - `AGENTS.md`
  - `index.md`
  - `agent/hooks.json`
  - `agent/hooks/README.md`
  - `agent/hooks/sdx_gate_common.py`
  - `agent/hooks/sdx_session_gate.py`
  - `agent/hooks/tests/test_sdx_gate_common.py`
  - `agent/rules/CONVENTIONS.md`
  - `application/index.md`
  - `company/changelogs/README.md`
  - `system/index.md`
  - `system/changelogs/README.md`

### 2026-05-04 11:51:45.000 · git
- **提交**: `1f49fdf61df1`
- **作者**: ouliyuan0129
- **信息**: docs(docs-indexing): 更新文档以增强结构与功能性
- **文件**:
  - `agent/skills/README.md`
  - `agent/skills/docs-indexing/SKILL.md`
  - `agent/skills/docs-indexing/agents/analyzer.md`
  - `agent/skills/docs-indexing/agents/grader.md`
  - `agent/skills/docs-indexing/assets/docs-indexing-session-spec-template.md`
  - `agent/skills/docs-indexing/evals/eval-metadata-template.json`
  - `agent/skills/docs-indexing/evals/evals.json`
  - `agent/skills/docs-indexing/gotchas.md`
  - `agent/skills/docs-indexing/references/README.md`
  - `agent/skills/docs-indexing/references/anti-patterns.md`
  - `agent/skills/docs-indexing/references/brainstorming-integration.md`
  - `agent/skills/docs-indexing/references/gates.md`
  - `agent/skills/docs-indexing/references/indexing-log-spec.md`
  - `agent/skills/docs-indexing/references/interaction-gate.md`
  - `agent/skills/docs-indexing/references/nine-chapter-spec.md`
  - `agent/skills/docs-indexing/references/quality-standards.md`
  - `agent/skills/docs-indexing/references/scan-config-onboarding.md`
  - `agent/skills/docs-indexing/references/scan-spec.md`
  - `agent/skills/docs-indexing/references/workflow.md`
  - `agent/skills/docs-indexing/scripts/indexing.sh`
  - `agent/skills/docs-indexing/scripts/indexing_log.py`

### 2026-05-04 11:48:58.000 · git
- **提交**: `57e1f98b8542`
- **作者**: ouliyuan0129
- **信息**: docs(docs-tag): 增强文档结构与功能性
- **文件**:
  - `agent/skills/docs-tag/SKILL.md`
  - `agent/skills/docs-tag/agents/analyzer.md`
  - `agent/skills/docs-tag/agents/grader.md`
  - `agent/skills/docs-tag/evals/eval-metadata-template.json`
  - `agent/skills/docs-tag/evals/evals.json`
  - `agent/skills/docs-tag/gotchas.md`
  - `agent/skills/docs-tag/references/algorithm.md`
  - `agent/skills/docs-tag/references/gates.md`
  - `agent/skills/docs-tag/references/workflow.md`
  - `agent/skills/docs-tag/scripts/keyword_tag.py`
  - `agent/skills/docs-tag/tests/test_integration.py`
  - `agent/skills/docs-tag/tests/test_properties.py`

### 2026-05-04 11:48:04.000 · git
- **提交**: `3ea47edd0a76`
- **作者**: ouliyuan0129
- **信息**: docs(docs-upgrade): 更新文档以增强技能描述与执行流程
- **文件**:
  - `agent/skills/docs-upgrade/SKILL.md`
  - `agent/skills/docs-upgrade/agents/analyzer.md`
  - `agent/skills/docs-upgrade/agents/grader.md`
  - `agent/skills/docs-upgrade/assets/docs-upgrade-scope-ack-template.md`
  - `agent/skills/docs-upgrade/evals/eval-metadata-template.json`
  - `agent/skills/docs-upgrade/evals/evals.json`
  - `agent/skills/docs-upgrade/references/README.md`
  - `agent/skills/docs-upgrade/references/anti-patterns.md`
  - `agent/skills/docs-upgrade/references/brainstorming-integration.md`
  - `agent/skills/docs-upgrade/references/core-concepts.md`
  - `agent/skills/docs-upgrade/references/design-principles.md`
  - `agent/skills/docs-upgrade/references/gates.md`
  - `agent/skills/docs-upgrade/references/quality-checklist.md`
  - `agent/skills/docs-upgrade/references/related-doc-discovery.md`
  - `agent/skills/docs-upgrade/references/semantic-keyword-discovery.md`
  - `agent/skills/docs-upgrade/references/workflow.md`

### 2026-05-04 11:42:02.000 · git
- **提交**: `fec96ec439ad`
- **作者**: ouliyuan0129
- **信息**: docs(docs-agent): 更新文档以增强一致性与准确性
- **文件**:
  - `AGENTS.md`
  - `index.md`
  - `README.md`
  - `agent/README.md`
  - `agent/skills/README.md`
  - `agent/skills/docs-change/SKILL.md`
  - `agent/skills/docs-change/agents/analyzer.md`
  - `agent/skills/docs-change/agents/grader.md`
  - `agent/skills/docs-change/evals/eval-metadata-template.json`
  - `agent/skills/docs-change/evals/evals.json`
  - `agent/skills/docs-change/references/README.md`
  - `agent/skills/docs-change/references/anti-patterns.md`
  - `agent/skills/docs-change/references/collection-rules.md`
  - `agent/skills/docs-change/references/core-concepts.md`
  - `agent/skills/docs-change/references/design-principles.md`
  - `agent/skills/docs-change/references/gates.md`
  - `agent/skills/docs-change/references/quality-checklist.md`
  - `agent/skills/docs-change/references/workflow.md`
  - `agent/skills/docs-indexing/SKILL.md`
  - `agent/skills/docs-indexing/gotchas.md`
  - `agent/skills/docs-indexing/reference/indexing-log-spec.md`

### 2026-05-04 11:40:53.000 · git
- **提交**: `2b3ac4b60e4e`
- **作者**: ouliyuan0129
- **信息**: docs(docs-build): 新增与更新文档以增强功能性与一致性
- **文件**:
  - `agent/skills/docs-build/SKILL.md`
  - `agent/skills/docs-build/agents/analyzer.md`
  - `agent/skills/docs-build/agents/grader.md`
  - `agent/skills/docs-build/assets/docs-build-session-spec-template.md`
  - `agent/skills/docs-build/evals/eval-metadata-template.json`
  - `agent/skills/docs-build/evals/evals.json`
  - `agent/skills/docs-build/gotchas.md`
  - `agent/skills/docs-build/references/README.md`
  - `agent/skills/docs-build/references/anti-patterns.md`
  - `agent/skills/docs-build/references/brainstorming-integration.md`
  - `agent/skills/docs-build/references/builtin-config.md`
  - `agent/skills/docs-build/references/core-concepts.md`
  - `agent/skills/docs-build/references/design-principles.md`
  - `agent/skills/docs-build/references/gates.md`
  - `agent/skills/docs-build/references/interaction-gate.md`
  - `agent/skills/docs-build/references/workflow.md`

### 2026-05-04 11:40:36.000 · git
- **提交**: `3bfef7f00130`
- **作者**: ouliyuan0129
- **信息**: docs(docs-agent): 新增文档与更新现有内容以增强功能性与一致性
- **文件**:
  - `agent/hooks/README.md`
  - `agent/rules/CONVENTIONS.md`
  - `agent/skills/agent-guide/SKILL.md`
  - `agent/skills/docs-agent/SKILL.md`
  - `agent/skills/docs-agent/agents/analyzer.md`
  - `agent/skills/docs-agent/agents/grader.md`
  - `agent/skills/docs-agent/assets/agents-skeleton.md`
  - `agent/skills/docs-agent/assets/readme-skeleton.md`
  - `agent/skills/docs-agent/evals/eval-metadata-template.json`
  - `agent/skills/docs-agent/evals/evals.json`
  - `agent/skills/docs-agent/gotchas.md`
  - `agent/skills/docs-agent/references/execution-spec.md`
  - `agent/skills/docs-agent/references/gates.md`
  - `agent/skills/docs-agent/references/quality-standards.md`
  - `agent/skills/docs-agent/references/three-file-spec.md`
  - `agent/skills/docs-agent/references/workflow.md`
  - `agent/skills/docs-agent/scripts/validate-guide.sh`

### 2026-05-04 11:39:44.000 · git
- **提交**: `02baf7d8bd7e`
- **作者**: ouliyuan0129
- **信息**: docs(docs-archive): 增强文档结构与功能性
- **文件**:
  - `agent/skills/docs-build/references/builtin-config.md`
  - `agent/skills/docs-build/references/consolidation-spec.md`
  - `agent/skills/docs-build/references/extraction-rules.md`
  - `agent/skills/docs-build/references/quality-checklist.md`
  - `agent/skills/docs-build/references/readme-fill-spec.md`

### 2026-05-04 11:37:52.000 · git
- **提交**: `09ca3579903d`
- **作者**: ouliyuan0129
- **信息**: docs(docs-archive): 增强文档结构与功能性
- **文件**:
  - `agent/skills/docs-archive/SKILL.md`
  - `agent/skills/docs-archive/agents/analyzer.md`
  - `agent/skills/docs-archive/agents/grader.md`
  - `agent/skills/docs-archive/assets/docs-archive-session-spec-template.md`
  - `agent/skills/docs-archive/evals/eval-metadata-template.json`
  - `agent/skills/docs-archive/evals/evals.json`
  - `agent/skills/docs-archive/gotchas.md`
  - `agent/skills/docs-archive/reference/gates-and-links.md`
  - `agent/skills/docs-archive/references/README.md`
  - `agent/skills/docs-archive/references/anti-patterns.md`
  - `agent/skills/docs-archive/references/brainstorming-integration.md`
  - `agent/skills/docs-archive/references/core-concepts.md`
  - `agent/skills/docs-archive/references/design-principles.md`
  - `agent/skills/docs-archive/references/gates.md`
  - `agent/skills/docs-archive/references/links-and-index.md`
  - `agent/skills/docs-archive/references/quality-checklist.md`
  - `agent/skills/docs-archive/references/workflow.md`

### 2026-05-04 11:36:12.000 · git
- **提交**: `ea5702c570c2`
- **作者**: ouliyuan0129
- **信息**: docs(docs-extract): 更新文档以增强一致性和可操作性
- **文件**:
  - `agent/skills/docs-extract/SKILL.md`
  - `agent/skills/docs-extract/agents/analyzer.md`
  - `agent/skills/docs-extract/agents/grader.md`
  - `agent/skills/docs-extract/assets/docs-extract-session-spec-template.md`
  - `agent/skills/docs-extract/evals/eval-metadata-template.json`
  - `agent/skills/docs-extract/gotchas.md`
  - `agent/skills/docs-extract/reference/interaction-gate.md`
  - `agent/skills/docs-extract/references/README.md`
  - `agent/skills/docs-extract/references/anti-patterns.md`
  - `agent/skills/docs-extract/references/brainstorming-integration.md`
  - `agent/skills/docs-extract/references/core-concepts.md`
  - `agent/skills/docs-extract/references/design-principles.md`
  - `agent/skills/docs-extract/references/extract-spec.md`
  - `agent/skills/docs-extract/references/gates.md`
  - `agent/skills/docs-extract/references/interaction-gate.md`
  - `agent/skills/docs-extract/references/quality-checklist.md`
  - `agent/skills/docs-extract/references/workflow.md`

### 2026-05-04 11:35:14.000 · git
- **提交**: `d1d37ca214b3`
- **作者**: ouliyuan0129
- **信息**: docs(docs-pull): 增强文档结构与内容一致性
- **文件**:
  - `agent/hooks/README.md`
  - `agent/skills/docs-pull/SKILL.md`
  - `agent/skills/docs-pull/agents/analyzer.md`
  - `agent/skills/docs-pull/agents/grader.md`
  - `agent/skills/docs-pull/assets/docs-pull-run-checklist.md`
  - `agent/skills/docs-pull/evals/eval-metadata-template.json`
  - `agent/skills/docs-pull/evals/evals.json`
  - `agent/skills/docs-pull/reference/preflight.md`
  - `agent/skills/docs-pull/references/README.md`
  - `agent/skills/docs-pull/references/anti-patterns.md`
  - `agent/skills/docs-pull/references/brainstorming-integration.md`
  - `agent/skills/docs-pull/references/core-concepts.md`
  - `agent/skills/docs-pull/references/design-principles.md`
  - `agent/skills/docs-pull/references/gates.md`
  - `agent/skills/docs-pull/references/manifest-spec.md`
  - `agent/skills/docs-pull/references/quality-checklist.md`
  - `agent/skills/docs-pull/references/workflow.md`

### 2026-05-04 11:24:25.000 · git
- **提交**: `d0f8c5ae7839`
- **作者**: ouliyuan0129
- **信息**: docs(docs-distill): 更新文档以增强技能描述和一致性
- **文件**:
  - `agent/hooks/README.md`
  - `agent/rules/CONVENTIONS.md`
  - `agent/skills/docs-distill/SKILL.md`
  - `agent/skills/docs-distill/agents/analyzer.md`
  - `agent/skills/docs-distill/agents/grader.md`
  - `agent/skills/docs-distill/assets/docs-distill-session-spec-template.md`
  - `agent/skills/docs-distill/evals/eval-metadata-template.json`
  - `agent/skills/docs-distill/gotchas.md`
  - `agent/skills/docs-distill/reference/README.md`
  - `agent/skills/docs-distill/reference/interaction-gate.md`
  - `agent/skills/docs-distill/references/README.md`
  - `agent/skills/docs-distill/references/anti-patterns.md`
  - `agent/skills/docs-distill/references/brainstorming-integration.md`
  - `agent/skills/docs-distill/references/core-concepts.md`
  - `agent/skills/docs-distill/references/design-principles.md`
  - `agent/skills/docs-distill/references/distill-log-spec.md`
  - `agent/skills/docs-distill/references/distill-spec.md`
  - `agent/skills/docs-distill/references/federation-spec.md`
  - `agent/skills/docs-distill/references/gates.md`
  - `agent/skills/docs-distill/references/interaction-gate.md`
  - `agent/skills/docs-distill/references/quality-checklist.md`
  - `agent/skills/docs-distill/references/workflow.md`
  - `agent/skills/docs-indexing/reference/indexing-log-spec.md`

### 2026-05-04 09:53:42.000 · git
- **提交**: `c0ef2e60e8b2`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-test): 更新文档以增强技能描述和一致性
- **文件**:
  - `index.md`
  - `agent/skills/README.md`
  - `agent/skills/sdx-test/SKILL.md`
  - `agent/skills/sdx-test/agents/analyzer.md`
  - `agent/skills/sdx-test/agents/grader.md`
  - `agent/skills/sdx-test/assets/tdd-template.md`
  - `agent/skills/sdx-test/assets/test-session-spec-template.md`
  - `agent/skills/sdx-test/evals/eval-metadata-template.json`
  - `agent/skills/sdx-test/evals/evals.json`
  - `agent/skills/sdx-test/gotchas.md`
  - `agent/skills/sdx-test/references/anti-patterns.md`
  - `agent/skills/sdx-test/references/audience-and-language.md`
  - `agent/skills/sdx-test/references/brainstorming-integration.md`
  - `agent/skills/sdx-test/references/core-concepts.md`
  - `agent/skills/sdx-test/references/design-principles.md`
  - `agent/skills/sdx-test/references/gates.md`
  - `agent/skills/sdx-test/references/quality-checklist.md`
  - `agent/skills/sdx-test/references/workflow.md`

### 2026-05-04 09:50:52.000 · git
- **提交**: `d4f35584cc92`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-design): 增强文档结构与内容一致性
- **文件**:
  - `index.md`
  - `agent/skills/README.md`
  - `agent/skills/sdx-architect/SKILL.md`
  - `agent/skills/sdx-architect/agents/analyzer.md`
  - `agent/skills/sdx-architect/agents/grader.md`
  - `agent/skills/sdx-architect/assets/architect-session-spec-template.md`
  - `agent/skills/sdx-architect/evals/eval-metadata-template.json`
  - `agent/skills/sdx-architect/evals/evals.json`
  - `agent/skills/sdx-architect/references/gates.md`
  - `agent/skills/sdx-architect/references/workflow.md`
  - `agent/skills/sdx-design/SKILL.md`
  - `agent/skills/sdx-design/agents/analyzer.md`
  - `agent/skills/sdx-design/agents/grader.md`
  - `agent/skills/sdx-design/evals/eval-metadata-template.json`
  - `agent/skills/sdx-design/evals/evals.json`
  - `agent/skills/sdx-design/gotchas.md`
  - `agent/skills/sdx-design/references/anti-patterns.md`
  - `agent/skills/sdx-design/references/audience-and-language.md`
  - `agent/skills/sdx-design/references/brainstorming-integration.md`
  - `agent/skills/sdx-design/references/design-principles.md`
  - `agent/skills/sdx-design/references/gates.md`
  - `agent/skills/sdx-design/references/knowledge-type-modes.md`
  - `agent/skills/sdx-design/references/quality-checklist.md`
  - `agent/skills/sdx-design/references/workflow.md`

### 2026-05-04 09:43:10.000 · git
- **提交**: `41ebc3100cca`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-prd): 更新文档以增强技能描述和结构一致性
- **文件**:
  - `agent/skills/sdx-prd/SKILL.md`
  - `agent/skills/sdx-prd/agents/analyzer.md`
  - `agent/skills/sdx-prd/agents/grader.md`
  - `agent/skills/sdx-prd/assets/prd-session-spec-template.md`
  - `agent/skills/sdx-prd/assets/prd-template.md`
  - `agent/skills/sdx-prd/assets/samples/mini-prd-example.md`
  - `agent/skills/sdx-prd/evals/eval-metadata-template.json`
  - `agent/skills/sdx-prd/evals/evals.json`
  - `agent/skills/sdx-prd/gotchas.md`
  - `agent/skills/sdx-prd/references/anti-patterns.md`
  - `agent/skills/sdx-prd/references/audience-and-language.md`
  - `agent/skills/sdx-prd/references/brainstorming-integration.md`
  - `agent/skills/sdx-prd/references/core-concepts.md`
  - `agent/skills/sdx-prd/references/design-principles.md`
  - `agent/skills/sdx-prd/references/gates.md`
  - `agent/skills/sdx-prd/references/quality-checklist.md`
  - `agent/skills/sdx-prd/references/workflow.md`
  - `agent/skills/sdx-solution/SKILL.md`

### 2026-05-04 09:42:46.000 · git
- **提交**: `900c167dcbe3`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-analysis): 增强技能文档以明确主要读者和角色
- **文件**:
  - `agent/skills/sdx-analysis/SKILL.md`

### 2026-05-04 09:31:28.000 · git
- **提交**: `8470819da099`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-analysis): 更新文档以增强技能描述和链接一致性
- **文件**:
  - `agent/skills/sdx-analysis/SKILL.md`
  - `agent/skills/sdx-analysis/agents/analyzer.md`
  - `agent/skills/sdx-analysis/agents/grader.md`
  - `agent/skills/sdx-analysis/assets/analysis-session-spec-template.md`
  - `agent/skills/sdx-analysis/assets/samples/mini-analysis-example.md`
  - `agent/skills/sdx-analysis/evals/eval-metadata-template.json`
  - `agent/skills/sdx-analysis/evals/evals.json`
  - `agent/skills/sdx-analysis/gotchas.md`
  - `agent/skills/sdx-analysis/references/anti-patterns.md`
  - `agent/skills/sdx-analysis/references/audience-and-language.md`
  - `agent/skills/sdx-analysis/references/brainstorming-integration.md`
  - `agent/skills/sdx-analysis/references/core-concepts.md`
  - `agent/skills/sdx-analysis/references/design-principles.md`
  - `agent/skills/sdx-analysis/references/gates.md`
  - `agent/skills/sdx-analysis/references/quality-checklist.md`
  - `agent/skills/sdx-analysis/references/workflow.md`

### 2026-05-04 09:25:56.000 · git
- **提交**: `e047725d27e5`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-solution): 更新文档以增强技能描述和门禁规则
- **文件**:
  - `agent/skills/sdx-solution/SKILL.md`
  - `agent/skills/sdx-solution/agents/analyzer.md`
  - `agent/skills/sdx-solution/agents/grader.md`
  - `agent/skills/sdx-solution/evals/eval-metadata-template.json`
  - `agent/skills/sdx-solution/evals/evals.json`
  - `agent/skills/sdx-solution/gotchas.md`
  - `agent/skills/sdx-solution/references/anti-patterns.md`
  - `agent/skills/sdx-solution/references/brainstorming-integration.md`
  - `agent/skills/sdx-solution/references/design-principles.md`
  - `agent/skills/sdx-solution/references/gates.md`
  - `agent/skills/sdx-solution/references/workflow-spec.md`
  - `agent/skills/sdx-solution/references/workflow.md`

### 2026-05-04 09:14:03.000 · git
- **提交**: `79deebfc2e35`
- **作者**: ouliyuan0129
- **信息**: fix(docs): 修正知识库链接格式以确保一致性
- **文件**:
  - `agent/skills/sdx-analysis/reference/audience-and-language.md`
  - `agent/skills/sdx-prd/reference/audience-and-language.md`
  - `agent/skills/sdx-prd/reference/core-concepts.md`
  - `agent/skills/sdx-solution/SKILL.md`
  - `agent/skills/sdx-solution/agents/analyzer.md`
  - `agent/skills/sdx-solution/agents/grader.md`
  - `agent/skills/sdx-solution/assets/solution-session-spec-template.md`
  - `agent/skills/sdx-solution/evals/eval-metadata-template.json`
  - `agent/skills/sdx-solution/evals/evals.json`
  - `agent/skills/sdx-solution/gotchas.md`
  - `agent/skills/sdx-solution/references/audience-and-language.md`
  - `agent/skills/sdx-solution/references/brainstorming-integration.md`
  - `agent/skills/sdx-solution/references/core-concepts.md`
  - `agent/skills/sdx-solution/references/design-principles.md`
  - `agent/skills/sdx-solution/references/quality-checklist.md`
  - `agent/skills/sdx-solution/references/workflow-spec.md`
  - `agent/skills/sdx-test/reference/audience-and-language.md`

### 2026-05-04 09:08:29.000 · git
- **提交**: `8d2f5af5ced8`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-architect): 移除冗余的 gotchas.md 文件并更新知识库链接
- **文件**:
  - `agent/skills/sdx-architect/SKILL.md`
  - `agent/skills/sdx-architect/assets/architect-session-spec-template.md`
  - `agent/skills/sdx-architect/gotchas.md`
  - `agent/skills/sdx-architect/references/anti-patterns.md`
  - `agent/skills/sdx-architect/references/knowledge-type-modes.md`
  - `agent/skills/sdx-design/reference/knowledge-type-modes.md`

### 2026-05-04 08:57:03.000 · git
- **提交**: `0998fd2d9c61`
- **作者**: ouliyuan0129
- **信息**: refactor(config-bootstrap): 精简配置解析逻辑并增强错误提示
- **文件**:
  - `agent/scripts/config-bootstrap.sh`
  - `agent/scripts/docs-core.sh`
  - `scripts/agent-config.sh`
  - `scripts/agent-install.sh`
  - `scripts/docs-bootstrap.sh`
  - `scripts/docs-config.sh`
  - `scripts/docs-install.sh`
  - `scripts/docs-link.sh`
  - `scripts/link-config.sh`

### 2026-05-03 19:22:34.000 · git
- **提交**: `9b8e4e615e16`
- **作者**: ouliyuan0129
- **信息**: docs(docs-link): 更新知识库链接格式和验证逻辑
- **文件**:
  - `company/knowledge-links.yaml`
  - `scripts/README.md`
  - `scripts/docs-link.sh`
  - `scripts/tests/docs-link/cases/02_link_writes_tilde_path_under_home.sh`
  - `scripts/tests/docs-link/cases/03_second_link_preserves_app_label.sh`
  - `system/knowledge-links.yaml`

### 2026-05-03 16:48:38.000 · git
- **提交**: `6ba299b72d7e`
- **作者**: ouliyuan0129
- **信息**: docs(docs-pull): 引入新技能并更新相关文档
- **文件**:
  - `index.md`
  - `README.md`
  - `agent/rules/CONVENTIONS.md`
  - `agent/scripts/config-bootstrap.sh`
  - `agent/skills/README.md`
  - `agent/skills/docs-pull/SKILL.md`
  - `agent/skills/docs-pull/assets/pull-log-template.md`
  - `agent/skills/docs-pull/gotchas.md`
  - `agent/skills/docs-pull/reference/manifest-spec.md`
  - `agent/skills/docs-pull/reference/preflight.md`
  - `agent/skills/docs-pull/scripts/pull-docs.sh`
  - `scripts/README.md`
  - `scripts/agent-install.sh`
  - `scripts/docs-bootstrap.sh`
  - `scripts/docs-install.sh`
  - `scripts/docs-link.sh`
  - `scripts/tests/docs-install/cases/02_scope_knowledge_no_docsconfig.sh`
  - `scripts/tests/docs-install/cases/03_mode_central_only_application.sh`
  - `scripts/tests/docs-install/cases/04_central_no_registry_side_effect.sh`
  - `scripts/tests/docs-install/cases/05_knowledge_system_installs_link_scripts.sh`
  - `scripts/tests/docs-install/cases/06_knowledge_company_installs_link_scripts.sh`
  - `scripts/tests/docs-install/cases/07_agent_install_recompute_agent_fields.sh`
  - `scripts/tests/docs-install/cases/08_knowledge_rewrites_agent_paths.sh`
  - `scripts/tests/docs-install/cases/09_standalone_full_installs_nested_readme.sh`
  - `scripts/tests/docs-install/cases/10_target_space_form.sh`
  - `scripts/tests/docs-link/cases/01_reject_path_as_url.sh`
  - `system/DESIGN.md`

### 2026-05-03 15:25:19.000 · git
- **提交**: `6228238c9ae8`
- **作者**: ouliyuan0129
- **信息**: docs(docs-link): 更新知识库链接格式和验证逻辑
- **文件**:
  - `company/knowledge-links.yaml`
  - `scripts/README.md`
  - `scripts/docs-link.sh`
  - `scripts/tests/docs-link/cases/01_reject_path_as_url.sh`
  - `scripts/tests/docs-link/run.sh`
  - `system/knowledge-links.yaml`

### 2026-04-30 22:44:35.000 · git
- **提交**: `e6c872089ce2`
- **作者**: ouliyuan0129
- **信息**: docs(agent-install): 更新安装路径和文档以反映单份实体存储的变更
- **文件**:
  - `scripts/README.md`
  - `scripts/agent-install.sh`

### 2026-04-30 22:34:32.000 · git
- **提交**: `c95390c453fa`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-architect): 更新技能文档以增强架构设计阶段的清晰度和一致性
- **文件**:
  - `agent/skills/sdx-architect/SKILL.md`
  - `agent/skills/sdx-architect/agents/analyzer.md`
  - `agent/skills/sdx-architect/agents/grader.md`
  - `agent/skills/sdx-architect/assets/asd-spec-template.md`
  - `agent/skills/sdx-architect/assets/asd-template.md`
  - `agent/skills/sdx-architect/assets/samples/mini-asd-example.md`
  - `agent/skills/sdx-architect/evals/eval-metadata-template.json`
  - `agent/skills/sdx-architect/evals/evals.json`
  - `agent/skills/sdx-architect/references/anti-patterns.md`
  - `agent/skills/sdx-architect/references/gates.md`
  - `agent/skills/sdx-architect/references/quality-checklist.md`
  - `agent/skills/sdx-architect/references/workflow.md`
  - `agent/skills/skill-creator/SKILL.md`
  - `agent/skills/skill-creator/agents/analyzer.md`
  - `agent/skills/skill-creator/agents/comparator.md`
  - `agent/skills/skill-creator/agents/grader.md`
  - `agent/skills/skill-creator/assets/eval_review.html`
  - `agent/skills/skill-creator/eval-viewer/generate_review.py`
  - `agent/skills/skill-creator/eval-viewer/viewer.html`
  - `agent/skills/skill-creator/license.txt`
  - `agent/skills/skill-creator/references/schemas.md`
  - `agent/skills/skill-creator/scripts/__init__.py`
  - `agent/skills/skill-creator/scripts/aggregate_benchmark.py`
  - `agent/skills/skill-creator/scripts/generate_report.py`
  - `agent/skills/skill-creator/scripts/improve_description.py`
  - `agent/skills/skill-creator/scripts/package_skill.py`
  - `agent/skills/skill-creator/scripts/quick_validate.py`
  - `agent/skills/skill-creator/scripts/run_eval.py`
  - `agent/skills/skill-creator/scripts/run_loop.py`
  - `agent/skills/skill-creator/scripts/utils.py`

### 2026-04-30 12:33:04.000 · git
- **提交**: `a602b9308308`
- **作者**: ouliyuan0129
- **信息**: docs(skills): 更新技能文档以反映架构设计和详细设计阶段的需求
- **文件**:
  - `agent/skills/README.md`
  - `agent/skills/sdx-analysis/SKILL.md`
  - `agent/skills/sdx-analysis/assets/analysis-session-spec-template.md`
  - `agent/skills/sdx-architect/SKILL.md`
  - `agent/skills/sdx-architect/assets/architect-session-spec-template.md`
  - `agent/skills/sdx-architect/assets/asd-stub-sections-federated.md`
  - `agent/skills/sdx-architect/assets/asd-template.md`
  - `agent/skills/sdx-architect/reference/knowledge-type-modes.md`
  - `agent/skills/sdx-architect/scripts/validate-asd.sh`
  - `agent/skills/sdx-design/SKILL.md`
  - `agent/skills/sdx-design/assets/design-session-spec-template.md`
  - `agent/skills/sdx-design/assets/dsd-template.md`
  - `agent/skills/sdx-design/reference/design-principles.md`
  - `agent/skills/sdx-design/reference/workflow-spec.md`
  - `agent/skills/sdx-prd/SKILL.md`
  - `agent/skills/sdx-prd/assets/prd-session-spec-template.md`
  - `agent/skills/sdx-solution/SKILL.md`
  - `agent/skills/sdx-solution/assets/solution-session-spec-template.md`
  - `agent/skills/sdx-test/SKILL.md`
  - `agent/skills/sdx-test/assets/test-session-spec-template.md`

### 2026-04-29 12:15:23.000 · git
- **提交**: `ff4b57a2be4a`
- **作者**: ouliyuan0129
- **信息**: docs(AGENTS, index, README): 更新文档以引入架构设计阶段和详细设计阶段规范
- **文件**:
  - `AGENTS.md`
  - `index.md`
  - `README.md`
  - `agent/hooks.json`
  - `agent/hooks/README.md`
  - `agent/hooks/sdx_gate_common.py`
  - `agent/hooks/sdx_session_gate.py`
  - `agent/rules/CONVENTIONS.md`
  - `agent/scripts/config-bootstrap.sh`
  - `agent/skills/README.md`
  - `agent/skills/docs-archive/SKILL.md`
  - `agent/skills/docs-distill/reference/interaction-gate.md`
  - `agent/skills/sdx-analysis/assets/analysis-template.md`
  - `agent/skills/sdx-analysis/reference/design-principles.md`
  - `agent/skills/sdx-architect/SKILL.md`
  - `agent/skills/sdx-architect/assets/architect-session-spec-template.md`
  - `agent/skills/sdx-architect/assets/asd-stub-sections-federated.md`
  - `agent/skills/sdx-architect/assets/asd-template.md`
  - `agent/skills/sdx-architect/gotchas.md`
  - `agent/skills/sdx-architect/reference/knowledge-type-modes.md`
  - `agent/skills/sdx-architect/scripts/validate-asd.sh`
  - `agent/skills/sdx-design/SKILL.md`
  - `agent/skills/sdx-design/assets/add-template.md`
  - `agent/skills/sdx-design/assets/design-session-spec-template.md`
  - `agent/skills/sdx-design/assets/dsd-template.md`
  - `agent/skills/sdx-design/assets/spec-template.md`
  - `agent/skills/sdx-design/gotchas.md`
  - `agent/skills/sdx-design/reference/audience-and-language.md`
  - `agent/skills/sdx-design/reference/brainstorming-integration.md`
  - `agent/skills/sdx-design/reference/design-principles.md`
  - … 另有 29 个文件

### 2026-04-29 09:45:43.000 · git
- **提交**: `fe6b1f763a79`
- **作者**: ouliyuan0129
- **信息**: docs(skills): 添加会话草稿门禁进度表规范
- **文件**:
  - `agent/skills/docs-archive/SKILL.md`
  - `agent/skills/docs-build/SKILL.md`
  - `agent/skills/docs-distill/reference/interaction-gate.md`
  - `agent/skills/docs-extract/reference/interaction-gate.md`
  - `agent/skills/sdx-analysis/SKILL.md`
  - `agent/skills/sdx-analysis/assets/analysis-session-spec-template.md`
  - `agent/skills/sdx-design/SKILL.md`
  - `agent/skills/sdx-design/assets/design-session-spec-template.md`
  - `agent/skills/sdx-prd/SKILL.md`
  - `agent/skills/sdx-prd/assets/prd-session-spec-template.md`
  - `agent/skills/sdx-solution/SKILL.md`
  - `agent/skills/sdx-solution/assets/solution-session-spec-template.md`
  - `agent/skills/sdx-test/SKILL.md`
  - `agent/skills/sdx-test/assets/test-session-spec-template.md`
  - `scripts/agent-install.sh`

### 2026-04-28 11:18:06.000 · git
- **提交**: `1e6fdb6f4226`
- **作者**: ouliyuan0129
- **信息**: feat(hooks): 为文档技能添加会话闸门与增量写入规范
- **文件**:
  - `agent/hooks.json`
  - `agent/hooks/sdx_gate_common.py`
  - `agent/hooks/sdx_session_gate.py`
  - `agent/hooks/tests/test_sdx_gate_common.py`
  - `agent/rules/CONVENTIONS.md`
  - `agent/skills/agent-guide/SKILL.md`
  - `agent/skills/agent-guide/assets/agents-skeleton.md`
  - `agent/skills/docs-archive/SKILL.md`
  - `agent/skills/docs-archive/reference/workflow-spec.md`
  - `agent/skills/docs-build/SKILL.md`
  - `agent/skills/docs-change/SKILL.md`
  - `agent/skills/docs-change/gotchas.md`
  - `agent/skills/docs-distill/SKILL.md`
  - `agent/skills/docs-extract/SKILL.md`
  - `agent/skills/docs-indexing/SKILL.md`
  - `agent/skills/docs-upgrade/SKILL.md`

### 2026-04-26 18:59:36.000 · git
- **提交**: `7e8a42027efa`
- **作者**: ouliyuan0129
- **信息**: docs(docs-indexing): 更新索引日志机制以增强增量索引的准确性和可追溯性
- **文件**:
  - `index.md`
  - `agent/skills/README.md`
  - `agent/skills/docs-indexing/SKILL.md`
  - `agent/skills/docs-indexing/gotchas.md`
  - `agent/skills/docs-indexing/reference/indexing-log-spec.md`
  - `agent/skills/docs-indexing/reference/quality-standards.md`
  - `agent/skills/docs-indexing/reference/scan-config-onboarding.md`
  - `agent/skills/docs-indexing/reference/scan-spec.md`
  - `agent/skills/docs-indexing/scripts/indexing.sh`
  - `agent/skills/docs-indexing/scripts/indexing_log.py`
  - `company/changelogs/CHANGE-LOG.md`
  - `company/changelogs/INDEXING-LOG.md`
  - `company/changelogs/README.md`
  - `system/application-APPNAME/changelogs/CHANGE-LOG.md`
  - `system/changelogs/CHANGE-LOG.md`
  - `system/changelogs/INDEXING-LOG.md`
  - `system/changelogs/README.md`

### 2026-04-26 18:24:25.000 · git
- **提交**: `4a3e97844886`
- **作者**: ouliyuan0129
- **信息**: docs(AGENTS, index): 更新文档内容以增强可读性和一致性
- **文件**:
  - `AGENTS.md`
  - `index.md`

### 2026-04-25 20:29:06.000 · git
- **提交**: `b2f28688e8fb`
- **作者**: ouliyuan0129
- **信息**: refactor(scripts): 简化配置与文档脚本并修复告警函数调用
- **文件**:
  - `agent/scripts/config-bootstrap.sh`
  - `agent/scripts/docs-core.sh`
  - `agent/scripts/validate-agent-md-links.sh`
  - `scripts/agent-config.sh`
  - `scripts/docs-bootstrap.sh`
  - `scripts/docs-install.sh`
  - `scripts/docs-link.sh`

### 2026-04-25 20:17:16.000 · git
- **提交**: `5264c5d2b3ca`
- **作者**: ouliyuan0129
- **信息**: fix(agent): 修复安装边界并强化 SDX 闸门匹配
- **文件**:
  - `agent/hooks/sdx_gate_common.py`
  - `agent/hooks/tests/test_sdx_gate_common.py`
  - `agent/skills/sdx-design/scripts/validate-design.sh`
  - `agent/skills/sdx-prd/scripts/validate-prd.sh`
  - `scripts/agent-install.sh`

### 2026-04-25 19:51:08.000 · git
- **提交**: `1638cb1803b7`
- **作者**: ouliyuan0129
- **信息**: refactor(agent-install): 重构为单实体存储加符号链接架构
- **文件**:
  - `agent/hooks.json`
  - `agent/skills/docs-distill/scripts/run-docs-distill.sh`
  - `agent/skills/sdx-design/scripts/validate-design.sh`
  - `agent/skills/sdx-prd/scripts/validate-prd.sh`
  - `scripts/agent-install.sh`

### 2026-04-25 18:21:03.000 · git
- **提交**: `6b43452d0270`
- **作者**: ouliyuan0129
- **信息**: docs(agent-guide): 更新 SKILL.md 文件，优化描述和结构
- **文件**:
  - `agent/skills/agent-guide/SKILL.md`

### 2026-04-25 17:12:46.000 · git
- **提交**: `791861be8e28`
- **作者**: ouliyuan0129
- **信息**: docs(docs-build): 重构技能文档以增强可读性和导航性
- **文件**:
  - `index.md`
  - `agent/skills/docs-build/SKILL.md`

### 2026-04-25 16:38:43.000 · git
- **提交**: `064685d6e551`
- **作者**: ouliyuan0129
- **信息**: merge: 合并 feature-1.2.0 到 main

### 2026-04-25 16:37:16.000 · git
- **提交**: `65e4160f2dab`
- **作者**: ouliyuan0129
- **信息**: feat(company): 初始化公司知识库架构文档与变更日志
- **文件**:
  - `README.md`
  - `company/README.md`
  - `company/analysis/README.md`
  - `company/analysis/analysis_meta.yaml`
  - `company/architecture/ARCHITECTURE-OVERVIEW.md`
  - `company/architecture/application/README.md`
  - `company/architecture/application/application-adr.md`
  - `company/architecture/application/application-domain-capability.md`
  - `company/architecture/application/application-domain-model.md`
  - `company/architecture/application/application-integration.md`
  - `company/architecture/application/application-inter-service.md`
  - `company/architecture/application/application-interface-management.md`
  - `company/architecture/application/application-landscape.md`
  - `company/architecture/application/application-multi-tenant-environment.md`
  - `company/architecture/application/application-overview.md`
  - `company/architecture/application/application-service-design.md`
  - `company/architecture/business/README.md`
  - `company/architecture/business/business-capability-map.md`
  - `company/architecture/business/business-domain.md`
  - `company/architecture/business/business-glossary.md`
  - `company/architecture/business/business-model-and-value-chain.md`
  - `company/architecture/business/business-overview.md`
  - `company/architecture/business/business-processes.md`
  - `company/architecture/business/business-roles-and-organization.md`
  - `company/architecture/business/business-rules-and-strategies.md`
  - `company/architecture/data/README.md`
  - `company/architecture/data/data-analytics.md`
  - `company/architecture/data/data-flow.md`
  - `company/architecture/data/data-governance.md`
  - `company/architecture/data/data-model.md`
  - … 另有 39 个文件

### 2026-04-25 16:13:35.000 · git
- **提交**: `e0e23c91f428`
- **作者**: ouliyuan0129
- **信息**: docs: 更新文档索引与指南，记录全库索引运行
- **文件**:
  - `AGENTS.md`
  - `index.md`
  - `README.md`

### 2026-04-25 14:08:58.000 · git
- **提交**: `bd3d34edbea7`
- **作者**: ouliyuan0129
- **信息**: docs: 为文档技能参考文件添加目录并重构蒸馏日志机制
- **文件**:
  - `agent/skills/docs-archive/SKILL.md`
  - `agent/skills/docs-archive/evals/evals.json`
  - `agent/skills/docs-archive/reference/gates-and-links.md`
  - `agent/skills/docs-archive/reference/quality-checklist.md`
  - `agent/skills/docs-archive/reference/workflow-spec.md`
  - `agent/skills/docs-distill/SKILL.md`
  - `agent/skills/docs-distill/evals/evals.json`
  - `agent/skills/docs-distill/gotchas.md`
  - `agent/skills/docs-distill/reference/distill-log-spec.md`
  - `agent/skills/docs-distill/reference/distill-spec.md`
  - `agent/skills/docs-distill/reference/federation-spec.md`
  - `agent/skills/docs-distill/reference/interaction-gate.md`
  - `agent/skills/docs-distill/scripts/append-change-log.sh`
  - `agent/skills/docs-distill/scripts/run-docs-distill.sh`
  - `agent/skills/docs-distill/scripts/update-archive-log.sh`
  - `agent/skills/docs-extract/SKILL.md`
  - `agent/skills/docs-extract/evals/evals.json`
  - `agent/skills/docs-extract/reference/extract-spec.md`
  - `agent/skills/docs-extract/reference/interaction-gate.md`

### 2026-04-24 12:13:20.000 · git
- **提交**: `18ab8b62d9e9`
- **作者**: ouliyuan0129
- **信息**: docs(agent/skills): 统一规范知识归档中来源信息的处理方式
- **文件**:
  - `agent/skills/docs-archive/SKILL.md`
  - `agent/skills/docs-archive/gotchas.md`
  - `agent/skills/docs-archive/reference/workflow-spec.md`
  - `agent/skills/docs-distill/SKILL.md`
  - `agent/skills/docs-distill/scripts/run-docs-distill.sh`
  - `agent/skills/docs-extract/SKILL.md`
  - `agent/skills/docs-extract/reference/extract-spec.md`

### 2026-04-22 17:57:36.000 · git
- **提交**: `6882d6230f75`
- **作者**: ouliyuan0129
- **信息**: docs: 重命名文档文件以统一命名规范
- **文件**:
  - `agent/skills/docs-archive/SKILL.md`
  - `agent/skills/docs-archive/assets/archive-template.md`
  - `agent/skills/docs-archive/reference/workflow-spec.md`
  - `agent/skills/docs-distill/SKILL.md`
  - `agent/skills/docs-distill/reference/README.md`
  - `agent/skills/docs-distill/reference/distill-log-spec.md`
  - `agent/skills/docs-distill/reference/distill-spec.md`
  - `agent/skills/docs-distill/reference/interaction-gate.md`

### 2026-04-22 17:50:52.000 · git
- **提交**: `38ddad9747c2`
- **作者**: ouliyuan0129
- **信息**: docs(docs-archive): 完善归档流程中的来源清理策略
- **文件**:
  - `README.md`
  - `agent/skills/docs-archive/SKILL.md`
  - `agent/skills/docs-archive/assets/distill-scheme-template.md`
  - `agent/skills/docs-archive/gotchas.md`
  - `agent/skills/docs-archive/reference/quality-checklist.md`
  - `agent/skills/docs-archive/reference/workflow-spec.md`

### 2026-04-22 15:56:23.000 · git
- **提交**: `f12fac3b4de9`
- **作者**: ouliyuan0129
- **信息**: refactor(agent): rename docs-archive to docs-distill and swap skill responsibilities
- **文件**:
  - `AGENTS.md`
  - `index.md`
  - `README.md`
  - `agent/hooks/README.md`
  - `agent/rules/CONVENTIONS.md`
  - `agent/skills/README.md`
  - `agent/skills/docs-archive/SKILL.md`
  - `agent/skills/docs-archive/assets/distill-scheme-template.md`
  - `agent/skills/docs-archive/gotchas.md`
  - `agent/skills/docs-archive/reference/gates-and-links.md`
  - `agent/skills/docs-archive/reference/quality-checklist.md`
  - `agent/skills/docs-archive/reference/workflow-spec.md`
  - `agent/skills/docs-distill/SKILL.md`
  - `agent/skills/docs-distill/gotchas.md`
  - `agent/skills/docs-distill/reference/README.md`
  - `agent/skills/docs-distill/reference/archive-log-spec.md`
  - `agent/skills/docs-distill/reference/archive-spec.md`
  - `agent/skills/docs-distill/reference/federation-spec.md`
  - `agent/skills/docs-distill/reference/interaction-gate.md`
  - `agent/skills/docs-distill/scripts/append-change-log.sh`
  - `agent/skills/docs-distill/scripts/run-docs-distill.sh`
  - `agent/skills/docs-distill/scripts/update-archive-log.sh`
  - `agent/skills/docs-extract/SKILL.md`
  - `agent/skills/docs-extract/reference/extract-spec.md`
  - `agent/skills/docs-extract/reference/interaction-gate.md`
  - `agent/skills/docs-fetch/SKILL.md`
  - `application/README-c.md`
  - `application/README-s.md`
  - `system/DESIGN.md`
  - `system/application-APPNAME/changelogs/CHANGE-LOG.md`

### 2026-04-22 12:00:55.000 · git
- **提交**: `17d5e235b5d9`
- **作者**: ouliyuan0129
- **信息**: docs: 更新 README 中的脚本命令和描述
- **文件**:
  - `README.md`

### 2026-04-21 20:15:40.000 · git
- **提交**: `76d72f97b559`
- **作者**: ouliyuan0129
- **信息**: feat(docs-extract): 新增文档提炼技能及相关规范
- **文件**:
  - `AGENTS.md`
  - `README.md`
  - `agent/skills/README.md`
  - `agent/skills/docs-extract/SKILL.md`
  - `agent/skills/docs-extract/gotchas.md`
  - `agent/skills/docs-extract/reference/extract-spec.md`
  - `agent/skills/docs-extract/reference/interaction-gate.md`

### 2026-04-21 19:27:34.000 · git
- **提交**: `1d2c95f53383`
- **作者**: ouliyuan0129
- **信息**: fix: 将 trea 重命名为 trae 以修正拼写错误
- **文件**:
  - `README.md`
  - `scripts/agent-config.sh`
  - `scripts/agent-install.sh`
  - `scripts/docs-bootstrap.sh`

### 2026-04-21 19:05:55.000 · git
- **提交**: `8e727da7d3ef`
- **作者**: ouliyuan0129
- **信息**: fix(docs-init): make docs-config idempotent
- **文件**:
  - `scripts/docs-config.sh`
  - `scripts/docs-install.sh`

### 2026-04-21 18:18:12.000 · git
- **提交**: `e2580fef86eb`
- **作者**: ouliyuan0129
- **信息**: feat(bootstrap): 重构交互引导，支持 docs-install + agent-install 串联执行
- **文件**:
  - `scripts/agent-config.sh`
  - `scripts/docs-bootstrap.sh`

### 2026-04-21 14:36:14.000 · git
- **提交**: `c0ad695cedb4`
- **作者**: ouliyuan0129
- **信息**: docs: 更新归档文档，新增 overview 文件生成与提炼规则
- **文件**:
  - `agent/skills/docs-archive/SKILL.md`
  - `agent/skills/docs-archive/gotchas.md`
  - `agent/skills/docs-archive/reference/archive-spec.md`
  - `agent/skills/docs-archive/reference/federation-spec.md`
  - `agent/skills/docs-archive/reference/interaction-gate.md`
  - `agent/skills/docs-archive/scripts/run-docs-archive.sh`
  - `system/architecture/business/README.md`
  - `system/architecture/overview/NAME-overview.md`

### 2026-04-20 15:36:59.000 · git
- **提交**: `706cf0f76aba`
- **作者**: ouliyuan0129
- **信息**: docs: 更新架构文档，新增各目录入口说明
- **文件**:
  - `system/architecture/data/README.md`
  - `system/architecture/product/README.md`
  - `system/architecture/technical/README.md`

### 2026-04-20 15:02:00.000 · git
- **提交**: `cc2deaee8c18`
- **作者**: ouliyuan0129
- **信息**: docs: 重构架构文档，整合与更新应用、业务、数据、产品与技术架构
- **文件**:
  - `system/architecture/APPLICATION-ARCHITECTURE.md`
  - `system/architecture/ARCHITECTURE-OVERVIEW.md`
  - `system/architecture/BUSINESS-ARCHITECTURE.md`
  - `system/architecture/DATA-ARCHITECTURE.md`
  - `system/architecture/OVERVIEW.md`
  - `system/architecture/PRODUCT-ARCHITECTURE.md`
  - `system/architecture/README.md`
  - `system/architecture/TECHNICAL-ARCHITECTURE.md`
  - `system/architecture/application/README.md`
  - `system/architecture/application/application-adr.md`
  - `system/architecture/application/application-domain-capability.md`
  - `system/architecture/application/application-domain-model.md`
  - `system/architecture/application/application-integration.md`
  - `system/architecture/application/application-inter-service.md`
  - `system/architecture/application/application-interface-management.md`
  - `system/architecture/application/application-landscape.md`
  - `system/architecture/application/application-multi-tenant-environment.md`
  - `system/architecture/application/application-overview.md`
  - `system/architecture/application/application-service-design.md`
  - `system/architecture/business/README.md`
  - `system/architecture/business/business-capability-map.md`
  - `system/architecture/business/business-domain.md`
  - `system/architecture/business/business-glossary.md`
  - `system/architecture/business/business-model-and-value-chain.md`
  - `system/architecture/business/business-overview.md`
  - `system/architecture/business/business-processes.md`
  - `system/architecture/business/business-roles-and-organization.md`
  - `system/architecture/business/business-rules-and-strategies.md`
  - `system/architecture/data/README.md`
  - `system/architecture/data/data-analytics.md`
  - … 另有 28 个文件

### 2026-04-19 20:17:41.000 · git
- **提交**: `62411c382850`
- **作者**: ouliyuan0129
- **信息**: feat(docs-tag): 新增文档标记技能及相关文档
- **文件**:
  - `agent/skills/docs-tag/SKILL.md`
  - `agent/skills/docs-tag/gotchas.md`
  - `agent/skills/docs-tag/reference/algorithm.md`
  - `agent/skills/docs-tag/scripts/keyword_tag.py`
  - `agent/skills/docs-tag/tests/__init__.py`
  - `agent/skills/docs-tag/tests/test_integration.py`
  - `agent/skills/docs-tag/tests/test_properties.py`
  - `agent/skills/docs-tag/tests/test_unit.py`

### 2026-04-18 09:59:38.000 · git
- **提交**: `bbcb42499002`
- **作者**: ouliyuan0129
- **信息**: chore(scripts): 优化 agent 路径重写扫描与安装日志
- **文件**:
  - `agent/scripts/docs-core.sh`
  - `scripts/agent-install.sh`

### 2026-04-18 09:59:35.000 · git
- **提交**: `55f9f18e38b9`
- **作者**: ouliyuan0129
- **信息**: feat(docs): 增强 docs-distill 来源-目标简写与触发词
- **文件**:
  - `agent/skills/README.md`
  - `agent/skills/docs-distill/SKILL.md`
  - `agent/skills/docs-distill/gotchas.md`
  - `agent/skills/docs-distill/reference/workflow-spec.md`

### 2026-04-18 09:43:15.000 · git
- **提交**: `125157b644d9`
- **作者**: ouliyuan0129
- **信息**: feat(skills): 新增 /docs-distill 知识蒸馏技能并更新索引
- **文件**:
  - `AGENTS.md`
  - `README.md`
  - `agent/skills/README.md`
  - `agent/skills/docs-distill/SKILL.md`
  - `agent/skills/docs-distill/assets/distill-scheme-template.md`
  - `agent/skills/docs-distill/gotchas.md`
  - `agent/skills/docs-distill/reference/gates-and-links.md`
  - `agent/skills/docs-distill/reference/quality-checklist.md`
  - `agent/skills/docs-distill/reference/workflow-spec.md`

### 2026-04-18 08:53:32.000 · git
- **提交**: `899b8e378ea8`
- **作者**: ouliyuan0129
- **信息**: docs: 更新架构文档，增强结构与可读性
- **文件**:
  - `system/README.md`
  - `system/architecture/README.md`

### 2026-04-18 08:51:05.000 · git
- **提交**: `1ee4ffaae4e4`
- **作者**: ouliyuan0129
- **信息**: docs: 新增架构文档，整合应用、业务、数据、产品与技术架构
- **文件**:
  - `system/architecture/APPLICATION-ARCHITECTURE.md`
  - `system/architecture/BUSINESS-ARCHITECTURE.md`
  - `system/architecture/DATA-ARCHITECTURE.md`
  - `system/architecture/OVERVIEW.md`
  - `system/architecture/PRODUCT-ARCHITECTURE.md`
  - `system/architecture/SYSTEM-ARCHITECTURE.md`
  - `system/architecture/TECHNICAL-ARCHITECTURE.md`

### 2026-04-17 11:31:45.000 · git
- **提交**: `2ae242dd380d`
- **作者**: ouliyuan0129
- **信息**: docs: 按 GitHub 专业规范重写 README 并精简 Git 提交确认规则
- **文件**:
  - `README.md`
  - `agent/rules/coding/git-guidelines.md`

### 2026-04-17 10:37:33.000 · git
- **提交**: `e9bdf5691290`
- **作者**: ouliyuan0129
- **信息**: refactor(scripts): 统一日志函数为 sdx_* 前缀，修复 bootstrap 语法错误
- **文件**:
  - `agent/scripts/docs-core.sh`
  - `scripts/agent-install.sh`
  - `scripts/docs-bootstrap.sh`
  - `scripts/docs-install.sh`
  - `scripts/docs-link.sh`

### 2026-04-16 16:11:52.000 · git
- **提交**: `f04fabe5db9b`
- **作者**: ouliyuan0129
- **信息**: 新增 SDX 会话激活钩子和状态管理功能，优化 preToolUse 钩子的逻辑。更新 hooks.json 配置以包含新钩子，完善 README.md 文档以说明新功能和使用语义。此更新旨在提升会话管理的灵活性与准确性，确保用户在使用过程中获得更好的支持。
- **文件**:
  - `agent/hooks.json`
  - `agent/hooks/README.md`
  - `agent/hooks/sdx_gate_common.py`
  - `agent/hooks/sdx_session_gate.py`
  - `agent/hooks/sdx_session_state.py`
  - `scripts/agent-install.sh`

### 2026-04-16 15:41:11.000 · git
- **提交**: `c1b476969b47`
- **作者**: ouliyuan0129
- **信息**: 更新 README.md 和 agent/hooks.json，调整钩子配置路径以反映最新结构变更。新增 agent/hooks.json 文件以集中管理钩子配置，并在相关文档中更新引用路径，确保一致性与清晰度。此更新旨在提升文档的可读性与维护性。
- **文件**:
  - `README.md`
  - `agent/hooks.json`
  - `agent/hooks/README.md`
  - `agent/skills/sdx-analysis/SKILL.md`
  - `agent/skills/sdx-design/SKILL.md`
  - `agent/skills/sdx-prd/SKILL.md`
  - `agent/skills/sdx-solution/SKILL.md`
  - `agent/skills/sdx-test/SKILL.md`
  - `scripts/README.md`
  - `scripts/agent-install.sh`

### 2026-04-15 18:22:14.000 · git
- **提交**: `38e3c8bac506`
- **作者**: ouliyuan0129
- **信息**: merge: 合并 features/feature-1.0.0-federated-docs 到 main

### 2026-04-15 18:18:46.000 · git
- **提交**: `b31e027ee37c`
- **作者**: ouliyuan0129
- **信息**: 更新 AGENTS.md、README.md、公司与系统知识库设计文档，优化结构与内容
- **文件**:
  - `AGENTS.md`
  - `README.md`
  - `company/DESIGN.md`
  - `system/DESIGN.md`

### 2026-04-15 12:29:05.000 · git
- **提交**: `866c590e875e`
- **作者**: ouliyuan0129
- **信息**: 重构文档备份逻辑，增强知识库管理功能
- **文件**:
  - `agent/scripts/docs-core.sh`
  - `scripts/README.md`
  - `scripts/docs-install.sh`
  - `scripts/docs-link.sh`

### 2026-04-15 12:22:00.000 · git
- **提交**: `6948927a64d8`
- **作者**: ouliyuan0129
- **信息**: 新增知识库建联清单文件及更新 docs-link.sh 脚本
- **文件**:
  - `company/knowledge-links.yaml`
  - `scripts/docs-link.sh`
  - `system/knowledge-links.yaml`

### 2026-04-15 12:00:37.000 · git
- **提交**: `a1223ad1126e`
- **作者**: ouliyuan0129
- **信息**: 增强 docs-link.sh 脚本的知识库路径管理功能
- **文件**:
  - `scripts/docs-link.sh`

### 2026-04-15 11:52:53.000 · git
- **提交**: `f4b4060e1a6b`
- **作者**: ouliyuan0129
- **信息**: 重构文档安装脚本，增强知识库路径重写功能
- **文件**:
  - `agent/scripts/docs-core.sh`
  - `scripts/README.md`
  - `scripts/agent-install.sh`
  - `scripts/docs-install.sh`
  - `scripts/docs-link.sh`
  - `scripts/link-config.sh`
  - `scripts/tests/docs-install/cases/08_knowledge_rewrites_agent_paths.sh`
  - `scripts/tests/docs-install/cases/09_standalone_full_installs_nested_readme.sh`
  - `scripts/tests/docs-install/test-lib.sh`

### 2026-04-14 16:31:09.000 · git
- **提交**: `5a135c818f7d`
- **作者**: ouliyuan0129
- **信息**: 更新文档与脚本，优化知识库安装与配置流程
- **文件**:
  - `index.md`
  - `README.md`
  - `agent/hooks/hooks.json`
  - `scripts/README.md`
  - `scripts/agent-install.sh`
  - `scripts/docs-config.sh`
  - `scripts/docs-install.sh`
  - `scripts/link-config.sh`
  - `scripts/tests/docs-install/cases/01_scope_config_docsconfig.sh`
  - `scripts/tests/docs-install/cases/02_scope_knowledge_no_docsconfig.sh`
  - `scripts/tests/docs-install/cases/05_knowledge_system_installs_link_scripts.sh`
  - `scripts/tests/docs-install/cases/06_knowledge_company_installs_link_scripts.sh`
  - `scripts/tests/docs-install/cases/07_agent_install_recompute_agent_fields.sh`
  - `scripts/tests/docs-install/test-lib.sh`

### 2026-04-14 11:32:06.000 · git
- **提交**: `2bd1590b7c83`
- **作者**: ouliyuan0129
- **信息**: 更新 AGENTS.md、index.md 和 README.md，删除 APPLICATIONS_INDEX.md 和 applications/README.md
- **文件**:
  - `AGENTS.md`
  - `index.md`
  - `README.md`
  - `agent/skills/README.md`
  - `applications/APPLICATIONS_INDEX.md`
  - `applications/README.md`

### 2026-04-14 11:15:01.000 · git
- **提交**: `d1ac86ba34f7`
- **作者**: ouliyuan0129
- **信息**: 更新 AGENTS.md、README.md 和 APPLICATIONS_INDEX.md，调整文档结构与内容
- **文件**:
  - `AGENTS.md`
  - `README.md`
  - `applications/APPLICATIONS_INDEX.md`
  - `applications/README.md`

### 2026-04-14 11:03:41.000 · git
- **提交**: `bd01476e3953`
- **作者**: ouliyuan0129
- **信息**: 更新 index.md，重构为九章结构并补充项目概览与架构视图，增强文档导航与可读性。同时，更新 CHANGE-LOG.md 和 INDEXING-LOG.md，记录与 docs-indexing 的联动变更及索引统计信息，确保文档维护的准确性与一致性。
- **文件**:
  - `index.md`
  - `agent/README.md`

### 2026-04-14 10:42:10.000 · git
- **提交**: `f1b839ddca69`
- **作者**: ouliyuan0129
- **信息**: 新增统一的钩子配置与逻辑，整合多个写入闸门脚本为 `sdx_gate_common.py`，并在 `hooks.json` 中注册。更新相关文档以反映新结构，确保用户在使用时获得一致的体验。删除冗余的单独闸门脚本，提升可维护性。
- **文件**:
  - `agent/hooks/README.md`
  - `agent/hooks/hooks.json`
  - `agent/hooks/sdx-analysis-gate-write.py`
  - `agent/hooks/sdx-design-gate-write.py`
  - `agent/hooks/sdx-prd-gate-write.py`
  - `agent/hooks/sdx-solution-gate-write.py`
  - `agent/hooks/sdx-test-gate-write.py`
  - `agent/hooks/sdx_gate_common.py`
  - `agent/skills/sdx-analysis/SKILL.md`
  - `agent/skills/sdx-design/SKILL.md`
  - `agent/skills/sdx-prd/SKILL.md`
  - `agent/skills/sdx-solution/SKILL.md`
  - `agent/skills/sdx-test/SKILL.md`
  - `scripts/README.md`
  - `scripts/agent-install.sh`

### 2026-04-14 10:33:17.000 · git
- **提交**: `aef9bc57262f`
- **作者**: ouliyuan0129
- **信息**: 更新 AGENTS.md、CONVENTIONS.md 和相关文档，整合文档产出闸门规则
- **文件**:
  - `AGENTS.md`
  - `agent/hooks/README.md`
  - `agent/rules/CONVENTIONS.md`
  - `agent/rules/docs-archive.md`
  - `agent/rules/sdx-analysis.md`
  - `agent/rules/sdx-design.md`
  - `agent/rules/sdx-prd.md`
  - `agent/rules/sdx-solution.md`
  - `agent/rules/sdx-test.md`
  - `agent/skills/docs-archive/reference/interaction-gate.md`

### 2026-04-14 10:30:40.000 · git
- **提交**: `91413c88c67a`
- **作者**: ouliyuan0129
- **信息**: 更新 git-guidelines.md，优化用户确认流程与提交说明
- **文件**:
  - `agent/rules/coding/git-guidelines.md`

### 2026-04-14 10:19:20.000 · git
- **提交**: `01390760ee87`
- **作者**: ouliyuan0129
- **信息**: 更新文档与脚本，新增 docs-link.sh 脚本以支持知识库登记与注销
- **文件**:
  - `index.md`
  - `README.md`
  - `scripts/README.md`
  - `scripts/docs-link.sh`
  - `scripts/link-config.sh`

### 2026-04-14 10:18:00.000 · git
- **提交**: `180bd1c454c9`
- **作者**: ouliyuan0129
- **信息**: 更新文档与脚本，统一配置管理
- **文件**:
  - `index.md`
  - `scripts/README.md`
  - `scripts/docs-config.sh`
  - `scripts/docs-install.sh`

### 2026-04-14 10:13:54.000 · git
- **提交**: `8c722edc750b`
- **作者**: ouliyuan0129
- **信息**: 更新文档，调整脚本引用以统一配置管理
- **文件**:
  - `index.md`
  - `agent/README.md`
  - `agent/scripts/config-bootstrap.sh`
  - `agent/scripts/docs-core.sh`
  - `scripts/README.md`
  - `scripts/agent-config.sh`
  - `scripts/agent-install.sh`
  - `scripts/docs-bootstrap.sh`
  - `scripts/knowledge-config.sh`
  - `scripts/link-config.sh`

### 2026-04-14 10:13:14.000 · git
- **提交**: `e11aed32047c`
- **作者**: ouliyuan0129
- **信息**: refactor(agent): 将 docs-config.sh 重命名为 docs-core.sh
- **文件**:
  - `index.md`
  - `README.md`
  - `agent/scripts/docs-core.sh`
  - `agent/skills/README.md`
  - `agent/skills/docs-fetch/SKILL.md`
  - `agent/skills/docs-fetch/gotchas.md`
  - `agent/skills/docs-fetch/reference/manifest-spec.md`
  - `agent/skills/docs-fetch/scripts/fetch-docs.sh`
  - `application/CONTRIBUTING.md`
  - `application/index.md`
  - `application/README-c.md`
  - `application/README-s.md`
  - `application/README.md`
  - `application/knowledge/README.md`
  - `scripts/README.md`
  - `system/index.md`

### 2026-04-14 10:05:06.000 · git
- **提交**: `02d5ea927373`
- **作者**: ouliyuan0129
- **信息**: 更新文档，调整初始化脚本与配置说明
- **文件**:
  - `AGENTS.md`
  - `index.md`
  - `README.md`
  - `agent/scripts/config-bootstrap.sh`
  - `agent/skills/README.md`
  - `agent/skills/docs-fetch/SKILL.md`
  - `agent/skills/docs-fetch/gotchas.md`
  - `agent/skills/docs-fetch/reference/manifest-spec.md`
  - `agent/skills/docs-fetch/scripts/fetch-docs.sh`
  - `application/index.md`
  - `application/README-c.md`
  - `application/README-s.md`
  - `application/manifest.yaml`
  - `scripts/README.md`
  - `scripts/agent-config.sh`
  - `scripts/agent-install.sh`
  - `scripts/docs-bootstrap.sh`
  - `scripts/docs-install.sh`
  - `scripts/knowledge-config.sh`
  - `scripts/tests/docs-install/cases/01_scope_config_docsconfig.sh`
  - `scripts/tests/docs-install/cases/02_scope_knowledge_no_docsconfig.sh`
  - `scripts/tests/docs-install/cases/03_mode_central_only_application.sh`
  - `scripts/tests/docs-install/cases/04_central_no_registry_side_effect.sh`
  - `scripts/tests/docs-install/run.sh`
  - `scripts/tests/docs-install/test-lib.sh`
  - `system/index.md`
  - `system/solutions/README.md`

### 2026-04-14 09:51:21.000 · git
- **提交**: `8bd5ba297f60`
- **作者**: ouliyuan0129
- **信息**: 更新文档，调整初始化脚本与配置说明
- **文件**:
  - `index.md`
  - `README.md`
  - `agent/scripts/config-bootstrap.sh`
  - `scripts/README.md`
  - `scripts/agent-config.sh`
  - `scripts/agent-install.sh`
  - `system/solutions/README.md`

### 2026-04-14 09:46:48.000 · git
- **提交**: `cea08574ab3f`
- **作者**: ouliyuan0129
- **信息**: 增强 docs-config.sh 脚本功能与文档支持
- **文件**:
  - `agent/scripts/docs-config.sh`
  - `scripts/agent-config.sh`
  - `scripts/docs-bootstrap.sh`
  - `scripts/knowledge-config.sh`
  - `scripts/link-config.sh`

### 2026-04-14 09:33:09.000 · git
- **提交**: `7fe2ea3ead09`
- **作者**: ouliyuan0129
- **信息**: 新增 .gitignore 文件，更新文档以增强用户指导
- **文件**:
  - `.gitignore`
  - `AGENTS.md`
  - `index.md`
  - `README.md`
  - `agent/README.md`
  - `agent/scripts/config-bootstrap.sh`
  - `agent/scripts/docs-config.sh`
  - `agent/scripts/docsconfig-bootstrap.sh`
  - `agent/scripts/validate-agent-md-links.sh`
  - `agent/skills/agent-guide/SKILL.md`
  - `agent/skills/agent-guide/scripts/validate-guide.sh`
  - `agent/skills/docs-build/scripts/validate-extraction.sh`
  - `agent/skills/docs-indexing/scripts/indexing.sh`
  - `agent/skills/sdx-analysis/scripts/validate-analysis.sh`
  - `agent/skills/sdx-design/scripts/validate-design.sh`
  - `agent/skills/sdx-prd/scripts/validate-prd.sh`
  - `agent/skills/sdx-solution/scripts/validate-solution.sh`
  - `agent/skills/sdx-test/scripts/validate-test.sh`
  - `scripts/README.md`
  - `scripts/agent-config.sh`
  - `scripts/agent-init.sh`
  - `scripts/docs-bootstrap.sh`
  - `scripts/docs-config.sh`
  - `scripts/knowledge-config.sh`
  - `scripts/knowledge-init.sh`
  - `scripts/knowledge-link.sh`
  - `scripts/lib/docs-init-core.sh`
  - `scripts/link-config.sh`
  - `scripts/maintain-agent-init.sh`
  - `scripts/tests/knowledge-init/cases/01_scope_config_docsconfig.sh`
  - … 另有 5 个文件

### 2026-04-13 11:41:44.000 · git
- **提交**: `4efe7c28a326`
- **作者**: ouliyuan0129
- **信息**: 更新文档，增强用户指导与规则说明
- **文件**:
  - `AGENTS.md`
  - `index.md`
  - `README.md`
  - `agent/README.md`
  - `agent/hooks.json`
  - `agent/hooks/README.md`
  - `agent/hooks/sdx-analysis-gate-write.py`
  - `agent/hooks/sdx-design-gate-write.py`
  - `agent/hooks/sdx-prd-gate-write.py`
  - `agent/hooks/sdx-solution-gate-write.py`
  - `agent/hooks/sdx-test-gate-write.py`
  - `agent/rules/CONVENTIONS.md`
  - `agent/rules/coding/git-guidelines.md`
  - `agent/rules/coding/java-guidelines.md`
  - `agent/rules/coding/maven-guidelines.md`
  - `agent/rules/coding/project-structure.md`
  - `agent/rules/design/design-guidelines.md`
  - `agent/rules/docs-archive.md`
  - `agent/rules/document/document-guidelines.md`
  - `agent/rules/sdx-analysis.md`
  - `agent/rules/sdx-design.md`
  - `agent/rules/sdx-prd.md`
  - `agent/rules/sdx-solution.md`
  - `agent/rules/sdx-test.md`
  - `agent/rules/testing/testing-guidelines.md`
  - `agent/scripts/docs-config.sh`
  - `agent/scripts/docsconfig-bootstrap.sh`
  - `agent/scripts/validate-agent-md-links.sh`
  - `agent/skills/README.md`
  - `agent/skills/agent-guide/SKILL.md`
  - … 另有 167 个文件

### 2026-04-12 18:03:00.000 · git
- **提交**: `a17ed34398ff`
- **作者**: ouliyuan0129
- **信息**: 更新文档，增强用户指导与常见陷阱说明
- **文件**:
  - `.agent/skills/docs-upgrade/SKILL.md`
  - `.agent/skills/docs-upgrade/gotchas.md`
  - `.agent/skills/docs-upgrade/reference/brainstorming-preflight.md`

### 2026-04-12 18:01:09.000 · git
- **提交**: `f7e1bce8db4f`
- **作者**: ouliyuan0129
- **信息**: 更新文档，增强用户指导与常见陷阱说明
- **文件**:
  - `.agent/skills/docs-fetch/SKILL.md`
  - `.agent/skills/docs-fetch/gotchas.md`

### 2026-04-12 18:00:49.000 · git
- **提交**: `eb00a64b556c`
- **作者**: ouliyuan0129
- **信息**: 更新文档，增强用户指导与常见陷阱说明
- **文件**:
  - `.agent/skills/docs-build/SKILL.md`
  - `.agent/skills/docs-build/gotchas.md`
  - `.agent/skills/docs-build/reference/extraction-rules.md`

### 2026-04-12 17:53:48.000 · git
- **提交**: `1e0ef6d9cf10`
- **作者**: ouliyuan0129
- **信息**: 更新文档，优化用户确认流程与内容引用
- **文件**:
  - `.agent/skills/docs-archive/SKILL.md`
  - `.agent/skills/docs-archive/gotchas.md`
  - `.agent/skills/docs-archive/reference/README.md`

### 2026-04-12 17:51:01.000 · git
- **提交**: `1650af44ba24`
- **作者**: ouliyuan0129
- **信息**: 更新常见陷阱与 SKILL 文档，增强用户确认流程
- **文件**:
  - `.agent/skills/docs-change/SKILL.md`
  - `.agent/skills/docs-change/gotchas.md`

### 2026-04-12 17:13:41.000 · git
- **提交**: `f945b2045785`
- **作者**: ouliyuan0129
- **信息**: docs(docs-archive): 新增文档与规则，优化用户确认流程
- **文件**:
  - `.agent/hooks/README.md`
  - `.agent/rules/docs-archive.md`
  - `.agent/skills/docs-archive/SKILL.md`
  - `.agent/skills/docs-archive/reference/README.md`
  - `.agent/skills/docs-archive/reference/interaction-gate.md`

### 2026-04-12 17:12:14.000 · git
- **提交**: `1060bed40ed8`
- **作者**: ouliyuan0129
- **信息**: docs(gotchas, SKILL): 更新常见陷阱与技能文档，增强用户确认流程
- **文件**:
  - `.agent/skills/docs-indexing/SKILL.md`
  - `.agent/skills/docs-indexing/gotchas.md`

### 2026-04-12 17:11:56.000 · git
- **提交**: `0467c91986cf`
- **作者**: ouliyuan0129
- **信息**: docs(SKILL, preflight): 增加预检文档与相关说明，优化用户确认流程
- **文件**:
  - `.agent/skills/docs-fetch/SKILL.md`
  - `.agent/skills/docs-fetch/reference/preflight.md`

### 2026-04-12 17:11:38.000 · git
- **提交**: `14dbfbf86b25`
- **作者**: ouliyuan0129
- **信息**: docs(SKILL, brainstorming-preflight): 增强文档结构与用户指导，新增预检阶段
- **文件**:
  - `.agent/skills/docs-upgrade/SKILL.md`
  - `.agent/skills/docs-upgrade/reference/brainstorming-preflight.md`

### 2026-04-12 16:50:03.000 · git
- **提交**: `ea5d20fa33b8`
- **作者**: ouliyuan0129
- **信息**: docs(SKILL): 更新工作流，新增预检阶段以优化用户体验
- **文件**:
  - `.agent/skills/docs-build/SKILL.md`

### 2026-04-12 16:49:35.000 · git
- **提交**: `a849e755f127`
- **作者**: ouliyuan0129
- **信息**: docs(agent-guide): 增强需求对齐与路径选择流程，优化用户体验
- **文件**:
  - `.agent/skills/agent-guide/SKILL.md`
  - `.agent/skills/agent-guide/gotchas.md`
  - `.agent/skills/agent-guide/reference/execution-spec.md`

### 2026-04-12 16:48:58.000 · git
- **提交**: `339339edad64`
- **作者**: ouliyuan0129
- **信息**: docs(SKILL, execution-spec): 增强前置确认与歧义处理流程，优化用户体验
- **文件**:
  - `.agent/skills/docs-change/SKILL.md`
  - `.agent/skills/docs-change/reference/execution-spec.md`

### 2026-04-12 16:38:58.000 · git
- **提交**: `f577f480dfe3`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-test): 更新常见陷阱文档，增强结构与可读性
- **文件**:
  - `.agent/skills/sdx-test/SKILL.md`
  - `.agent/skills/sdx-test/gotchas.md`
  - `.agent/skills/sdx-test/reference/brainstorming-integration.md`
  - `.agent/skills/sdx-test/reference/core-concepts.md`
  - `.agent/skills/sdx-test/reference/design-principles.md`
  - `.agent/skills/sdx-test/reference/workflow-spec.md`

### 2026-04-12 16:36:32.000 · git
- **提交**: `5bc6b0f4afd2`
- **作者**: ouliyuan0129
- **信息**: docs(docs-indexing): 增强扫描配置文档，添加便捷预设与汇总提问
- **文件**:
  - `.agent/skills/docs-indexing/SKILL.md`
  - `.agent/skills/docs-indexing/gotchas.md`
  - `.agent/skills/docs-indexing/reference/scan-config-onboarding.md`

### 2026-04-12 16:34:47.000 · git
- **提交**: `f27b46630c27`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-analysis, sdx-design, sdx-solution): 重构常见陷阱文档，增强结构与可读性
- **文件**:
  - `.agent/skills/sdx-analysis/gotchas.md`
  - `.agent/skills/sdx-analysis/reference/brainstorming-integration.md`
  - `.agent/skills/sdx-analysis/reference/core-concepts.md`
  - `.agent/skills/sdx-analysis/reference/workflow-spec.md`
  - `.agent/skills/sdx-design/SKILL.md`
  - `.agent/skills/sdx-design/gotchas.md`
  - `.agent/skills/sdx-design/reference/brainstorming-integration.md`
  - `.agent/skills/sdx-design/reference/core-concepts.md`
  - `.agent/skills/sdx-design/reference/design-principles.md`
  - `.agent/skills/sdx-design/reference/workflow-spec.md`
  - `.agent/skills/sdx-solution/gotchas.md`
  - `.agent/skills/sdx-solution/reference/brainstorming-integration.md`
  - `.agent/skills/sdx-solution/reference/core-concepts.md`
  - `.agent/skills/sdx-solution/reference/workflow-spec.md`

### 2026-04-12 16:17:10.000 · git
- **提交**: `25775f6f85e5`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-prd): 更新常见陷阱文档，增强结构与可读性
- **文件**:
  - `.agent/skills/sdx-prd/SKILL.md`
  - `.agent/skills/sdx-prd/gotchas.md`
  - `.agent/skills/sdx-prd/reference/audience-and-language.md`
  - `.agent/skills/sdx-prd/reference/brainstorming-integration.md`
  - `.agent/skills/sdx-prd/reference/core-concepts.md`
  - `.agent/skills/sdx-prd/reference/design-principles.md`
  - `.agent/skills/sdx-prd/reference/quality-checklist.md`
  - `.agent/skills/sdx-prd/reference/workflow-spec.md`

### 2026-04-12 16:14:11.000 · git
- **提交**: `73a248c85f61`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-design): 新增设计阶段文档与钩子，强化写入控制
- **文件**:
  - `.agent/hooks.json`
  - `.agent/hooks/README.md`
  - `.agent/hooks/sdx-design-gate-write.py`
  - `.agent/rules/sdx-design.md`
  - `.agent/skills/sdx-design/SKILL.md`
  - `.agent/skills/sdx-design/assets/design-session-spec-template.md`
  - `.agent/skills/sdx-design/gotchas.md`
  - `.agent/skills/sdx-design/reference/brainstorming-integration.md`
  - `.agent/skills/sdx-design/reference/core-concepts.md`
  - `.agent/skills/sdx-design/reference/quality-checklist.md`
  - `.agent/skills/sdx-design/reference/workflow-spec.md`
  - `.agent/skills/sdx-design/scripts/validate-design.sh`
  - `AGENTS.md`

### 2026-04-12 16:08:48.000 · git
- **提交**: `f6a3534e2388`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-test): 新增测试设计阶段文档与钩子，强化写入控制
- **文件**:
  - `.agent/hooks.json`
  - `.agent/hooks/README.md`
  - `.agent/hooks/sdx-test-gate-write.py`
  - `.agent/rules/sdx-test.md`
  - `.agent/skills/README.md`
  - `.agent/skills/sdx-test/SKILL.md`
  - `.agent/skills/sdx-test/assets/test-session-spec-template.md`
  - `.agent/skills/sdx-test/gotchas.md`
  - `.agent/skills/sdx-test/reference/brainstorming-integration.md`
  - `.agent/skills/sdx-test/reference/design-principles.md`
  - `.agent/skills/sdx-test/reference/quality-checklist.md`
  - `.agent/skills/sdx-test/reference/workflow-spec.md`
  - `.agent/skills/sdx-test/scripts/validate-test.sh`
  - `AGENTS.md`

### 2026-04-12 15:58:41.000 · git
- **提交**: `5c6141e353b8`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-prd): 添加 PRD 阶段文档与钩子，增强写入控制
- **文件**:
  - `.agent/hooks.json`
  - `.agent/hooks/README.md`
  - `.agent/hooks/sdx-prd-gate-write.py`
  - `.agent/rules/sdx-prd.md`
  - `.agent/skills/README.md`
  - `.agent/skills/sdx-prd/SKILL.md`
  - `.agent/skills/sdx-prd/assets/prd-session-spec-template.md`
  - `.agent/skills/sdx-prd/gotchas.md`
  - `.agent/skills/sdx-prd/reference/brainstorming-integration.md`
  - `.agent/skills/sdx-prd/reference/core-concepts.md`
  - `.agent/skills/sdx-prd/reference/workflow-spec.md`
  - `.agent/skills/sdx-prd/scripts/validate-prd.sh`

### 2026-04-12 13:46:54.000 · git
- **提交**: `049fe4bde6cb`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-analysis): 重构常见陷阱与反模式文档，增强结构与可读性
- **文件**:
  - `.agent/skills/sdx-analysis/SKILL.md`
  - `.agent/skills/sdx-analysis/gotchas.md`
  - `.agent/skills/sdx-analysis/reference/audience-and-language.md`
  - `.agent/skills/sdx-analysis/reference/brainstorming-integration.md`
  - `.agent/skills/sdx-analysis/reference/core-concepts.md`
  - `.agent/skills/sdx-analysis/reference/design-principles.md`
  - `.agent/skills/sdx-analysis/reference/quality-checklist.md`
  - `.agent/skills/sdx-analysis/reference/workflow-spec.md`

### 2026-04-12 13:40:38.000 · git
- **提交**: `089c1aa71491`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-analysis): 更新文档结构与术语，增强可读性与一致性
- **文件**:
  - `.agent/hooks.json`
  - `.agent/hooks/README.md`
  - `.agent/hooks/sdx-solution-gate-write.py`
  - `.agent/rules/sdx-analysis.md`
  - `.agent/rules/sdx-solution.md`
  - `.agent/skills/sdx-analysis/SKILL.md`
  - `.agent/skills/sdx-analysis/assets/analysis-session-spec-template.md`
  - `.agent/skills/sdx-analysis/gotchas.md`
  - `.agent/skills/sdx-analysis/reference/audience-and-language.md`
  - `.agent/skills/sdx-analysis/reference/brainstorming-integration.md`
  - `.agent/skills/sdx-analysis/reference/core-concepts.md`
  - `.agent/skills/sdx-analysis/reference/design-principles.md`
  - `.agent/skills/sdx-analysis/reference/quality-checklist.md`
  - `.agent/skills/sdx-analysis/reference/workflow-spec.md`
  - `.agent/skills/sdx-analysis/scripts/validate-analysis.sh`
  - `.agent/skills/sdx-solution/scripts/validate-solution.sh`
  - `AGENTS.md`
  - `index.md`
  - `application/analysis/README.md`
  - `application/solutions/README.md`
  - `system/analysis/README.md`
  - `system/solutions/README.md`

### 2026-04-12 13:22:11.000 · git
- **提交**: `ab4451cc6323`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-solution): 更新 gotchas、SKILL 文档与新增 brainstorming 集成参考
- **文件**:
  - `.agent/skills/sdx-solution/SKILL.md`
  - `.agent/skills/sdx-solution/assets/solution-session-spec-template.md`
  - `.agent/skills/sdx-solution/gotchas.md`
  - `.agent/skills/sdx-solution/reference/brainstorming-integration.md`
  - `.agent/skills/sdx-solution/reference/workflow-spec.md`

### 2026-04-12 11:44:12.000 · git
- **提交**: `26df35bc76ed`
- **作者**: ouliyuan0129
- **信息**: docs(git-guidelines): 更新提交格式规范与语言要求
- **文件**:
  - `.agent/rules/coding/git-guidelines.md`

### 2026-04-12 11:41:59.000 · git
- **提交**: `45988a2942f6`
- **作者**: ouliyuan0129
- **信息**: refactor(sdx-solution): 更新常见陷阱与反模式文档结构
- **文件**:
  - `.agent/skills/sdx-solution/SKILL.md`
  - `.agent/skills/sdx-solution/gotchas.md`
  - `.agent/skills/sdx-solution/reference/audience-and-language.md`
  - `.agent/skills/sdx-solution/reference/core-concepts.md`
  - `.agent/skills/sdx-solution/reference/design-principles.md`
  - `.agent/skills/sdx-solution/reference/workflow-spec.md`

### 2026-04-12 11:12:15.000 · git
- **提交**: `1c4e7ccad609`
- **作者**: ouliyuan0129
- **信息**: refactor(sdx-solution): update terminology and structure for clarity
- **文件**:
  - `.agent/skills/sdx-solution/SKILL.md`
  - `.agent/skills/sdx-solution/assets/solution-session-spec-template.md`
  - `.agent/skills/sdx-solution/gotchas.md`
  - `.agent/skills/sdx-solution/reference/core-concepts.md`
  - `.agent/skills/sdx-solution/reference/workflow-spec.md`
  - `.agent/skills/sdx-solution/scripts/validate-solution.sh`

### 2026-04-12 01:40:54.000 · git
- **提交**: `bcf2d4156060`
- **作者**: ouliyuan0129
- **信息**: refactor(sdx-solution): update gotchas and guidelines for clarity and consistency
- **文件**:
  - `.agent/skills/sdx-solution/SKILL.md`
  - `.agent/skills/sdx-solution/assets/solution-session-spec-template.md`
  - `.agent/skills/sdx-solution/gotchas.md`
  - `.agent/skills/sdx-solution/reference/audience-and-language.md`
  - `.agent/skills/sdx-solution/reference/checklists.md`
  - `.agent/skills/sdx-solution/reference/core-concepts.md`
  - `.agent/skills/sdx-solution/reference/design-principles.md`
  - `.agent/skills/sdx-solution/reference/principles.md`
  - `.agent/skills/sdx-solution/reference/quality-checklist.md`
  - `.agent/skills/sdx-solution/reference/workflow-spec.md`

### 2026-04-12 01:18:23.000 · git
- **提交**: `e5071abaadd7`
- **作者**: ouliyuan0129
- **信息**: refactor(sdx-solution): rewrite backbone logic and aggressive metadata
- **文件**:
  - `.agent/skills/sdx-solution/SKILL.md`
  - `.agent/skills/sdx-solution/reference/workflow-spec.md`

### 2026-04-12 01:18:01.000 · git
- **提交**: `bedb537098c8`
- **作者**: ouliyuan0129
- **信息**: refactor(sdx-solution): merge quality checklists and language guidelines
- **文件**:
  - `.agent/skills/sdx-solution/reference/audience-and-language.md`
  - `.agent/skills/sdx-solution/reference/checklists.md`
  - `.agent/skills/sdx-solution/reference/quality-checklist.md`

### 2026-04-12 01:13:11.000 · git
- **提交**: `33019d77d2ac`
- **作者**: ouliyuan0129
- **信息**: refactor(sdx-solution): merge concepts and principles into a single file
- **文件**:
  - `.agent/hooks.json`
  - `.agent/hooks/README.md`
  - `.agent/hooks/sdx-analysis-gate-write.py`
  - `.agent/hooks/sdx-solution-gate-write.py`
  - `.agent/rules/CONVENTIONS.md`
  - `.agent/rules/sdx-analysis.md`
  - `.agent/rules/sdx-solution.md`
  - `.agent/skills/sdx-analysis/SKILL.md`
  - `.agent/skills/sdx-analysis/assets/analysis-session-spec-template.md`
  - `.agent/skills/sdx-analysis/scripts/validate-analysis.sh`
  - `.agent/skills/sdx-solution/SKILL.md`
  - `.agent/skills/sdx-solution/assets/solution-session-spec-template.md`
  - `.agent/skills/sdx-solution/gotchas.md`
  - `.agent/skills/sdx-solution/reference/core-concepts.md`
  - `.agent/skills/sdx-solution/reference/design-principles.md`
  - `.agent/skills/sdx-solution/reference/principles.md`
  - `.agent/skills/sdx-solution/reference/workflow-spec.md`
  - `.agent/skills/sdx-solution/scripts/validate-solution.sh`
  - `AGENTS.md`
  - `application/solutions/README.md`
  - `system/solutions/README.md`

### 2026-04-11 09:59:30.000 · git
- **提交**: `cb58a1c9659f`
- **作者**: ouliyuan0129
- **信息**: refactor(docs-init): Clarify installation process for agent scripts and update README
- **文件**:
  - `scripts/README.md`
  - `scripts/docs-init.sh`

### 2026-04-11 09:49:39.000 · git
- **提交**: `4b52e9e7e1ce`
- **作者**: ouliyuan0129
- **信息**: refactor(docs-init): Update scope handling and documentation for agent installation
- **文件**:
  - `.agent/README.md`
  - `.agent/scripts/docsconfig-bootstrap.sh`
  - `README.md`
  - `scripts/README.md`
  - `scripts/docs-init.sh`
  - `scripts/tests/docs-init/cases/by-mode-type.sh`
  - `scripts/tests/docs-init/cases/by-scope-agent.sh`
  - `scripts/tests/docs-init/cases/by-scope-ck.sh`
  - `scripts/tests/docs-init/cases/by-scope-config.sh`
  - `scripts/tests/docs-init/cases/by-scope-knowledge.sh`

### 2026-04-11 08:41:36.000 · git
- **提交**: `e04bdb1c5b28`
- **作者**: ouliyuan0129
- **信息**: feat(scripts): docs-init 分发 agent scripts 与 docs-config，docsconfig-bootstrap 委托 docsconfig_read_into
- **文件**:
  - `.agent/README.md`
  - `.agent/scripts/docs-config.sh`
  - `.agent/scripts/docsconfig-bootstrap.sh`
  - `scripts/README.md`
  - `scripts/docs-init.sh`
  - `scripts/tests/docs-init/cases/by-scope-agent.sh`
  - `scripts/tests/docs-init/run.sh`

### 2026-04-11 08:11:28.000 · git
- **提交**: `f9a7ac97e487`
- **作者**: ouliyuan0129
- **信息**: refactor(scripts): 去掉 docs 脚本函数前缀下划线
- **文件**:
  - `scripts/docs-bootstrap.sh`
  - `scripts/docs-config.sh`
  - `scripts/docs-init.sh`

### 2026-04-11 08:07:14.000 · git
- **提交**: `169e06be0d5a`
- **作者**: ouliyuan0129
- **信息**: refactor(scripts): docs-bootstrap 复用克隆体 docs-config 并校验 URL 一致
- **文件**:
  - `scripts/README.md`
  - `scripts/docs-bootstrap.sh`
  - `scripts/docs-config.sh`
  - `scripts/tests/docs-init/cases/bootstrap-config-sync.sh`
  - `scripts/tests/docs-init/run.sh`

### 2026-04-10 21:41:34.000 · git
- **提交**: `31cf91129461`
- **作者**: ouliyuan0129
- **信息**: refactor(scripts): docs-init central 双轨 type 与 system 登记
- **文件**:
  - `scripts/README.md`
  - `scripts/docs-init.sh`
  - `scripts/tests/docs-init/cases/by-agents.sh`
  - `scripts/tests/docs-init/cases/by-mode-type.sh`
  - `scripts/tests/docs-init/cases/by-scope-agent.sh`
  - `scripts/tests/docs-init/cases/by-scope-ck.sh`
  - `scripts/tests/docs-init/cases/by-scope-config.sh`
  - `scripts/tests/docs-init/cases/by-scope-knowledge.sh`
  - `scripts/tests/docs-init/cases/cross-cut.sh`
  - `scripts/tests/docs-init/lib/assert.sh`
  - `scripts/tests/docs-init/run.sh`

### 2026-04-10 16:29:48.000 · git
- **提交**: `ba508d5a25b1`
- **作者**: ouliyuan0129
- **信息**: test(scripts): 增加 docs-init 集成测试并修复 dry-run 分支稳定性
- **文件**:
  - `scripts/README.md`
  - `scripts/docs-init.sh`
  - `scripts/tests/docs-init/cases/by-agents.sh`
  - `scripts/tests/docs-init/cases/by-mode-type.sh`
  - `scripts/tests/docs-init/cases/by-scope-agent.sh`
  - `scripts/tests/docs-init/cases/by-scope-ck.sh`
  - `scripts/tests/docs-init/cases/by-scope-config.sh`
  - `scripts/tests/docs-init/cases/by-scope-knowledge.sh`
  - `scripts/tests/docs-init/cases/cross-cut.sh`
  - `scripts/tests/docs-init/cases/full-copy.sh`
  - `scripts/tests/docs-init/lib/assert.sh`
  - `scripts/tests/docs-init/run.sh`

### 2026-04-09 20:17:55.000 · git
- **提交**: `de2c64416d4f`
- **作者**: ouliyuan0129
- **信息**: refactor(docs): Update directory metadata and simplify path mapping
- **文件**:
  - `application/docs_meta.yaml`
  - `scripts/README.md`
  - `scripts/docs-config.sh`
  - `scripts/docs-init.sh`
  - `system/docs_meta.yaml`

### 2026-04-09 19:59:22.000 · git
- **提交**: `02b6ba6b9057`
- **作者**: ouliyuan0129
- **信息**: refactor(docs-bootstrap, docs-config, docs-init): Enhance script documentation and structure
- **文件**:
  - `scripts/README.md`
  - `scripts/docs-bootstrap.sh`
  - `scripts/docs-config.sh`
  - `scripts/docs-init.sh`

### 2026-04-09 15:29:08.000 · git
- **提交**: `8ad622f8a1ba`
- **作者**: ouliyuan0129
- **信息**: fix(docs-init): Set dry_run to default value of 0 and remove related documentation entry
- **文件**:
  - `scripts/docs-init.sh`

### 2026-04-09 14:02:38.000 · git
- **提交**: `e8f336b76da7`
- **作者**: ouliyuan0129
- **信息**: docs: 强制提交前征得用户确认
- **文件**:
  - `.agent/rules/CONVENTIONS.md`
  - `.agent/rules/coding/git-guidelines.md`
  - `.agent/skills/README.md`
  - `AGENTS.md`

### 2026-04-09 13:09:32.000 · git
- **提交**: `48128f446582`
- **作者**: ouliyuan0129
- **信息**: docs(readme): 快速开始与文档导航补充目标工程 .docsconfig 说明
- **文件**:
  - `README.md`

### 2026-04-09 13:07:32.000 · git
- **提交**: `8ab0079891f7`
- **作者**: ouliyuan0129
- **信息**: docs: 对齐 .docsconfig 术语（DOC_* / AGENT_*）与脚本说明
- **文件**:
  - `.agent/README.md`
  - `.agent/rules/CONVENTIONS.md`
  - `.agent/skills/agent-guide/SKILL.md`
  - `AGENTS.md`
  - `index.md`
  - `application/index.md`
  - `scripts/README.md`
  - `system/index.md`

### 2026-04-09 12:14:41.000 · git
- **提交**: `5a07f33d00a3`
- **作者**: ouliyuan0129
- **信息**: feat(docsconfig): ~/ 写入、AGENT_* 与 expand_tilde 修正
- **文件**:
  - `.agent/scripts/docsconfig-bootstrap.sh`
  - `scripts/README.md`
  - `scripts/docs-config.sh`
  - `scripts/docs-init.sh`

### 2026-04-09 12:09:10.000 · git
- **提交**: `0ab5eb09516f`
- **作者**: ouliyuan0129
- **信息**: docs: 新增 docsconfig ~ 与 AGENT_* 实现计划
- **文件**:
### 2026-04-09 12:07:41.000 · git
- **提交**: `28472a28d691`
- **作者**: ouliyuan0129
- **信息**: docs: §4.4 术语替换纳入 DOC_ROOT/REPO_ROOT/DOC_DIR
- **文件**:
### 2026-04-09 12:06:20.000 · git
- **提交**: `408dcf724b1c`
- **作者**: ouliyuan0129
- **信息**: docs: 明确 AGENT_* 术语替换范围与 AGENT_DIR 占位
- **文件**:
### 2026-04-09 12:00:57.000 · git
- **提交**: `75e1a94d2e28`
- **作者**: ouliyuan0129
- **信息**: docs: 补充 AGENT_* 消费方与 DOC_ROOT 对齐及读入说明
- **文件**:
### 2026-04-09 11:08:41.000 · git
- **提交**: `11a2f2a5f5ba`
- **作者**: ouliyuan0129
- **信息**: docs: 新增 docsconfig ~ 路径与 Agent 键设计说明
- **文件**:
### 2026-04-09 10:09:26.000 · git
- **提交**: `6e7920ff058f`
- **作者**: ouliyuan0129
- **信息**: docs(changelogs): 统一 CHANGE-LOG 与 INDEXING-LOG 为 Markdown 约定
- **文件**:
  - `.agent/skills/README.md`
  - `.agent/skills/docs-change/SKILL.md`
  - `.agent/skills/docs-change/gotchas.md`
  - `.agent/skills/docs-change/reference/execution-spec.md`
  - `.agent/skills/docs-change/scripts/change-indexing.sh`
  - `.agent/skills/docs-indexing/SKILL.md`
  - `.agent/skills/docs-indexing/gotchas.md`
  - `.agent/skills/docs-indexing/reference/quality-standards.md`
  - `.agent/skills/docs-indexing/reference/scan-spec.md`
  - `.agent/skills/docs-indexing/scripts/indexing.sh`
  - `.docsconfig`
  - `index.md`
  - `application/DESIGN.md`
  - `application/index.md`
  - `application/constitution/standards/naming-conventions.md`
  - `scripts/docs-init.sh`
  - `system/index.md`
  - `system/changelogs/CHANGE-LOG.md`
  - `system/changelogs/INDEXING-LOG.md`
  - `system/changelogs/README.md`
  - `system/changelogs/changelogs_meta.yaml`

### 2026-04-08 23:02:59.000 · git
- **提交**: `ef5f48ce7108`
- **作者**: ouliyuan0129
- **信息**: 更新应用知识文档库，重构设计方案与阅读路径文档
- **文件**:
  - `application/DESIGN.md`
  - `application/README-c.md`
  - `application/README-s.md`
  - `application/README.md`
  - `application/specs/README.md`
  - `application/specs/specs_meta.yaml`
  - `company/system-SYSNAME/README.md`
  - `scripts/README.md`
  - `scripts/docs-init.sh`
  - `system/analysis/README.md`
  - `system/analysis/analysis_meta.yaml`
  - `system/changelogs/CHANGE-LOG.md`
  - `system/changelogs/README.md`
  - `system/changelogs/changelogs_meta.yaml`
  - `system/requirements/README.md`
  - `system/requirements/REQUIREMENT-EXAMPLE/README.md`
  - `system/requirements/requirements_meta.yaml`
  - `system/solutions/README.md`
  - `system/solutions/archive/.gitkeep`
  - `system/solutions/solutions_meta.yaml`
  - `system/specs/README.md`

### 2026-04-08 22:20:00.000 · git
- **提交**: `cf55400fce4f`
- **作者**: ouliyuan0129
- **信息**: 更新 docs-config.sh 中的初始化完成核对清单，简化内容并移除冗余项，以提高可读性和清晰度。
- **文件**:
  - `scripts/docs-config.sh`

### 2026-04-08 22:16:50.000 · git
- **提交**: `a76d905eefaa`
- **作者**: ouliyuan0129
- **信息**: 更新 index.md 文档，调整输出路径为环境变量，并新增系统索引指南文件
- **文件**:
  - `application/index.md`
  - `scripts/docs-config.sh`
  - `system/index.md`

### 2026-04-08 21:26:57.000 · git
- **提交**: `a8dceedb5447`
- **作者**: ouliyuan0129
- **信息**: refactor(docs): 删除过时的文档与设计文件，整合相关内容
- **文件**:
### 2026-04-08 21:17:49.000 · git
- **提交**: `382da663acae`
- **作者**: ouliyuan0129
- **信息**: refactor(docs-archive): 子脚本改为 .agent-only 路径并去除 system 命名
- **文件**:
  - `.agent/skills/docs-archive/scripts/append-change-log.sh`
  - `.agent/skills/docs-archive/scripts/update-archive-log.sh`

### 2026-04-08 21:17:44.000 · git
- **提交**: `dbd9ea93975b`
- **作者**: ouliyuan0129
- **信息**: refactor(docs-init): rewrite_doc_file 仅保留 .agent 替换并记录跳过规则
- **文件**:
  - `scripts/docs-init.sh`

### 2026-04-08 21:17:09.000 · git
- **提交**: `32f84b54e147`
- **作者**: ouliyuan0129
- **信息**: fix(commit): 恢复误提交的 docs-archive 与 changelog 文件
- **文件**:
  - `.agent/skills/docs-archive/scripts/append-system-change-log.sh`
  - `.agent/skills/docs-archive/scripts/run-docs-archive.sh`
  - `.agent/skills/docs-archive/scripts/update-application-archive-log.sh`
  - `.agent/skills/docs-fetch/SKILL.md`
  - `system/changelogs/CHANGE-LOG.md`
  - `system/changelogs/README.md`

### 2026-04-08 21:15:53.000 · git
- **提交**: `76a449986e17`
- **作者**: ouliyuan0129
- **信息**: refactor(docs-init): 保留 rewrite_agent_file 并仅执行 .agent 替换
- **文件**:
  - `.agent/skills/docs-archive/scripts/append-system-change-log.sh`
  - `.agent/skills/docs-archive/scripts/run-docs-archive.sh`
  - `.agent/skills/docs-archive/scripts/update-application-archive-log.sh`
  - `.agent/skills/docs-fetch/SKILL.md`
  - `scripts/docs-init.sh`
  - `system/changelogs/CHANGE-LOG.md`
  - `system/changelogs/README.md`

### 2026-04-08 21:10:31.000 · git
- **提交**: `1119e6483e3e`
- **作者**: ouliyuan0129
- **信息**: refactor(docs-init): 移除 rewrite_doc_file_minimal 并统一最小替换入口
- **文件**:
  - `scripts/README.md`
  - `scripts/docs-init.sh`

### 2026-04-08 20:58:51.000 · git
- **提交**: `6c5c723b0844`
- **作者**: ouliyuan0129
- **信息**: feat(docs-init): rewrite_doc_file_minimal 禁用 system 替换并输出命中告警
- **文件**:
  - `scripts/docs-init.sh`

### 2026-04-08 20:56:14.000 · git
- **提交**: `d3e1e8deb10a`
- **作者**: ouliyuan0129
- **信息**: refactor(docs-init): 提取替换命中明细日志助手函数
- **文件**:
  - `scripts/docs-init.sh`

### 2026-04-08 20:51:44.000 · git
- **提交**: `357e33ffcfcd`
- **作者**: ouliyuan0129
- **信息**: docs(superpowers): 新增 rewrite_doc_file_minimal 禁用 system 替换设计
- **文件**:
### 2026-04-08 20:51:29.000 · git
- **提交**: `07499bd87579`
- **作者**: ouliyuan0129
- **信息**: docs(superpowers): 新增 rewrite_agent_file 的 system 跳过替换设计
- **文件**:
  - `scripts/docs-config.sh`
  - `scripts/docs-init.sh`

### 2026-04-08 14:49:41.000 · git
- **提交**: `5e8275c14927`
- **作者**: ouliyuan0129
- **信息**: feat(docsconfig): 添加 .docsconfig 文件并更新相关脚本以支持新文档路径配置
- **文件**:
  - `.agent/scripts/docsconfig-bootstrap.sh`
  - `.agent/skills/README.md`
  - `.agent/skills/agent-guide/SKILL.md`
  - `.agent/skills/agent-guide/assets/readme-skeleton.md`
  - `.agent/skills/agent-guide/scripts/validate-guide.sh`
  - `.agent/skills/docs-build/SKILL.md`
  - `.agent/skills/docs-build/reference/consolidation-spec.md`
  - `.agent/skills/docs-build/reference/quality-checklist.md`
  - `.agent/skills/docs-build/reference/readme-fill-spec.md`
  - `.agent/skills/docs-build/scripts/validate-extraction.sh`
  - `.agent/skills/docs-change/SKILL.md`
  - `.agent/skills/docs-change/gotchas.md`
  - `.agent/skills/docs-fetch/SKILL.md`
  - `.agent/skills/docs-fetch/gotchas.md`
  - `.agent/skills/docs-fetch/reference/manifest-spec.md`
  - `.agent/skills/docs-indexing/SKILL.md`
  - `.agent/skills/docs-indexing/assets/index-guide-template.md`
  - `.agent/skills/docs-indexing/gotchas.md`
  - `.agent/skills/docs-indexing/reference/nine-chapter-spec.md`
  - `.agent/skills/docs-indexing/reference/scan-spec.md`
  - `.agent/skills/docs-indexing/scripts/indexing.sh`
  - `.agent/skills/docs-upgrade/reference/related-doc-discovery.md`
  - `.agent/skills/docs-upgrade/reference/semantic-keyword-discovery.md`
  - `.agent/skills/sdx-analysis/SKILL.md`
  - `.agent/skills/sdx-analysis/gotchas.md`
  - `.agent/skills/sdx-analysis/reference/core-concepts.md`
  - `.agent/skills/sdx-analysis/reference/design-principles.md`
  - `.agent/skills/sdx-analysis/reference/workflow-spec.md`
  - `.agent/skills/sdx-analysis/scripts/validate-analysis.sh`
  - `.agent/skills/sdx-design/SKILL.md`
  - … 另有 26 个文件

### 2026-04-08 12:20:52.000 · git
- **提交**: `a6550340faa0`
- **作者**: ouliyuan0129
- **信息**: docs(system): 补充架构分册、变更日志与元信息
- **文件**:
  - `system/application-APPNAME/changelogs/CHANGE-LOG.md`
  - `system/architecture/BUSINESS-ARCHITECTURE.md`
  - `system/architecture/DATA-ARCHITECTURE.md`
  - `system/architecture/PRODUCT-ARCHITECTURE.md`
  - `system/architecture/README.md`
  - `system/architecture/SYSTEM-ARCHITECTURE.md`
  - `system/architecture/TECHNICAL-ARCHITECTURE.md`
  - `system/changelogs/CHANGE-LOG.md`
  - `system/changelogs/README.md`
  - `system/docs_meta.yaml`

### 2026-04-08 12:20:50.000 · git
- **提交**: `44dcc88d70da`
- **作者**: ouliyuan0129
- **信息**: docs(superpowers): 新增 agent 链接可达性要求并移除过时设计稿
- **文件**:
### 2026-04-08 12:20:48.000 · git
- **提交**: `df78625405f0`
- **作者**: ouliyuan0129
- **信息**: refactor(docs-archive): 归档脚本拆分与规格、计划同步
- **文件**:
  - `.agent/skills/docs-archive/SKILL.md`
  - `.agent/skills/docs-archive/gotchas.md`
  - `.agent/skills/docs-archive/reference/README.md`
  - `.agent/skills/docs-archive/reference/archive-log-spec.md`
  - `.agent/skills/docs-archive/reference/archive-spec.md`
  - `.agent/skills/docs-archive/reference/federation-spec.md`
  - `.agent/skills/docs-archive/scripts/append-system-change-log.sh`
  - `.agent/skills/docs-archive/scripts/run-docs-archive.sh`
  - `.agent/skills/docs-archive/scripts/update-application-archive-log.sh`
  - `.agent/skills/docs-archive/scripts/update-archive-log.sh`
### 2026-04-08 12:20:46.000 · git
- **提交**: `2039fd44751c`
- **作者**: ouliyuan0129
- **信息**: docs(agent-guide): 对齐 validate 流程与 DOC_ROOT 语义
- **文件**:
  - `.agent/skills/agent-guide/SKILL.md`
  - `.agent/skills/agent-guide/gotchas.md`
  - `.agent/skills/agent-guide/reference/execution-spec.md`
  - `.agent/skills/agent-guide/reference/three-file-spec.md`
  - `.agent/skills/agent-guide/scripts/validate-guide.sh`

### 2026-04-08 12:20:44.000 · git
- **提交**: `dd70ca131883`
- **作者**: ouliyuan0129
- **信息**: feat(agent): 新增 docsconfig-bootstrap 并迁移 validate 与 indexing 脚本
- **文件**:
  - `.agent/scripts/docsconfig-bootstrap.sh`
  - `.agent/scripts/validate-agent-md-links.sh`
  - `.agent/skills/docs-build/scripts/validate-extraction.sh`
  - `.agent/skills/docs-indexing/scripts/indexing.sh`
  - `.agent/skills/sdx-analysis/scripts/validate-analysis.sh`
  - `.agent/skills/sdx-design/scripts/validate-design.sh`
  - `.agent/skills/sdx-prd/scripts/validate-prd.sh`
  - `.agent/skills/sdx-solution/scripts/validate-solution.sh`
  - `.agent/skills/sdx-test/scripts/validate-test.sh`

### 2026-04-08 12:20:41.000 · git
- **提交**: `dc6244aae5d4`
- **作者**: ouliyuan0129
- **信息**: feat(scripts): docs-init 与 docs-config 支持 .docsconfig 写入与推算
- **文件**:
  - `scripts/docs-config.sh`
  - `scripts/docs-init.sh`

### 2026-04-08 12:19:38.000 · git
- **提交**: `ad9a73a99ff2`
- **作者**: ouliyuan0129
- **信息**: docs(spec): 同步 docsconfig 设计规格与 scripts 说明
- **文件**:
  - `scripts/README.md`

### 2026-04-08 12:19:38.000 · git
- **提交**: `e7e4eb5d338f`
- **作者**: ouliyuan0129
- **信息**: docs(plan): 新增 docsconfig 与 docs-init 实施计划
- **文件**:
### 2026-04-08 12:19:37.000 · git
- **提交**: `1ef7b806d1f8`
- **作者**: ouliyuan0129
- **信息**: docs(spec): 新增 agent 外部引用路径规格
- **文件**:
### 2026-04-08 12:19:35.000 · git
- **提交**: `7fd96f7ff9a0`
- **作者**: ouliyuan0129
- **信息**: chore(agent): 移除 sdx-doc-root 与 sdx-validate-bootstrap
- **文件**:
  - `.agent/README.md`
  - `.agent/scripts/sdx-doc-root.sh`
  - `.agent/scripts/sdx-validate-bootstrap.sh`

### 2026-04-08 10:57:09.000 · git
- **提交**: `1b42e37a2ba8`
- **作者**: ouliyuan0129
- **信息**: docs(spec): DOC_ROOT 仅初始化显式指定，禁止推断
- **文件**:
### 2026-04-08 10:52:33.000 · git
- **提交**: `ebd8759e5717`
- **作者**: ouliyuan0129
- **信息**: docs(spec): DOC_DIR 由 DOC_ROOT 推算，REPO_ROOT+DOC_DIR=DOC_ROOT
- **文件**:
### 2026-04-08 10:52:07.000 · git
- **提交**: `b1511a7e22bd`
- **作者**: ouliyuan0129
- **信息**: docs(spec): REPO_ROOT 列于 DOC_ROOT 之后且由 DOC_ROOT 推算
- **文件**:
### 2026-04-08 10:50:54.000 · git
- **提交**: `aef1f4d3d908`
- **作者**: ouliyuan0129
- **信息**: docs(spec): 明确 DOC_ROOT 即 docs-init 传入知识库目录（规范化）
- **文件**:
### 2026-04-08 10:50:02.000 · git
- **提交**: `327bbff8fbee`
- **作者**: ouliyuan0129
- **信息**: docs(spec): 禁止 export 路径变量，避免多仓库环境串扰
- **文件**:
### 2026-04-08 10:47:34.000 · git
- **提交**: `c89ea5069b5d`
- **作者**: ouliyuan0129
- **信息**: docs(spec): 明确 REPO_ROOT/DOC_ROOT 语义并新增 DOC_DIR（相对仓库根）
- **文件**:
### 2026-04-08 10:45:17.000 · git
- **提交**: `a4465453240e`
- **作者**: ouliyuan0129
- **信息**: docs(spec): 目标文档目录即 DOC_ROOT，废弃 probe_base 与目录探测
- **文件**:
### 2026-04-08 10:39:24.000 · git
- **提交**: `c406e52a7fb4`
- **作者**: ouliyuan0129
- **信息**: docs(spec): docs-init 缺 .docsconfig 时直接落盘；策略 D 仅约束 validate
- **文件**:
### 2026-04-08 10:36:34.000 · git
- **提交**: `bc5d6c30a587`
- **作者**: ouliyuan0129
- **信息**: refactor: sdx_probe_doc_root_segment 重命名为 probe_doc_segment
- **文件**:
  - `.agent/scripts/sdx-doc-root.sh`
### 2026-04-08 10:34:48.000 · git
- **提交**: `91f915a286c6`
- **作者**: ouliyuan0129
- **信息**: docs(spec): §1.2 与 §3.2 推断链表述对齐
- **文件**:
### 2026-04-08 10:34:42.000 · git
- **提交**: `f7888ec27afe`
- **作者**: ouliyuan0129
- **信息**: docs(spec): 写入推断改为 --doc-root > .docsconfig > 探测 > 默认 docs
- **文件**:
### 2026-04-08 10:31:33.000 · git
- **提交**: `b675c0d8050c`
- **作者**: ouliyuan0129
- **信息**: docs(spec): 运行时读 .docsconfig 不支持显式环境变量覆盖
- **文件**:
### 2026-04-08 10:10:12.000 · git
- **提交**: `e6656424602d`
- **作者**: ouliyuan0129
- **信息**: docs(spec): 明确文档根推断函数落在 docs-config.sh
- **文件**:
### 2026-04-08 10:08:10.000 · git
- **提交**: `021a75970898`
- **作者**: ouliyuan0129
- **信息**: docs(spec): 约定 --scope=c 为 config 缩写
- **文件**:
### 2026-04-08 10:05:11.000 · git
- **提交**: `802b2ad17036`
- **作者**: ouliyuan0129
- **信息**: docs(spec): 新增 .docsconfig 与 docs-init 整合设计（方案甲）
- **文件**:
### 2026-04-08 09:06:20.000 · git
- **提交**: `1fe48e81b292`
- **作者**: ouliyuan0129
- **信息**: docs(spec): 新增 doc-root 脚本重构设计规格
- **文件**:
  - `.agent/README.md`
  - `.agent/rules/CONVENTIONS.md`
  - `.agent/scripts/sdx-doc-root.sh`
  - `.agent/scripts/sdx-validate-bootstrap.sh`
  - `.agent/scripts/validate-agent-md-links.sh`
  - `.agent/skills/README.md`
  - `.agent/skills/agent-guide/SKILL.md`
  - `.agent/skills/agent-guide/assets/readme-skeleton.md`
  - `.agent/skills/agent-guide/gotchas.md`
  - `.agent/skills/agent-guide/reference/execution-spec.md`
  - `.agent/skills/agent-guide/reference/three-file-spec.md`
  - `.agent/skills/agent-guide/scripts/validate-guide.sh`
  - `.agent/skills/docs-archive/SKILL.md`
  - `.agent/skills/docs-archive/gotchas.md`
  - `.agent/skills/docs-archive/reference/README.md`
  - `.agent/skills/docs-archive/reference/archive-log-spec.md`
  - `.agent/skills/docs-archive/reference/archive-spec.md`
  - `.agent/skills/docs-archive/reference/federation-spec.md`
  - `.agent/skills/docs-archive/scripts/update-archive-log.sh`
  - `.agent/skills/docs-build/scripts/validate-extraction.sh`
  - `.agent/skills/docs-change/SKILL.md`
  - `.agent/skills/docs-fetch/SKILL.md`
  - `.agent/skills/docs-indexing/scripts/indexing.sh`
  - `.agent/skills/docs-upgrade/reference/related-doc-discovery.md`
  - `.agent/skills/sdx-analysis/reference/core-concepts.md`
  - `.agent/skills/sdx-analysis/scripts/validate-analysis.sh`
  - `.agent/skills/sdx-design/reference/core-concepts.md`
  - `.agent/skills/sdx-design/scripts/validate-design.sh`
  - `.agent/skills/sdx-prd/reference/core-concepts.md`
  - `.agent/skills/sdx-prd/scripts/validate-prd.sh`
  - … 另有 5 个文件

### 2026-04-07 12:56:38.000 · git
- **提交**: `a256d6ce9601`
- **作者**: ouliyuan0129
- **信息**: feat: 联邦文档治理与 sdx-doc-root 探测扩展
- **文件**:
  - `.agent/scripts/sdx-doc-root.sh`
  - `AGENTS.md`
  - `README.md`
  - `application/CONTRIBUTING.md`
  - `application/index.md`
  - `application/SYSTEM_INDEX.md`
  - `application/analysis/analysis_meta.yaml`
  - `application/knowledge/business/README.md`
  - `application/manifest.yaml`
  - `application/system_meta.yaml`
  - `applications/APPLICATIONS_INDEX.md`
  - `applications/README.md`
  - `scripts/README.md`
  - `scripts/docs-init.sh`

### 2026-04-07 12:38:04.000 · git
- **提交**: `83f9ba9a352a`
- **作者**: ouliyuan0129
- **信息**: feat(application): 将宪法层迁至 application/constitution 并新增 system/constitution
- **文件**:
  - `.agent/skills/docs-archive/reference/archive-spec.md`
  - `.agent/skills/docs-archive/reference/federation-spec.md`
  - `.agent/skills/sdx-design/SKILL.md`
  - `index.md`
  - `application/DESIGN.md`
  - `application/README.md`
  - `application/analysis/README.md`
  - `application/constitution/GLOSSARY.md`
  - `application/constitution/README.md`
  - `application/constitution/adr/adr-template.md`
  - `application/constitution/adr/adr_meta.yaml`
  - `application/constitution/constitution_meta.yaml`
  - `application/constitution/principles/architecture-principles.yaml`
  - `application/constitution/principles/principles_meta.yaml`
  - `application/constitution/standards/naming-conventions.md`
  - `application/constitution/standards/standards_meta.yaml`
  - `application/docs_meta.yaml`
  - `application/knowledge/README.md`
  - `application/knowledge/constitution/GLOSSARY.md`
  - `application/knowledge/constitution/README.md`
  - `application/knowledge/knowledge_meta.yaml`
  - `application/requirements/requirements_meta.yaml`
  - `application/solutions/README.md`
  - `application/solutions/solutions_meta.yaml`
  - `scripts/README.md`
  - `scripts/docs-config.sh`
  - `system/README.md`
  - `system/constitution/README.md`
  - `system/constitution/constitution_meta.yaml`

### 2026-04-07 12:34:18.000 · git
- **提交**: `7c47f56b5855`
- **作者**: ouliyuan0129
- **信息**: fix(docs): 更新路径与索引文档，调整应用知识库与系统知识库的引用
- **文件**:
  - `.agent/rules/CONVENTIONS.md`
  - `.agent/scripts/sdx-doc-root.sh`
  - `.agent/skills/README.md`
  - `.agent/skills/agent-guide/reference/three-file-spec.md`
  - `.agent/skills/docs-archive/SKILL.md`
  - `.agent/skills/docs-archive/gotchas.md`
  - `.agent/skills/docs-archive/reference/archive-log-spec.md`
  - `.agent/skills/docs-archive/reference/archive-spec.md`
  - `.agent/skills/docs-archive/reference/federation-spec.md`
  - `.agent/skills/docs-fetch/SKILL.md`

### 2026-04-07 11:55:55.000 · git
- **提交**: `80c18890680b`
- **作者**: ouliyuan0129
- **信息**: feat(docs): 知识库 v2 方案B — application SSOT、system/company 骨架与入口对齐
- **文件**:
  - `.agent/README.md`
  - `.agent/rules/CONVENTIONS.md`
  - `.agent/scripts/sdx-doc-root.sh`
  - `.agent/skills/README.md`
  - `.agent/skills/agent-guide/SKILL.md`
  - `.agent/skills/agent-guide/assets/readme-skeleton.md`
  - `.agent/skills/agent-guide/gotchas.md`
  - `.agent/skills/agent-guide/reference/execution-spec.md`
  - `.agent/skills/agent-guide/reference/three-file-spec.md`
  - `.agent/skills/agent-guide/scripts/validate-guide.sh`
  - `.agent/skills/docs-archive/SKILL.md`
  - `.agent/skills/docs-archive/gotchas.md`
  - `.agent/skills/docs-archive/reference/README.md`
  - `.agent/skills/docs-archive/reference/archive-log-spec.md`
  - `.agent/skills/docs-archive/reference/archive-spec.md`
  - `.agent/skills/docs-archive/reference/federation-spec.md`
  - `.agent/skills/docs-archive/scripts/update-archive-log.sh`
  - `.agent/skills/docs-build/SKILL.md`
  - `.agent/skills/docs-build/reference/consolidation-spec.md`
  - `.agent/skills/docs-build/reference/quality-checklist.md`
  - `.agent/skills/docs-build/reference/readme-fill-spec.md`
  - `.agent/skills/docs-build/scripts/validate-extraction.sh`
  - `.agent/skills/docs-change/SKILL.md`
  - `.agent/skills/docs-change/gotchas.md`
  - `.agent/skills/docs-fetch/SKILL.md`
  - `.agent/skills/docs-fetch/gotchas.md`
  - `.agent/skills/docs-fetch/reference/manifest-spec.md`
  - `.agent/skills/docs-indexing/assets/index-guide-template.md`
  - `.agent/skills/docs-indexing/gotchas.md`
  - `.agent/skills/docs-indexing/reference/nine-chapter-spec.md`
  - … 另有 104 个文件

### 2026-04-07 11:40:01.000 · git
- **提交**: `79ea4c8d179e`
- **作者**: ouliyuan0129
- **信息**: docs: 默认 type=application，central 且无 type 时例外为 system
- **文件**:
### 2026-04-07 11:36:56.000 · git
- **提交**: `9dc12ec5a9e0`
- **作者**: ouliyuan0129
- **信息**: docs: company/ 增加 architecture 与 system/architecture 对照
- **文件**:
### 2026-04-07 11:34:43.000 · git
- **提交**: `35ce7b9ab199`
- **作者**: ouliyuan0129
- **信息**: docs: §2.3 central 默认 type=system；系统/公司库根与 fetch 槽位
- **文件**:
### 2026-04-07 11:26:38.000 · git
- **提交**: `5ffdb837b423`
- **作者**: ouliyuan0129
- **信息**: docs: 5.1 并入 mode=standalone|central，移除 --sync 参数表述
- **文件**:
### 2026-04-07 11:24:56.000 · git
- **提交**: `df49926b67a9`
- **作者**: ouliyuan0129
- **信息**: docs: §2.2 更正为 mode=s|c 等同 standalone|central；全量/核心改用 sync=full|core
- **文件**:
### 2026-04-07 11:23:18.000 · git
- **提交**: `6587838347fe`
- **作者**: ouliyuan0129
- **信息**: docs: §2.2 确认 mode=s|c，旧 standalone/central 迁至 --init-mode
- **文件**:
### 2026-04-07 11:19:54.000 · git
- **提交**: `7ae443927bca`
- **作者**: ouliyuan0129
- **信息**: docs: 确认 sync=core 源根为 application/（知识库布局 v2）
- **文件**:
### 2026-04-07 11:16:18.000 · git
- **提交**: `28f0a3f28e6c`
- **作者**: ouliyuan0129
- **信息**: docs: 知识库顶层重构（application/system/company）评估与草案
- **文件**:
### 2026-04-07 08:54:46.000 · git
- **提交**: `1bc7901d6367`
- **作者**: ouliyuan0129
- **信息**: refactor: 将协作控制层目录 .ai 重命名为 .agent
- **文件**:
  - `.agent/README.md`
  - `.agent/rules/CONVENTIONS.md`
  - `.agent/rules/coding/git-guidelines.md`
  - `.agent/rules/coding/java-guidelines.md`
  - `.agent/rules/coding/maven-guidelines.md`
  - `.agent/rules/coding/project-structure.md`
  - `.agent/rules/design/design-guidelines.md`
  - `.agent/rules/document/document-guidelines.md`
  - `.agent/rules/testing/testing-guidelines.md`
  - `.agent/scripts/sdx-doc-root.sh`
  - `.agent/scripts/sdx-validate-bootstrap.sh`
  - `.agent/skills/README.md`
  - `.agent/skills/agent-guide/SKILL.md`
  - `.agent/skills/agent-guide/assets/agents-skeleton.md`
  - `.agent/skills/agent-guide/assets/readme-skeleton.md`
  - `.agent/skills/agent-guide/gotchas.md`
  - `.agent/skills/agent-guide/reference/execution-spec.md`
  - `.agent/skills/agent-guide/reference/quality-standards.md`
  - `.agent/skills/agent-guide/reference/three-file-spec.md`
  - `.agent/skills/agent-guide/scripts/validate-guide.sh`
  - `.agent/skills/docs-archive/SKILL.md`
  - `.agent/skills/docs-archive/gotchas.md`
  - `.agent/skills/docs-archive/reference/README.md`
  - `.agent/skills/docs-archive/reference/archive-log-spec.md`
  - `.agent/skills/docs-archive/reference/archive-spec.md`
  - `.agent/skills/docs-archive/reference/federation-spec.md`
  - `.agent/skills/docs-archive/scripts/update-archive-log.sh`
  - `.agent/skills/docs-build/SKILL.md`
  - `.agent/skills/docs-build/assets/knowledge-index-template.md`
  - `.agent/skills/docs-build/assets/knowledge-schema-template.json`
  - … 另有 113 个文件

### 2026-04-07 08:49:49.000 · git
- **提交**: `40dc5d4da160`
- **作者**: ouliyuan0129
- **信息**: docs: 落盘 .ai 更名为 .agent 的设计评估说明
- **文件**:
### 2026-04-06 20:46:17.000 · git
- **提交**: `ec7f4feb20be`
- **作者**: ouliyuan0129
- **信息**: refactor(scripts): 收敛 SDX 校验入口至 .ai/scripts 并移除根目录转发脚本
- **文件**:
  - `.ai/scripts/sdx-doc-root.sh`
  - `.ai/scripts/sdx-validate-bootstrap.sh`
  - `.ai/skills/docs-build/scripts/validate-extraction.sh`
  - `.ai/skills/sdx-analysis/scripts/validate-analysis.sh`
  - `.ai/skills/sdx-design/scripts/validate-design.sh`
  - `.ai/skills/sdx-prd/scripts/validate-prd.sh`
  - `.ai/skills/sdx-solution/scripts/validate-solution.sh`
  - `.ai/skills/sdx-test/scripts/validate-test.sh`
  - `scripts/README.md`
  - `scripts/sdx-doc-root.sh`
  - `scripts/sdx-validate-bootstrap.sh`

### 2026-04-06 20:44:30.000 · git
- **提交**: `1dc1038f03ab`
- **作者**: ouliyuan0129
- **信息**: refactor(agent-guide): 移除根目录 validate-guide 并统一为 skill 内脚本路径
- **文件**:
  - `.ai/skills/agent-guide/SKILL.md`
  - `.ai/skills/agent-guide/gotchas.md`
  - `.ai/skills/agent-guide/reference/quality-standards.md`
  - `.ai/skills/agent-guide/scripts/validate-guide.sh`
  - `scripts/validate-guide.sh`

### 2026-04-06 19:56:56.000 · git
- **提交**: `31ae46025d55`
- **作者**: ouliyuan0129
- **信息**: remove: 删除 `.ai` 目录下的外部引用审计与复评文档
- **文件**:
### 2026-04-06 19:56:22.000 · git
- **提交**: `9b45b869f8cc`
- **作者**: ouliyuan0129
- **信息**: refactor(.ai): 将 sdx-doc-root 与 sdx-validate-bootstrap 迁至 .ai/scripts/
- **文件**:
  - `.ai/README.md`
  - `.ai/scripts/sdx-doc-root.sh`
  - `.ai/scripts/sdx-validate-bootstrap.sh`
  - `.ai/skills/docs-build/scripts/validate-extraction.sh`
  - `.ai/skills/sdx-analysis/scripts/validate-analysis.sh`
  - `.ai/skills/sdx-design/scripts/validate-design.sh`
  - `.ai/skills/sdx-prd/scripts/validate-prd.sh`
  - `.ai/skills/sdx-solution/scripts/validate-solution.sh`
  - `.ai/skills/sdx-test/scripts/validate-test.sh`
  - `scripts/README.md`
  - `scripts/sdx-doc-root.sh`
  - `scripts/sdx-validate-bootstrap.sh`

### 2026-04-06 19:54:08.000 · git
- **提交**: `132aceec75b5`
- **作者**: ouliyuan0129
- **信息**: refactor(.ai): 方案丙 — sdx-doc-root 迁入 .ai/skills，scripts 下为转发
- **文件**:
  - `.ai/skills/docs-build/scripts/validate-extraction.sh`
  - `.ai/skills/sdx-analysis/scripts/validate-analysis.sh`
  - `.ai/skills/sdx-design/scripts/validate-design.sh`
  - `.ai/skills/sdx-doc-root.sh`
  - `.ai/skills/sdx-prd/scripts/validate-prd.sh`
  - `.ai/skills/sdx-solution/scripts/validate-solution.sh`
  - `.ai/skills/sdx-test/scripts/validate-test.sh`
  - `.ai/skills/sdx-validate-bootstrap.sh`
  - `scripts/README.md`
  - `scripts/sdx-doc-root.sh`

### 2026-04-06 19:45:55.000 · git
- **提交**: `a55bef0e0bc5`
- **作者**: ouliyuan0129
- **信息**: docs: 复评 .ai 对外引用并记录脚本推断路径方案
- **文件**:
### 2026-04-06 19:44:46.000 · git
- **提交**: `98ce08e0fa2c`
- **作者**: ouliyuan0129
- **信息**: docs(.ai): 统一「系统知识库根目录」「应用知识库根目录」表述并保留路径字面量
- **文件**:
  - `.ai/README.md`
  - `.ai/rules/CONVENTIONS.md`
  - `.ai/skills/README.md`
  - `.ai/skills/agent-guide/SKILL.md`
  - `.ai/skills/docs-archive/SKILL.md`
  - `.ai/skills/docs-archive/gotchas.md`
  - `.ai/skills/docs-archive/reference/README.md`
  - `.ai/skills/docs-archive/reference/archive-spec.md`
  - `.ai/skills/docs-archive/reference/federation-spec.md`
  - `.ai/skills/docs-build/SKILL.md`
  - `.ai/skills/docs-change/SKILL.md`
  - `.ai/skills/docs-change/gotchas.md`
  - `.ai/skills/docs-fetch/SKILL.md`
  - `.ai/skills/docs-fetch/gotchas.md`
  - `.ai/skills/sdx-analysis/SKILL.md`
  - `.ai/skills/sdx-design/SKILL.md`
  - `.ai/skills/sdx-prd/SKILL.md`
  - `.ai/skills/sdx-solution/SKILL.md`
  - `.ai/skills/sdx-test/SKILL.md`
### 2026-04-06 19:40:28.000 · git
- **提交**: `5ef1d3a60c39`
- **作者**: ouliyuan0129
- **信息**: refactor(.ai): 将 sdx-validate-bootstrap 迁至 .ai/skills，校验脚本就近 source
- **文件**:
  - `.ai/skills/docs-build/scripts/validate-extraction.sh`
  - `.ai/skills/sdx-analysis/scripts/validate-analysis.sh`
  - `.ai/skills/sdx-design/scripts/validate-design.sh`
  - `.ai/skills/sdx-prd/scripts/validate-prd.sh`
  - `.ai/skills/sdx-solution/scripts/validate-solution.sh`
  - `.ai/skills/sdx-test/scripts/validate-test.sh`
  - `.ai/skills/sdx-validate-bootstrap.sh`
  - `scripts/README.md`
  - `scripts/sdx-validate-bootstrap.sh`

### 2026-04-06 19:38:24.000 · git
- **提交**: `ef09e0cbc8d4`
- **作者**: ouliyuan0129
- **信息**: docs(.ai): README 全仓库文档关系改为纯文本路径，去除仓库根 Markdown 外链
- **文件**:
  - `.ai/README.md`
### 2026-04-06 19:35:52.000 · git
- **提交**: `9d436182f52b`
- **作者**: ouliyuan0129
- **信息**: docs: 审计 .ai 目录对外部路径引用并落盘 spec
- **文件**:
### 2026-04-06 19:32:10.000 · git
- **提交**: `bbe46211942b`
- **作者**: ouliyuan0129
- **信息**: remove: 删除与 Agent 安装至用户主目录相关的设计文档和实现计划
- **文件**:
### 2026-04-06 19:30:40.000 · git
- **提交**: `3bed4a5e831e`
- **作者**: ouliyuan0129
- **信息**: fix(scripts): doc_root 默认首段改为 docs，探测优先 docs 目录
- **文件**:
  - `scripts/README.md`
  - `scripts/docs-config.sh`
  - `scripts/sdx-doc-root.sh`
  - `scripts/sdx-validate-bootstrap.sh`

### 2026-04-06 19:29:30.000 · git
- **提交**: `923a38e77fc1`
- **作者**: ouliyuan0129
- **信息**: feat(scripts): 方案 A 统一 doc_root 解析（SDX_DOC_ROOT、.sdx-doc-root、探测）
- **文件**:
  - `.ai/skills/docs-build/scripts/validate-extraction.sh`
  - `.ai/skills/sdx-analysis/scripts/validate-analysis.sh`
  - `.ai/skills/sdx-design/scripts/validate-design.sh`
  - `.ai/skills/sdx-prd/scripts/validate-prd.sh`
  - `.ai/skills/sdx-solution/scripts/validate-solution.sh`
  - `.ai/skills/sdx-test/scripts/validate-test.sh`
  - `scripts/README.md`
  - `scripts/docs-config.sh`
  - `scripts/sdx-doc-root.sh`
  - `scripts/sdx-validate-bootstrap.sh`

### 2026-04-06 19:23:23.000 · git
- **提交**: `5b34129e1894`
- **作者**: ouliyuan0129
- **信息**: docs: 新增 doc_root 解析来源（Skill/rules 上下文）设计说明
- **文件**:
### 2026-04-06 19:14:34.000 · git
- **提交**: `dbae58a463bc`
- **作者**: ouliyuan0129
- **信息**: feat(scripts): docs-init 在 standalone+s/r/rs 下可省略工程文档目录
- **文件**:
  - `scripts/README.md`
  - `scripts/docs-config.sh`
  - `scripts/docs-init.sh`

### 2026-04-06 19:13:57.000 · git
- **提交**: `1299b6148d13`
- **作者**: ouliyuan0129
- **信息**: feat(skill-creator): add foundational files for skill creation and evaluation
- **文件**:
  - `.ai/skills/skill-creator/SKILL.md`
  - `.ai/skills/skill-creator/agents/analyzer.md`
  - `.ai/skills/skill-creator/agents/comparator.md`
  - `.ai/skills/skill-creator/agents/grader.md`
  - `.ai/skills/skill-creator/assets/eval_review.html`
  - `.ai/skills/skill-creator/eval-viewer/generate_review.py`
  - `.ai/skills/skill-creator/eval-viewer/viewer.html`
  - `.ai/skills/skill-creator/license.txt`
  - `.ai/skills/skill-creator/references/schemas.md`
  - `.ai/skills/skill-creator/scripts/__init__.py`
  - `.ai/skills/skill-creator/scripts/aggregate_benchmark.py`
  - `.ai/skills/skill-creator/scripts/generate_report.py`
  - `.ai/skills/skill-creator/scripts/improve_description.py`
  - `.ai/skills/skill-creator/scripts/package_skill.py`
  - `.ai/skills/skill-creator/scripts/quick_validate.py`
  - `.ai/skills/skill-creator/scripts/run_eval.py`
  - `.ai/skills/skill-creator/scripts/run_loop.py`
  - `.ai/skills/skill-creator/scripts/utils.py`

### 2026-04-06 19:12:23.000 · git
- **提交**: `04bb1965704c`
- **作者**: ouliyuan0129
- **信息**: docs: 无工程路径时 docs_slash 默认改为 docs/
- **文件**:
### 2026-04-06 19:07:51.000 · git
- **提交**: `f6d8871b8d32`
- **作者**: ouliyuan0129
- **信息**: docs: 新增 docs-init scope s/r/rs 时文档路径可选的设计说明
- **文件**:
### 2026-04-06 19:06:47.000 · git
- **提交**: `828a807846aa`
- **作者**: ouliyuan0129
- **信息**: feat(scripts): docs-init 将 Agent skills/rules 安装至用户主目录
- **文件**:
  - `scripts/README.md`
  - `scripts/docs-config.sh`
  - `scripts/docs-init.sh`

### 2026-04-06 19:00:37.000 · git
- **提交**: `c09d2e21abb1`
- **作者**: ouliyuan0129
- **信息**: docs: 新增 docs-init Agent 安装至用户主目录设计说明
- **文件**:
### 2026-04-06 18:38:59.000 · git
- **提交**: `5926f7c9bd74`
- **作者**: ouliyuan0129
- **信息**: merge: 合并 features/feature-1.0.0-federated-docs 至 main

### 2026-04-06 18:37:58.000 · git
- **提交**: `e7b99e07476e`
- **作者**: ouliyuan0129
- **信息**: Remove skill-creator documentation and related assets
- **文件**:
  - `.ai/skills/skill-creator/LICENSE.txt`
  - `.ai/skills/skill-creator/SKILL.md`
  - `.ai/skills/skill-creator/agents/analyzer.md`
  - `.ai/skills/skill-creator/agents/comparator.md`
  - `.ai/skills/skill-creator/agents/grader.md`
  - `.ai/skills/skill-creator/assets/eval_review.html`
  - `.ai/skills/skill-creator/eval-viewer/generate_review.py`
  - `.ai/skills/skill-creator/eval-viewer/viewer.html`
  - `.ai/skills/skill-creator/references/schemas.md`
  - `.ai/skills/skill-creator/scripts/__init__.py`
  - `.ai/skills/skill-creator/scripts/aggregate_benchmark.py`
  - `.ai/skills/skill-creator/scripts/generate_report.py`
  - `.ai/skills/skill-creator/scripts/improve_description.py`
  - `.ai/skills/skill-creator/scripts/package_skill.py`
  - `.ai/skills/skill-creator/scripts/quick_validate.py`
  - `.ai/skills/skill-creator/scripts/run_eval.py`
  - `.ai/skills/skill-creator/scripts/run_loop.py`
  - `.ai/skills/skill-creator/scripts/utils.py`

### 2026-04-06 18:35:20.000 · git
- **提交**: `c64ee7a6266a`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-test): 更新测试设计文档内容与结构要求
- **文件**:
  - `.ai/skills/sdx-test/SKILL.md`
  - `.ai/skills/sdx-test/gotchas.md`

### 2026-04-06 18:32:08.000 · git
- **提交**: `6d27dd54a409`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-design): 更新设计文档内容与结构要求
- **文件**:
  - `.ai/skills/sdx-design/SKILL.md`
  - `.ai/skills/sdx-design/gotchas.md`

### 2026-04-06 18:19:51.000 · git
- **提交**: `6563dd8d7624`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-prd): 更新 PRD 文档内容与结构要求
- **文件**:
  - `.ai/skills/sdx-prd/SKILL.md`
  - `.ai/skills/sdx-prd/gotchas.md`

### 2026-04-06 18:03:36.000 · git
- **提交**: `7ee750010db3`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-design): 更新设计文档质量自查与输出要求
- **文件**:
  - `.ai/skills/sdx-design/SKILL.md`
  - `.ai/skills/sdx-design/assets/add-template.md`
  - `.ai/skills/sdx-design/reference/quality-checklist.md`
  - `.ai/skills/sdx-design/reference/workflow-spec.md`
  - `.ai/skills/sdx-prd/SKILL.md`
  - `.ai/skills/sdx-prd/assets/prd-template.md`
  - `.ai/skills/sdx-prd/reference/quality-checklist.md`
  - `.ai/skills/sdx-prd/reference/workflow-spec.md`
  - `.ai/skills/sdx-test/SKILL.md`
  - `.ai/skills/sdx-test/assets/tdd-template.md`
  - `.ai/skills/sdx-test/reference/quality-checklist.md`
  - `.ai/skills/sdx-test/reference/workflow-spec.md`
  - `.ai/skills/sdx-test/scripts/validate-test.sh`

### 2026-04-06 17:51:11.000 · git
- **提交**: `d50faebdd9c3`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-prd): 精简 PRD 模板内容与结构
- **文件**:
  - `.ai/skills/sdx-prd/assets/prd-template.md`

### 2026-04-06 17:35:05.000 · git
- **提交**: `b168eeb2f385`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-prd): 更新 PRD 文档结构与内容要求
- **文件**:
  - `.ai/skills/sdx-prd/SKILL.md`
  - `.ai/skills/sdx-prd/assets/prd-template.md`
  - `.ai/skills/sdx-prd/gotchas.md`
  - `.ai/skills/sdx-prd/reference/core-concepts.md`
  - `.ai/skills/sdx-prd/reference/design-principles.md`
  - `.ai/skills/sdx-prd/reference/quality-checklist.md`
  - `.ai/skills/sdx-prd/reference/workflow-spec.md`
  - `.ai/skills/sdx-prd/scripts/validate-prd.sh`

### 2026-04-06 12:56:10.000 · git
- **提交**: `68a34e12f608`
- **作者**: ouliyuan0129
- **信息**: docs(system-index): 移除 APP-BILLING-APPEAL 条目
- **文件**:
  - `system/SYSTEM_INDEX.md`

### 2026-04-06 12:52:08.000 · git
- **提交**: `c326280ecee0`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-analysis, sdx-solution): 更新质量自查与文档结构要求
- **文件**:
  - `.ai/skills/sdx-analysis/SKILL.md`
  - `.ai/skills/sdx-analysis/assets/analysis-template.md`
  - `.ai/skills/sdx-analysis/gotchas.md`
  - `.ai/skills/sdx-analysis/reference/design-principles.md`
  - `.ai/skills/sdx-analysis/reference/quality-checklist.md`
  - `.ai/skills/sdx-analysis/reference/workflow-spec.md`
  - `.ai/skills/sdx-analysis/scripts/validate-analysis.sh`
  - `.ai/skills/sdx-solution/SKILL.md`
  - `.ai/skills/sdx-solution/assets/solution-template.md`
  - `.ai/skills/sdx-solution/gotchas.md`
  - `.ai/skills/sdx-solution/reference/quality-checklist.md`
  - `.ai/skills/sdx-solution/reference/workflow-spec.md`
  - `.ai/skills/sdx-solution/scripts/validate-solution.sh`

### 2026-04-06 12:41:50.000 · git
- **提交**: `22c06e561ae2`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-analysis): 更新需求分析文档结构与内容
- **文件**:
  - `.ai/skills/sdx-analysis/SKILL.md`
  - `.ai/skills/sdx-analysis/assets/analysis-template.md`
  - `.ai/skills/sdx-analysis/gotchas.md`
  - `.ai/skills/sdx-analysis/reference/audience-and-language.md`
  - `.ai/skills/sdx-analysis/reference/core-concepts.md`
  - `.ai/skills/sdx-analysis/reference/design-principles.md`
  - `.ai/skills/sdx-analysis/reference/quality-checklist.md`
  - `.ai/skills/sdx-analysis/reference/workflow-spec.md`
  - `.ai/skills/sdx-analysis/scripts/validate-analysis.sh`
  - `system/analysis/README.md`

### 2026-04-06 11:17:55.000 · git
- **提交**: `c478bb8291f0`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-solution): 更新解决方案技能文档与模板结构
- **文件**:
  - `.ai/skills/docs-archive/SKILL.md`
  - `.ai/skills/sdx-solution/SKILL.md`
  - `.ai/skills/sdx-solution/assets/solution-template.md`
  - `.ai/skills/sdx-solution/gotchas.md`
  - `.ai/skills/sdx-solution/reference/audience-and-language.md`
  - `.ai/skills/sdx-solution/reference/core-concepts.md`
  - `.ai/skills/sdx-solution/reference/design-principles.md`
  - `.ai/skills/sdx-solution/reference/quality-checklist.md`
  - `.ai/skills/sdx-solution/reference/workflow-spec.md`
  - `.ai/skills/sdx-solution/scripts/validate-solution.sh`
  - `system/solutions/README.md`

### 2026-04-05 23:57:20.000 · git
- **提交**: `6d27f4664581`
- **作者**: ouliyuan0129
- **信息**: docs(docs-archive): 更新归档技能文档与锚点规范
- **文件**:
  - `.ai/skills/README.md`
  - `.ai/skills/docs-archive/SKILL.md`
  - `.ai/skills/docs-archive/gotchas.md`
  - `.ai/skills/docs-archive/reference/README.md`
  - `.ai/skills/docs-archive/reference/archive-log-spec.md`
  - `.ai/skills/docs-archive/reference/archive-spec.md`
  - `.ai/skills/docs-archive/reference/federation-spec.md`
  - `.ai/skills/docs-archive/scripts/update-archive-log.sh`

### 2026-04-05 23:31:05.000 · git
- **提交**: `cce5f82d43bd`
- **作者**: ouliyuan0129
- **信息**: docs(docs-fetch): 新增文档与技能说明，优化知识库同步流程
- **文件**:
  - `.ai/skills/README.md`
  - `.ai/skills/docs-fetch/SKILL.md`
  - `.ai/skills/docs-fetch/assets/fetch-log-template.md`
  - `.ai/skills/docs-fetch/gotchas.md`
  - `.ai/skills/docs-fetch/reference/manifest-spec.md`
  - `.ai/skills/docs-fetch/scripts/fetch-docs.sh`

### 2026-04-05 23:18:07.000 · git
- **提交**: `ab04dbfc4491`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-test): 精简并优化 gotchas.md、SKILL.md 和 design-principles.md 内容
- **文件**:
  - `.ai/skills/sdx-test/SKILL.md`
  - `.ai/skills/sdx-test/gotchas.md`
  - `.ai/skills/sdx-test/reference/design-principles.md`

### 2026-04-05 23:15:36.000 · git
- **提交**: `0ccb80fad90b`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-design): 优化方案设计技能说明与校验默认路径
- **文件**:
  - `.ai/skills/sdx-design/SKILL.md`
  - `.ai/skills/sdx-design/gotchas.md`
  - `.ai/skills/sdx-design/reference/design-principles.md`
  - `.ai/skills/sdx-design/scripts/validate-design.sh`

### 2026-04-05 23:11:16.000 · git
- **提交**: `71dfb9b00e80`
- **作者**: ouliyuan0129
- **信息**: docs(sdx-prd): 优化 PRD 技能说明与校验默认路径
- **文件**:
  - `.ai/skills/sdx-prd/SKILL.md`
  - `.ai/skills/sdx-prd/gotchas.md`
  - `.ai/skills/sdx-prd/reference/design-principles.md`
  - `.ai/skills/sdx-prd/scripts/validate-prd.sh`

### 2026-04-05 23:07:41.000 · git
- **提交**: `5e15256826b0`
- **作者**: ouliyuan0129
- **信息**: 更新文档，优化 `gotchas.md`、`SKILL.md` 和 `design-principles.md` 内容
- **文件**:
  - `.ai/skills/sdx-analysis/SKILL.md`
  - `.ai/skills/sdx-analysis/gotchas.md`
  - `.ai/skills/sdx-analysis/reference/design-principles.md`
  - `.ai/skills/sdx-analysis/scripts/validate-analysis.sh`

### 2026-04-05 23:02:31.000 · git
- **提交**: `8b9f2dffb14f`
- **作者**: ouliyuan0129
- **信息**: 更新文档，优化 `gotchas.md`、`SKILL.md` 和 `design-principles.md` 内容
- **文件**:
  - `.ai/skills/sdx-solution/SKILL.md`
  - `.ai/skills/sdx-solution/gotchas.md`
  - `.ai/skills/sdx-solution/reference/design-principles.md`
  - `.ai/skills/sdx-solution/scripts/validate-solution.sh`

### 2026-04-05 22:56:31.000 · git
- **提交**: `db1ce75cf575`
- **作者**: ouliyuan0129
- **信息**: 新增文档，完善文档升级技能的常见陷阱与引用链检索策略
- **文件**:
  - `.ai/skills/docs-upgrade/SKILL.md`
  - `.ai/skills/docs-upgrade/gotchas.md`
  - `.ai/skills/docs-upgrade/reference/related-doc-discovery.md`
  - `.ai/skills/docs-upgrade/reference/semantic-keyword-discovery.md`
  - `.ai/skills/docs-upgrade/references/gotchas.md`
  - `.ai/skills/docs-upgrade/references/related-doc-discovery.md`
  - `.ai/skills/docs-upgrade/references/semantic-keyword-discovery.md`

### 2026-04-05 22:53:12.000 · git
- **提交**: `fe44e131683b`
- **作者**: ouliyuan0129
- **信息**: 更新文档，优化 `gotchas.md`、`SKILL.md` 和 `scan-spec.md` 内容
- **文件**:
  - `.ai/skills/docs-indexing/SKILL.md`
  - `.ai/skills/docs-indexing/gotchas.md`
  - `.ai/skills/docs-indexing/reference/scan-spec.md`
  - `.ai/skills/docs-indexing/scripts/indexing.sh`

### 2026-04-05 22:48:23.000 · git
- **提交**: `8c7e5dc34d85`
- **作者**: ouliyuan0129
- **信息**: 新增文档，完善知识归档与联邦原则规范
- **文件**:
  - `.ai/skills/docs-archive/SKILL.md`
  - `.ai/skills/docs-archive/gotchas.md`
  - `.ai/skills/docs-archive/reference/archive-spec.md`
  - `.ai/skills/docs-archive/reference/federation-spec.md`

### 2026-04-05 22:47:21.000 · git
- **提交**: `eab63aa3e6a4`
- **作者**: ouliyuan0129
- **信息**: 更新文档，优化 `gotchas.md`、`SKILL.md` 和内置配置说明
- **文件**:
  - `.ai/skills/docs-build/SKILL.md`
  - `.ai/skills/docs-build/gotchas.md`
  - `.ai/skills/docs-build/reference/builtin-config.md`
  - `.ai/skills/docs-build/scripts/validate-extraction.sh`

### 2026-04-05 22:39:40.000 · git
- **提交**: `31cb57975d74`
- **作者**: ouliyuan0129
- **信息**: 优化 agent-guide 文档，更新常见陷阱与执行规范
- **文件**:
  - `.ai/skills/agent-guide/SKILL.md`
  - `.ai/skills/agent-guide/assets/agents-skeleton.md`
  - `.ai/skills/agent-guide/gotchas.md`
  - `.ai/skills/agent-guide/reference/execution-spec.md`
  - `.ai/skills/agent-guide/reference/quality-standards.md`
  - `.ai/skills/agent-guide/reference/three-file-spec.md`
  - `.ai/skills/agent-guide/scripts/validate-guide.sh`

### 2026-04-05 22:29:20.000 · git
- **提交**: `16703f3e5e2a`
- **作者**: ouliyuan0129
- **信息**: 更新文档，优化 `gotchas.md` 和 `SKILL.md` 内容
- **文件**:
  - `.ai/skills/docs-change/SKILL.md`
  - `.ai/skills/docs-change/gotchas.md`
  - `.ai/skills/docs-change/reference/execution-spec.md`
  - `.ai/skills/docs-change/scripts/change-indexing.sh`

### 2026-04-05 21:57:28.000 · git
- **提交**: `45476b4737f2`
- **作者**: ouliyuan0129
- **信息**: 更新文档，优化知识归档与中央登记流程
- **文件**:
  - `.ai/skills/docs-archive/SKILL.md`
  - `.ai/skills/docs-upgrade/references/semantic-keyword-discovery.md`
  - `scripts/README.md`
  - `scripts/docs-init.sh`

### 2026-04-05 21:40:59.000 · git
- **提交**: `fde9a48e1269`
- **作者**: ouliyuan0129
- **信息**: 更新文档，增强技能升级与引用同步功能
- **文件**:
  - `.ai/skills/README.md`
  - `.ai/skills/docs-upgrade/SKILL.md`
  - `.ai/skills/docs-upgrade/agents/openai.yaml`
  - `.ai/skills/docs-upgrade/references/gotchas.md`
  - `.ai/skills/docs-upgrade/references/related-doc-discovery.md`
  - `.ai/skills/docs-upgrade/references/semantic-keyword-discovery.md`
  - `index.md`

### 2026-04-05 21:25:05.000 · git
- **提交**: `36295f5448f6`
- **作者**: ouliyuan0129
- **信息**: 更新技能文档，新增技能创建与评估相关内容
- **文件**:
  - `.ai/skills/skill-creator/LICENSE.txt`
  - `.ai/skills/skill-creator/SKILL.md`
  - `.ai/skills/skill-creator/agents/analyzer.md`
  - `.ai/skills/skill-creator/agents/comparator.md`
  - `.ai/skills/skill-creator/agents/grader.md`
  - `.ai/skills/skill-creator/assets/eval_review.html`
  - `.ai/skills/skill-creator/eval-viewer/generate_review.py`
  - `.ai/skills/skill-creator/eval-viewer/viewer.html`
  - `.ai/skills/skill-creator/references/schemas.md`
  - `.ai/skills/skill-creator/scripts/__init__.py`
  - `.ai/skills/skill-creator/scripts/aggregate_benchmark.py`
  - `.ai/skills/skill-creator/scripts/generate_report.py`
  - `.ai/skills/skill-creator/scripts/improve_description.py`
  - `.ai/skills/skill-creator/scripts/package_skill.py`
  - `.ai/skills/skill-creator/scripts/quick_validate.py`
  - `.ai/skills/skill-creator/scripts/run_eval.py`
  - `.ai/skills/skill-creator/scripts/run_loop.py`
  - `.ai/skills/skill-creator/scripts/utils.py`
  - `.cursor/skills/skill-creator/SKILL.md`
  - `.cursor/skills/skill-creator/agents/analyzer.md`
  - `.cursor/skills/skill-creator/agents/comparator.md`
  - `.cursor/skills/skill-creator/agents/grader.md`
  - `.cursor/skills/skill-creator/agents/openai.yaml`
  - `.cursor/skills/skill-creator/assets/eval_review.html`
  - `.cursor/skills/skill-creator/assets/skill-creator-small.svg`
  - `.cursor/skills/skill-creator/assets/skill-creator.png`
  - `.cursor/skills/skill-creator/eval-viewer/generate_review.py`
  - `.cursor/skills/skill-creator/eval-viewer/viewer.html`
  - `.cursor/skills/skill-creator/license.txt`
  - `.cursor/skills/skill-creator/references/openai_yaml.md`
  - … 另有 12 个文件

### 2026-04-05 19:58:47.000 · git
- **提交**: `5b983d9ea8c0`
- **作者**: ouliyuan0129
- **信息**: 更新文档，增强项目概述与角色定位描述
- **文件**:
  - `.ai/skills/agent-guide/assets/agents-skeleton.md`
  - `AGENTS.md`

### 2026-04-05 19:48:48.000 · git
- **提交**: `e8f167abadbc`
- **作者**: ouliyuan0129
- **信息**: 更新文档，优化 AI Agent 指南与 README 结构
- **文件**:
  - `.ai/skills/agent-guide/assets/agents-skeleton.md`
  - `AGENTS.md`
  - `README.md`

### 2026-04-05 19:38:37.000 · git
- **提交**: `ba05aed47263`
- **作者**: ouliyuan0129
- **信息**: 更新文档，优化索引与导航结构
- **文件**:
  - `.ai/README.md`
  - `.ai/skills/agent-guide/assets/agents-skeleton.md`
  - `.ai/skills/docs-indexing/scripts/indexing.sh`
  - `.cursor/skills/skill-creator/SKILL.md`
  - `AGENTS.md`
  - `index.md`
  - `README.md`
  - `system/index.md`
  - `system/changelogs/changes-index.json`
  - `system/changelogs/changes-index.md`
  - `system/changelogs/indexing-log.jsonl`
  - `system/knowledge/technical/technical-debt.md`

### 2026-04-04 09:09:11.000 · git
- **提交**: `6724d7f8f281`
- **作者**: ouliyuan0129
- **信息**: 更新文档，统一元数据填写规范与文件命名
- **文件**:
  - `.ai/skills/sdx-analysis/assets/analysis-template.md`
  - `.ai/skills/sdx-design/assets/add-template.md`
  - `.ai/skills/sdx-design/gotchas.md`
  - `.ai/skills/sdx-design/reference/quality-checklist.md`
  - `.ai/skills/sdx-design/scripts/validate-design.sh`
  - `.ai/skills/sdx-prd/assets/prd-template.md`
  - `.ai/skills/sdx-prd/gotchas.md`
  - `.ai/skills/sdx-prd/reference/quality-checklist.md`
  - `.ai/skills/sdx-prd/scripts/validate-prd.sh`
  - `.ai/skills/sdx-solution/assets/solution-template.md`
  - `.ai/skills/sdx-solution/gotchas.md`
  - `.ai/skills/sdx-solution/reference/quality-checklist.md`
  - `.ai/skills/sdx-solution/reference/workflow-spec.md`
  - `.ai/skills/sdx-solution/scripts/validate-solution.sh`
  - `.ai/skills/sdx-test/assets/tdd-template.md`
  - `.ai/skills/sdx-test/reference/quality-checklist.md`
  - `.ai/skills/sdx-test/scripts/validate-test.sh`

### 2026-04-04 08:57:04.000 · git
- **提交**: `4e9ec7e7faa5`
- **作者**: ouliyuan0129
- **信息**: 更新文档，统一文件命名与元数据规范
- **文件**:
  - `.ai/skills/sdx-analysis/SKILL.md`
  - `.ai/skills/sdx-analysis/reference/core-concepts.md`
  - `.ai/skills/sdx-design/SKILL.md`
  - `.ai/skills/sdx-design/assets/add-template.md`
  - `.ai/skills/sdx-design/reference/core-concepts.md`
  - `.ai/skills/sdx-design/reference/design-principles.md`
  - `.ai/skills/sdx-design/reference/workflow-spec.md`
  - `.ai/skills/sdx-prd/SKILL.md`
  - `.ai/skills/sdx-prd/assets/prd-template.md`
  - `.ai/skills/sdx-prd/gotchas.md`
  - `.ai/skills/sdx-prd/reference/core-concepts.md`
  - `.ai/skills/sdx-prd/reference/design-principles.md`
  - `.ai/skills/sdx-prd/reference/workflow-spec.md`
  - `.ai/skills/sdx-solution/SKILL.md`
  - `.ai/skills/sdx-solution/reference/core-concepts.md`
  - `.ai/skills/sdx-test/SKILL.md`
  - `.ai/skills/sdx-test/assets/tdd-template.md`
  - `.ai/skills/sdx-test/gotchas.md`
  - `.ai/skills/sdx-test/reference/core-concepts.md`
  - `.ai/skills/sdx-test/reference/design-principles.md`
  - `.ai/skills/sdx-test/reference/workflow-spec.md`
  - `.cursor/skills/skill-creator/SKILL.md`
  - `.cursor/skills/skill-creator/agents/openai.yaml`
  - `.cursor/skills/skill-creator/assets/skill-creator-small.svg`
  - `.cursor/skills/skill-creator/assets/skill-creator.png`
  - `.cursor/skills/skill-creator/license.txt`
  - `.cursor/skills/skill-creator/references/openai_yaml.md`
  - `.cursor/skills/skill-creator/scripts/generate_openai_yaml.py`
  - `.cursor/skills/skill-creator/scripts/init_skill.py`
  - `.cursor/skills/skill-creator/scripts/quick_validate.py`
  - … 另有 15 个文件

### 2026-04-03 17:59:49.000 · git
- **提交**: `1b323538327c`
- **作者**: ouliyuan0129
- **信息**: 更新技能文档，调整文件命名与元数据规范
- **文件**:
  - `.ai/skills/sdx-design/SKILL.md`
  - `.ai/skills/sdx-prd/SKILL.md`
  - `.ai/skills/sdx-test/SKILL.md`

### 2026-04-03 15:52:55.000 · git
- **提交**: `ceb683b08f54`
- **作者**: ouliyuan0129
- **信息**: 更新文档，明确文档元数据的填写规范与位置
- **文件**:
  - `.ai/skills/sdx-analysis/assets/analysis-template.md`
  - `.ai/skills/sdx-analysis/gotchas.md`
  - `.ai/skills/sdx-analysis/reference/audience-and-language.md`
  - `.ai/skills/sdx-analysis/reference/design-principles.md`
  - `.ai/skills/sdx-analysis/reference/quality-checklist.md`
  - `.ai/skills/sdx-analysis/reference/workflow-spec.md`
  - `.ai/skills/sdx-analysis/scripts/validate-analysis.sh`

### 2026-04-03 12:09:01.000 · git
- **提交**: `c3e8942a128a`
- **作者**: ouliyuan0129
- **信息**: 新增文档升级技能，支持定向编辑 Markdown 文档并链式同步引用。更新 README，补充技能说明与使用场景，提升用户理解与操作体验。新增技能创建指南，提供创建与更新技能的详细流程与示例。
- **文件**:
  - `.ai/skills/README.md`
  - `.ai/skills/docs-upgrade/SKILL.md`
  - `.ai/skills/docs-upgrade/agents/openai.yaml`
  - `.ai/skills/docs-upgrade/references/related-doc-discovery.md`
  - `.ai/skills/skill-creator/SKILL.md`
  - `.ai/skills/skill-creator/agents/openai.yaml`
  - `.ai/skills/skill-creator/assets/skill-creator-small.svg`
  - `.ai/skills/skill-creator/assets/skill-creator.png`
  - `.ai/skills/skill-creator/license.txt`
  - `.ai/skills/skill-creator/references/openai_yaml.md`
  - `.ai/skills/skill-creator/scripts/generate_openai_yaml.py`
  - `.ai/skills/skill-creator/scripts/init_skill.py`
  - `.ai/skills/skill-creator/scripts/quick_validate.py`

### 2026-04-01 15:32:28.000 · git
- **提交**: `ddd0da4aefb7`
- **作者**: ouliyuan0129
- **信息**: Merge branch 'features/feature-1.0.0-federated-docs'

### 2026-04-01 15:32:13.000 · git
- **提交**: `c2832c2eab9d`
- **作者**: ouliyuan0129
- **信息**: 更新 README，补充常见 Skill 说明与推荐流程。
- **文件**:
  - `README.md`

### 2026-04-01 15:20:07.000 · git
- **提交**: `8a146df519c5`
- **作者**: ouliyuan0129
- **信息**: Merge branch 'features/feature-1.0.0-federated-docs'

### 2026-04-01 15:19:35.000 · git
- **提交**: `0aac2bbd5edf`
- **作者**: ouliyuan0129
- **信息**: 更新 README.md，优化知识库初始化说明
- **文件**:
  - `README.md`

### 2026-04-01 15:19:23.000 · git
- **提交**: `ab6c96697833`
- **作者**: ouliyuan0129
- **信息**: 更新 README.md，优化初始化流程与入口导航
- **文件**:
  - `README.md`

### 2026-04-01 14:55:43.000 · git
- **提交**: `fc7b678f8508`
- **作者**: ouliyuan0129
- **信息**: Merge branch 'features/feature-1.0.0-federated-docs'

### 2026-04-01 14:45:33.000 · git
- **提交**: `8844ddd8578c`
- **作者**: ouliyuan0129
- **信息**: 更新文档与技能，统一 `document-indexing` 和 `document-change` 术语为 `docs-indexing` 和 `docs-change`
- **文件**:
  - `.ai/skills/agent-guide/SKILL.md`
  - `.ai/skills/agent-guide/gotchas.md`
  - `.ai/skills/agent-guide/reference/execution-spec.md`
  - `.ai/skills/agent-guide/reference/quality-standards.md`
  - `.ai/skills/docs-build/SKILL.md`
  - `.ai/skills/docs-build/gotchas.md`
  - `.ai/skills/docs-build/reference/builtin-config.md`
  - `.ai/skills/docs-change/SKILL.md`
  - `.ai/skills/docs-change/gotchas.md`
  - `.ai/skills/docs-change/reference/execution-spec.md`
  - `.ai/skills/docs-change/scripts/change-indexing.sh`
  - `.ai/skills/docs-indexing/SKILL.md`
  - `.ai/skills/docs-indexing/gotchas.md`
  - `.ai/skills/docs-indexing/reference/quality-standards.md`
  - `.ai/skills/docs-indexing/reference/scan-spec.md`
  - `.ai/skills/docs-indexing/scripts/indexing.sh`

### 2026-04-01 14:27:40.000 · git
- **提交**: `81708031de63`
- **作者**: ouliyuan0129
- **信息**: 更新文档与脚本，统一初始化与构建流程
- **文件**:
  - `.ai/rules/CONVENTIONS.md`
  - `.ai/skills/README.md`
  - `.ai/skills/docs-archive/SKILL.md`
  - `.ai/skills/docs-build/SKILL.md`
  - `.ai/skills/docs-build/assets/knowledge-index-template.md`
  - `.ai/skills/docs-build/assets/knowledge-schema-template.json`
  - `.ai/skills/docs-build/gotchas.md`
  - `.ai/skills/docs-build/reference/builtin-config.md`
  - `.ai/skills/docs-build/reference/consolidation-spec.md`
  - `.ai/skills/docs-build/reference/extraction-rules.md`
  - `.ai/skills/docs-build/reference/quality-checklist.md`
  - `.ai/skills/docs-build/reference/readme-fill-spec.md`
  - `.ai/skills/docs-build/scripts/validate-extraction.sh`
  - `.ai/skills/docs-change/SKILL.md`
  - `.ai/skills/docs-change/gotchas.md`
  - `.ai/skills/docs-indexing/SKILL.md`
  - `.ai/skills/sdx-analysis/SKILL.md`
  - `.ai/skills/sdx-design/SKILL.md`
  - `.ai/skills/sdx-design/gotchas.md`
  - `.ai/skills/sdx-prd/SKILL.md`
  - `.ai/skills/sdx-solution/SKILL.md`
  - `.ai/skills/sdx-test/SKILL.md`
  - `AGENTS.md`
  - `index.md`
  - `README.md`
  - `applications/APPLICATIONS_INDEX.md`
  - `applications/app-APPNAME/APPNAME_INDEX.md`
  - `applications/app-APPNAME/README.md`
  - `applications/app-APPNAME/application_meta.yaml`
  - `applications/app-APPNAME/knowledge/README.md`
  - … 另有 13 个文件

### 2026-04-01 13:45:08.000 · git
- **提交**: `23a9336eb231`
- **作者**: ouliyuan0129
- **信息**: 更新知识构建文档，调整阶段与内容结构以提升一致性
- **文件**:
  - `.ai/skills/knowledge-build/SKILL.md`
  - `.ai/skills/knowledge-build/gotchas.md`
  - `.ai/skills/knowledge-build/reference/builtin-config.md`
  - `.ai/skills/knowledge-build/reference/consolidation-spec.md`
  - `.ai/skills/knowledge-build/reference/quality-checklist.md`
  - `.ai/skills/knowledge-build/reference/readme-fill-spec.md`

### 2026-04-01 12:05:21.000 · git
- **提交**: `fd3ceb5ad860`
- **作者**: ouliyuan0129
- **信息**: 更新文档，强化深度 3（精读）执行规范与质量标准
- **文件**:
  - `.ai/skills/docs-indexing/SKILL.md`
  - `.ai/skills/docs-indexing/assets/index-guide-template.md`
  - `.ai/skills/docs-indexing/gotchas.md`
  - `.ai/skills/docs-indexing/reference/quality-standards.md`
  - `.ai/skills/docs-indexing/reference/scan-spec.md`

### 2026-04-01 11:11:15.000 · git
- **提交**: `6f5bd2ce14f8`
- **作者**: ouliyuan0129
- **信息**: 更新知识初始化脚本，统一索引名称以提升一致性
- **文件**:
  - `scripts/knowledge-init.sh`

### 2026-04-01 11:07:48.000 · git
- **提交**: `a3dcd0ba2e16`
- **作者**: ouliyuan0129
- **信息**: 更新知识初始化脚本，调整索引名称以提升一致性
- **文件**:
  - `scripts/knowledge-init.sh`

### 2026-04-01 11:07:41.000 · git
- **提交**: `5b960be2f566`
- **作者**: ouliyuan0129
- **信息**: 更新文档，强化用户确认机制与执行规范
- **文件**:
  - `.ai/skills/docs-indexing/SKILL.md`
  - `.ai/skills/docs-indexing/gotchas.md`

### 2026-03-31 21:21:37.000 · git
- **提交**: `52f160893942`
- **作者**: ouliyuan0129
- **信息**: Merge branch 'features/feature-1.0.0-federated-docs'

### 2026-03-31 21:21:00.000 · git
- **提交**: `9620df6ca97a`
- **作者**: ouliyuan0129
- **信息**: 更新知识库名称与相关路径，确保一致性
- **文件**:
  - `AGENTS.md`
  - `index.md`
  - `README.md`
  - `scripts/README.md`
  - `scripts/knowledge-config.sh`
  - `scripts/knowledge-init-bootstrap.sh`

### 2026-03-31 21:13:43.000 · git
- **提交**: `166f01546162`
- **作者**: ouliyuan0129
- **信息**: Merge branch 'features/feature-1.0.0-federated-docs'

### 2026-03-31 21:13:00.000 · git
- **提交**: `9e219b57968f`
- **作者**: ouliyuan0129
- **信息**: 更新文档与技能，提升一致性与可读性
- **文件**:
  - `.ai/README.md`
  - `.ai/rules/CONVENTIONS.md`
  - `.ai/skills/README.md`
  - `README.md`
  - `applications/README.md`
  - `scripts/README.md`
  - `system/README.md`
  - `system/changelogs/README.md`

### 2026-03-31 21:01:14.000 · git
- **提交**: `775b4ecfa1e8`
- **作者**: ouliyuan0129
- **信息**: 更新文档与技能，提升一致性与可读性
- **文件**:
  - `.ai/skills/docs-change/SKILL.md`
  - `.ai/skills/docs-change/assets/changes-index-template.json`
  - `.ai/skills/docs-change/assets/changes-index-template.md`
  - `.ai/skills/docs-change/gotchas.md`
  - `.ai/skills/docs-change/reference/execution-spec.md`
  - `.ai/skills/docs-change/scripts/change-indexing.sh`
  - `.ai/skills/docs-indexing/SKILL.md`
  - `.ai/skills/docs-indexing/assets/index-guide-template.md`
  - `.ai/skills/docs-indexing/gotchas.md`
  - `.ai/skills/docs-indexing/reference/nine-chapter-spec.md`
  - `.ai/skills/docs-indexing/reference/quality-standards.md`
  - `.ai/skills/docs-indexing/reference/scan-spec.md`
  - `.ai/skills/docs-indexing/scripts/indexing.sh`
  - `.ai/skills/document-indexing/scripts/indexing.sh`
  - `.ai/skills/knowledge-archive/SKILL.md`
  - `.ai/skills/knowledge-build/SKILL.md`
  - `.ai/skills/knowledge-build/assets/knowledge-index-template.md`
  - `.ai/skills/knowledge-build/assets/knowledge-schema-template.json`
  - `.ai/skills/knowledge-build/gotchas.md`
  - `.ai/skills/knowledge-build/reference/builtin-config.md`
  - `.ai/skills/knowledge-build/reference/consolidation-spec.md`
  - `.ai/skills/knowledge-build/reference/extraction-rules.md`
  - `.ai/skills/knowledge-build/reference/quality-checklist.md`
  - `.ai/skills/knowledge-build/scripts/validate-extraction.sh`
  - `.ai/skills/sdx-analysis/SKILL.md`
  - `.ai/skills/sdx-design/SKILL.md`
  - `.ai/skills/sdx-design/gotchas.md`
  - `.ai/skills/sdx-prd/SKILL.md`
  - `.ai/skills/sdx-solution/SKILL.md`
  - `.ai/skills/sdx-test/SKILL.md`
  - … 另有 15 个文件

### 2026-03-31 19:25:17.000 · git
- **提交**: `738d27c5886b`
- **作者**: ouliyuan0129
- **信息**: Merge branch 'features/feature-1.0.0-federated-docs'

### 2026-03-31 19:24:16.000 · git
- **提交**: `45f7f4007735`
- **作者**: ouliyuan0129
- **信息**: 更新知识初始化脚本，增强功能与文档一致性
- **文件**:
  - `scripts/README.md`
  - `scripts/knowledge-config.sh`
  - `scripts/knowledge-init.sh`

### 2026-03-31 18:58:10.000 · git
- **提交**: `9a2807b61997`
- **作者**: ouliyuan0129
- **信息**: 更新文档ID格式与模板，提升一致性与可读性
- **文件**:
  - `.ai/skills/sdx-analysis/assets/analysis-template.md`
  - `.ai/skills/sdx-analysis/reference/design-principles.md`
  - `.ai/skills/sdx-analysis/reference/workflow-spec.md`
  - `.ai/skills/sdx-solution/SKILL.md`
  - `.ai/skills/sdx-solution/assets/solution-template.md`
  - `.ai/skills/sdx-solution/gotchas.md`
  - `.ai/skills/sdx-solution/reference/core-concepts.md`
  - `.ai/skills/sdx-solution/reference/design-principles.md`
  - `.ai/skills/sdx-solution/reference/quality-checklist.md`
  - `.ai/skills/sdx-solution/reference/workflow-spec.md`
  - `.ai/skills/sdx-solution/scripts/validate-solution.sh`
  - `system/solutions/README.md`

### 2026-03-31 18:40:20.000 · git
- **提交**: `e98534c3f663`
- **作者**: ouliyuan0129
- **信息**: 更新技能文档与模板，提升一致性与可读性
- **文件**:
  - `.ai/skills/sdx-design/SKILL.md`
  - `.ai/skills/sdx-design/assets/add-template.md`
  - `.ai/skills/sdx-design/assets/spec-template.md`

### 2026-03-31 14:20:00.000 · git
- **提交**: `e1eccc928b2b`
- **作者**: ouliyuan0129
- **信息**: 更新文档结构与内容，提升一致性与可读性
- **文件**:
  - `.ai/skills/sdx-prd/SKILL.md`
  - `.ai/skills/sdx-prd/assets/prd-template.md`
  - `.ai/skills/sdx-prd/gotchas.md`
  - `.ai/skills/sdx-prd/reference/design-principles.md`
  - `.ai/skills/sdx-prd/reference/quality-checklist.md`
  - `.ai/skills/sdx-prd/reference/workflow-spec.md`
  - `.ai/skills/sdx-prd/scripts/validate-prd.sh`

### 2026-03-30 20:21:48.000 · git
- **提交**: `66156bded20f`
- **作者**: ouliyuan0129
- **信息**: 更新文档与质量标准，提升一致性与可读性
- **文件**:
  - `.ai/skills/agent-guide/SKILL.md`
  - `.ai/skills/agent-guide/gotchas.md`
  - `.ai/skills/agent-guide/reference/execution-spec.md`
  - `.ai/skills/agent-guide/reference/quality-standards.md`
  - `.ai/skills/agent-guide/reference/three-file-spec.md`
  - `.ai/skills/document-change/SKILL.md`
  - `.ai/skills/document-change/reference/execution-spec.md`
  - `.ai/skills/document-indexing/SKILL.md`
  - `.ai/skills/document-indexing/reference/quality-standards.md`
  - `.ai/skills/document-indexing/reference/scan-spec.md`
  - `.ai/skills/knowledge-extract/SKILL.md`
  - `.ai/skills/knowledge-extract/gotchas.md`
  - `.ai/skills/knowledge-extract/reference/builtin-config.md`
  - `.ai/skills/knowledge-extract/reference/consolidation-spec.md`
  - `.ai/skills/knowledge-extract/reference/design-principles.md`
  - `.ai/skills/knowledge-extract/reference/extraction-rules.md`
  - `.ai/skills/knowledge-extract/reference/quality-checklist.md`
  - `.ai/skills/sdx-analysis/SKILL.md`
  - `.ai/skills/sdx-analysis/assets/analysis-template.md`
  - `.ai/skills/sdx-analysis/gotchas.md`
  - `.ai/skills/sdx-analysis/reference/audience-and-language.md`
  - `.ai/skills/sdx-analysis/reference/core-concepts.md`
  - `.ai/skills/sdx-analysis/reference/design-principles.md`
  - `.ai/skills/sdx-analysis/reference/quality-checklist.md`
  - `.ai/skills/sdx-analysis/reference/workflow-spec.md`
  - `.ai/skills/sdx-design/SKILL.md`
  - `.ai/skills/sdx-design/assets/quality-gate-checklist.md`
  - `.ai/skills/sdx-design/gotchas.md`
  - `.ai/skills/sdx-design/reference/audience-and-language.md`
  - `.ai/skills/sdx-design/reference/core-concepts.md`
  - … 另有 26 个文件

### 2026-03-30 19:26:06.000 · git
- **提交**: `4e402081ddea`
- **作者**: ouliyuan0129
- **信息**: 更新文档路径与模板，提升一致性与可读性
- **文件**:
  - `.ai/README.md`
  - `.ai/rules/CONVENTIONS.md`
  - `.ai/skills/agent-guide/SKILL.md`
  - `.ai/skills/agent-guide/gotchas.md`
  - `.ai/skills/agent-guide/reference/execution-spec.md`
  - `.ai/skills/document-change/SKILL.md`
  - `.ai/skills/document-indexing/SKILL.md`
  - `.ai/skills/knowledge-archive/SKILL.md`
  - `.ai/skills/knowledge-build/SKILL.md`
  - `.ai/skills/knowledge-extract/SKILL.md`
  - `.ai/skills/knowledge-extract/gotchas.md`
  - `.ai/skills/knowledge-extract/reference/consolidation-spec.md`
  - `.ai/skills/knowledge-extract/reference/extraction-rules.md`
  - `.ai/skills/sdx-analysis/SKILL.md`
  - `.ai/skills/sdx-analysis/assets/analysis-template.md`
  - `.ai/skills/sdx-analysis/assets/quality-gate-checklist.md`
  - `.ai/skills/sdx-analysis/reference/design-principles.md`
  - `.ai/skills/sdx-analysis/reference/workflow-spec.md`
  - `.ai/skills/sdx-design/SKILL.md`
  - `.ai/skills/sdx-design/reference/design-principles.md`
  - `.ai/skills/sdx-design/reference/workflow-spec.md`
  - `.ai/skills/sdx-prd/SKILL.md`
  - `.ai/skills/sdx-prd/reference/design-principles.md`
  - `.ai/skills/sdx-prd/reference/workflow-spec.md`
  - `.ai/skills/sdx-solution/SKILL.md`
  - `.ai/skills/sdx-solution/reference/design-principles.md`
  - `.ai/skills/sdx-solution/reference/workflow-spec.md`
  - `.ai/skills/sdx-test/SKILL.md`
  - `.ai/skills/sdx-test/reference/design-principles.md`
  - `.ai/skills/sdx-test/reference/workflow-spec.md`
  - … 另有 32 个文件

### 2026-03-30 16:54:41.000 · git
- **提交**: `c350e56ca2a1`
- **作者**: ouliyuan0129
- **信息**: 更新文档与模板，提升一致性与可读性
- **文件**:
  - `.ai/rules/CONVENTIONS.md`
  - `.ai/rules/coding/git-guidelines.md`
  - `.ai/rules/coding/maven-guidelines.md`
  - `.ai/rules/coding/project-structure.md`
  - `.ai/rules/design/api-readme-template.md`
  - `.ai/rules/design/architecture-template.md`
  - `.ai/rules/design/design-template.md`
  - `.ai/skills/agent-guide/assets/agents-skeleton.md`
  - `.ai/skills/sdx-design/assets/add-template.md`

### 2026-03-29 18:26:52.000 · git
- **提交**: `d57f1312a17c`
- **作者**: ouliyuan0129
- **信息**: 更新文档路径与模板，提升一致性与可读性
- **文件**:
  - `.ai/skills/agent-guide/SKILL.md`
  - `.ai/skills/agent-guide/reference/execution-spec.md`
  - `.ai/skills/agent-guide/scripts/validate-guide.sh`
  - `.ai/skills/knowledge-archive/SKILL.md`
  - `.ai/skills/sdx-design/SKILL.md`
  - `.ai/skills/sdx-design/assets/add-template.md`
  - `.ai/skills/sdx-design/reference/workflow-spec.md`
  - `.ai/skills/sdx-prd/assets/prd-template.md`
  - `.ai/skills/sdx-prd/reference/workflow-spec.md`
  - `.ai/skills/sdx-solution/scripts/validate-solution.sh`
  - `.ai/skills/sdx-test/SKILL.md`
  - `.ai/skills/sdx-test/assets/tdd-template.md`
  - `.ai/skills/sdx-test/reference/workflow-spec.md`
  - `AGENTS.md`
  - `index.md`
  - `README.md`
  - `applications/APPLICATIONS_INDEX.md`
  - `applications/README.md`
  - `applications/app-APPNAME/APPNAME_INDEX.md`
  - `applications/app-APPNAME/README.md`
  - `applications/app-APPNAME/application_meta.yaml`
  - `applications/app-APPNAME/changelogs/CHANGELOG.md`
  - `applications/app-APPNAME/changelogs/README.md`
  - `applications/app-APPNAME/changelogs/changelogs_meta.yaml`
  - `applications/app-APPNAME/knowledge/README.md`
  - `applications/app-APPNAME/knowledge/business/README.md`
  - `applications/app-APPNAME/knowledge/constitution/README.md`
  - `applications/app-APPNAME/knowledge/data/README.md`
  - `applications/app-APPNAME/knowledge/knowledge_meta.yaml`
  - `applications/app-APPNAME/knowledge/product/README.md`
  - … 另有 11 个文件

### 2026-03-29 18:01:24.000 · git
- **提交**: `6f57a8349247`
- **作者**: ouliyuan0129
- **信息**: 更新文档路径与模板，确保一致性与可读性
- **文件**:
  - `.ai/README.md`
  - `.ai/rules/CONVENTIONS.md`
  - `.ai/rules/agents-template.md`
  - `.ai/rules/design/api-readme-template.md`
  - `.ai/skills/README.md`
  - `.ai/skills/agent-guide/SKILL.md`
  - `.ai/skills/agent-guide/assets/agents-skeleton.md`
  - `.ai/skills/agent-guide/assets/readme-skeleton.md`
  - `.ai/skills/agent-guide/gotchas.md`
  - `.ai/skills/agent-guide/reference/execution-spec.md`
  - `.ai/skills/agent-guide/scripts/validate-guide.sh`
  - `.ai/skills/document-change/SKILL.md`
  - `.ai/skills/document-change/gotchas.md`
  - `.ai/skills/document-indexing/SKILL.md`
  - `.ai/skills/document-indexing/assets/index-guide-template.md`
  - `.ai/skills/document-indexing/gotchas.md`
  - `.ai/skills/document-indexing/reference/nine-chapter-spec.md`
  - `.ai/skills/document-indexing/reference/quality-standards.md`
  - `.ai/skills/document-indexing/scripts/indexing.sh`
  - `.ai/skills/knowledge-archive/SKILL.md`
  - `.ai/skills/knowledge-build/SKILL.md`
  - `.ai/skills/knowledge-extract/SKILL.md`
  - `.ai/skills/sdx-analysis/SKILL.md`
  - `.ai/skills/sdx-analysis/gotchas.md`
  - `.ai/skills/sdx-analysis/reference/design-principles.md`
  - `.ai/skills/sdx-analysis/reference/workflow-spec.md`
  - `.ai/skills/sdx-design/SKILL.md`
  - `.ai/skills/sdx-design/assets/add-template.md`
  - `.ai/skills/sdx-design/reference/design-principles.md`
  - `.ai/skills/sdx-design/reference/workflow-spec.md`
  - … 另有 63 个文件

### 2026-03-29 14:17:32.000 · git
- **提交**: `b2ed9377ff3a`
- **作者**: ouliyuan0129
- **信息**: 更新文档路径与模板，提升一致性与可读性
- **文件**:
  - `.ai/README.md`
  - `.ai/rules/CONVENTIONS.md`
  - `.ai/rules/design/api-readme-template.md`
  - `.ai/skills/README.md`
  - `.ai/skills/agent-guide/SKILL.md`
  - `.ai/skills/agent-guide/assets/agents-skeleton.md`
  - `.ai/skills/agent-guide/assets/readme-skeleton.md`
  - `.ai/skills/agent-guide/gotchas.md`
  - `.ai/skills/agent-guide/reference/execution-spec.md`
  - `.ai/skills/document-change/SKILL.md`
  - `.ai/skills/document-indexing/SKILL.md`
  - `.ai/skills/knowledge-archive/SKILL.md`
  - `.ai/skills/knowledge-build/SKILL.md`
  - `.ai/skills/knowledge-extract/SKILL.md`
  - `.ai/skills/knowledge-extract/reference/consolidation-spec.md`
  - `.ai/skills/sdx-analysis/SKILL.md`
  - `.ai/skills/sdx-analysis/assets/analysis-template.md`
  - `.ai/skills/sdx-analysis/assets/quality-gate-checklist.md`
  - `.ai/skills/sdx-analysis/reference/design-principles.md`
  - `.ai/skills/sdx-analysis/reference/workflow-spec.md`
  - `.ai/skills/sdx-design/SKILL.md`
  - `.ai/skills/sdx-design/reference/design-principles.md`
  - `.ai/skills/sdx-design/reference/workflow-spec.md`
  - `.ai/skills/sdx-prd/SKILL.md`
  - `.ai/skills/sdx-prd/assets/quality-gate-checklist.md`
  - `.ai/skills/sdx-prd/reference/design-principles.md`
  - `.ai/skills/sdx-prd/reference/workflow-spec.md`
  - `.ai/skills/sdx-solution/SKILL.md`
  - `.ai/skills/sdx-solution/reference/design-principles.md`
  - `.ai/skills/sdx-solution/reference/workflow-spec.md`
  - … 另有 49 个文件

### 2026-03-29 13:59:39.000 · git
- **提交**: `b4444f569528`
- **作者**: ouliyuan0129
- **信息**: 更新文档路径与模板，确保一致性与可读性
- **文件**:
  - `.ai/rules/CONVENTIONS.md`
  - `.ai/rules/testing/tdd-template.md`
  - `.ai/skills/README.md`
  - `.ai/skills/agent-guide/SKILL.md`
  - `.ai/skills/agent-guide/assets/agents-skeleton.md`
  - `.ai/skills/agent-guide/reference/execution-spec.md`
  - `.ai/skills/knowledge-archive/SKILL.md`
  - `.ai/skills/knowledge-extract/SKILL.md`
  - `.ai/skills/sdx-analysis/SKILL.md`
  - `.ai/skills/sdx-analysis/reference/design-principles.md`
  - `.ai/skills/sdx-design/SKILL.md`
  - `.ai/skills/sdx-design/assets/add-template.md`
  - `.ai/skills/sdx-design/reference/design-principles.md`
  - `.ai/skills/sdx-design/reference/workflow-spec.md`
  - `.ai/skills/sdx-design/scripts/validate-design.sh`
  - `.ai/skills/sdx-prd/SKILL.md`
  - `.ai/skills/sdx-prd/assets/prd-template.md`
  - `.ai/skills/sdx-prd/reference/design-principles.md`
  - `.ai/skills/sdx-prd/reference/workflow-spec.md`
  - `.ai/skills/sdx-prd/scripts/validate-prd.sh`
  - `.ai/skills/sdx-solution/SKILL.md`
  - `.ai/skills/sdx-solution/reference/design-principles.md`
  - `.ai/skills/sdx-solution/scripts/validate-solution.sh`
  - `.ai/skills/sdx-test/SKILL.md`
  - `.ai/skills/sdx-test/assets/tdd-template.md`
  - `.ai/skills/sdx-test/gotchas.md`
  - `.ai/skills/sdx-test/reference/design-principles.md`
  - `.ai/skills/sdx-test/reference/workflow-spec.md`
  - `.ai/skills/sdx-test/scripts/validate-test.sh`
  - `.cursor/README.md`
  - … 另有 3 个文件

### 2026-03-28 19:40:58.000 · git
- **提交**: `6143343af057`
- **作者**: ouliyuan0129
- **信息**: 更新文档路径与模板，确保一致性与可读性
- **文件**:
  - `.ai/rules/CONVENTIONS.md`
  - `.ai/rules/analysis/analysis-template.md`
  - `.ai/rules/solution/solution-template.md`
  - `.ai/skills/sdx-analysis/scripts/validate-analysis.sh`
  - `AGENTS.md`
  - `index.md`
  - `README.md`
  - `scripts/README.md`
  - `scripts/knowledge-init.sh`
  - `system/SYSTEM_INDEX.md`
  - `system/analysis/README.md`
  - `system/analysis/analysis_meta.yaml`
  - `system/solutions/README.md`
  - `system/solutions/solutions_meta.yaml`

### 2026-03-28 19:10:24.000 · git
- **提交**: `bbe98c1e3a22`
- **作者**: ouliyuan0129
- **信息**: 更新需求分析文档模板与相关文档路径，确保一致性与可读性
- **文件**:
  - `.ai/rules/CONVENTIONS.md`
  - `.ai/skills/sdx-analysis/SKILL.md`
  - `.ai/skills/sdx-analysis/assets/analysis-template.md`
  - `.ai/skills/sdx-analysis/assets/quality-gate-checklist.md`
  - `.ai/skills/sdx-analysis/reference/design-principles.md`
  - `.ai/skills/sdx-analysis/reference/workflow-spec.md`
  - `system/analysis/README.md`

### 2026-03-28 19:09:47.000 · git
- **提交**: `0b194e8a4b52`
- **作者**: ouliyuan0129
- **信息**: 更新解决方案文档模板与质量门禁清单，调整章节结构与内容规范
- **文件**:
  - `.ai/rules/CONVENTIONS.md`
  - `.ai/skills/sdx-solution/SKILL.md`
  - `.ai/skills/sdx-solution/assets/quality-gate-checklist.md`
  - `.ai/skills/sdx-solution/assets/solution-template.md`
  - `.ai/skills/sdx-solution/gotchas.md`
  - `.ai/skills/sdx-solution/reference/audience-language-spec.md`
  - `.ai/skills/sdx-solution/reference/design-principles.md`
  - `.ai/skills/sdx-solution/reference/workflow-spec.md`
  - `.ai/skills/sdx-solution/scripts/validate-solution.sh`
  - `system/solutions/README.md`

### 2026-03-28 09:59:44.000 · git
- **提交**: `aece5c023d01`
- **作者**: ouliyuan0129
- **信息**: 新增多个技能的常见陷阱文档，涵盖 agent-guide、document-change、document-indexing、knowledge-extract、sdx-analysis、sdx-design、sdx-prd 和 sdx-solution 等技能的执行注意事项，提升开发者与 Agent 的参考价值。
- **文件**:
  - `.ai/skills/agent-guide/gotchas.md`
  - `.ai/skills/document-change/gotchas.md`
  - `.ai/skills/document-indexing/gotchas.md`
  - `.ai/skills/knowledge-build/assets/acceptance-checklist.md`
  - `.ai/skills/knowledge-build/reference/builtin-config.md`
  - `.ai/skills/knowledge-build/reference/design-principles.md`
  - `.ai/skills/knowledge-build/reference/phase-three-spec.md`
  - `.ai/skills/knowledge-build/scripts/validate-knowledge.sh`
  - `.ai/skills/knowledge-extract/gotchas.md`
  - `.ai/skills/sdx-analysis/gotchas.md`
  - `.ai/skills/sdx-design/gotchas.md`
  - `.ai/skills/sdx-prd/gotchas.md`
  - `.ai/skills/sdx-solution/gotchas.md`
  - `.ai/skills/sdx-test/gotchas.md`

### 2026-03-28 00:13:40.000 · git
- **提交**: `ac17ffedfcbd`
- **作者**: ouliyuan0129
- **信息**: 更新知识提取模板与文档，修正系统路径
- **文件**:
  - `.ai/skills/knowledge-extract/assets/knowledge-schema-template.json`
  - `system/SYSTEM_INDEX.md`

### 2026-03-28 00:13:26.000 · git
- **提交**: `bacf459b229b`
- **作者**: ouliyuan0129
- **信息**: 更新知识提取模板与文档，调整系统与服务名称为“计费申诉”
- **文件**:
  - `.ai/skills/knowledge-build/reference/phase-three-spec.md`
  - `.ai/skills/knowledge-extract/assets/knowledge-schema-template.json`
  - `.ai/skills/knowledge-extract/reference/consolidation-spec.md`
  - `.ai/skills/knowledge-extract/reference/extraction-rules.md`
  - `.ai/skills/sdx-analysis/reference/design-principles.md`
  - `.ai/skills/sdx-design/reference/design-principles.md`
  - `.ai/skills/sdx-solution/reference/design-principles.md`
  - `.ai/skills/sdx-test/reference/design-principles.md`
  - `applications/app-APPNAME/knowledge/README.md`
  - `applications/app-APPNAME/knowledge/constitution/standards/naming-conventions.md`
  - `system/SYSTEM_INDEX.md`
  - `system/knowledge/README.md`
  - `system/knowledge/constitution/standards/naming-conventions.md`

### 2026-03-27 23:56:38.000 · git
- **提交**: `c86a1b281cce`
- **作者**: ouliyuan0129
- **信息**: 更新知识提取模板与文档，调整系统与服务名称
- **文件**:
  - `.ai/skills/knowledge-extract/assets/knowledge-schema-template.json`
  - `.ai/skills/knowledge-extract/reference/extraction-rules.md`
  - `applications/INDEX.md`
  - `system/INDEX.md`
  - `system/SYSTEM_INDEX.md`

### 2026-03-27 23:26:11.000 · git
- **提交**: `69bf2654e712`
- **作者**: ouliyuan0129
- **信息**: 更新文档与技能说明，调整知识库初始化脚本路径
- **文件**:
  - `.ai/README.md`
  - `.ai/rules/analysis/analysis-template.md`
  - `.ai/rules/requirement/prd-template.md`
  - `.ai/rules/solution/solution-template.md`
  - `.ai/skills/README.md`
  - `.ai/skills/agent-guide/SKILL.md`
  - `.ai/skills/agent-guide/assets/agents-skeleton.md`
  - `.ai/skills/agent-guide/assets/readme-skeleton.md`
  - `.ai/skills/agent-guide/reference/execution-spec.md`
  - `.ai/skills/agent-guide/scripts/validate-guide.sh`
  - `.ai/skills/document-change/SKILL.md`
  - `.ai/skills/document-change/assets/changes-index-template.json`
  - `.ai/skills/document-change/assets/changes-index-template.md`
  - `.ai/skills/document-change/reference/execution-spec.md`
  - `.ai/skills/document-change/scripts/change-indexing.sh`
  - `.ai/skills/document-indexing/SKILL.md`
  - `.ai/skills/document-indexing/assets/index-guide-template.md`
  - `.ai/skills/document-indexing/reference.md`
  - `.ai/skills/document-indexing/reference/nine-chapter-spec.md`
  - `.ai/skills/document-indexing/reference/quality-standards.md`
  - `.ai/skills/document-indexing/scripts/indexing.sh`
  - `.ai/skills/knowledge-build/SKILL.md`
  - `.ai/skills/knowledge-build/assets/acceptance-checklist.md`
  - `.ai/skills/knowledge-build/reference/builtin-config.md`
  - `.ai/skills/knowledge-build/reference/design-principles.md`
  - `.ai/skills/knowledge-build/reference/phase-three-spec.md`
  - `.ai/skills/knowledge-build/scripts/validate-knowledge.sh`
  - `.ai/skills/knowledge-extract/SKILL.md`
  - `.ai/skills/knowledge-extract/assets/knowledge-index-template.md`
  - `.ai/skills/knowledge-extract/assets/knowledge-schema-template.json`
  - … 另有 107 个文件

### 2026-03-22 20:40:54.000 · git
- **提交**: `8509a110903e`
- **作者**: ouliyuan0129
- **信息**: 更新文档索引与技能说明，调整 `read_mode` 相关描述
- **文件**:
  - `.ai/skills/README.md`
  - `.ai/skills/agent-guide/SKILL.md`
  - `.ai/skills/document-indexing/SKILL.md`
  - `.ai/skills/document-indexing/reference.md`
  - `.ai/skills/knowledge-build/SKILL.md`
  - `.ai/skills/knowledge-upgrade/SKILL.md`

### 2026-03-22 19:16:47.000 · git
- **提交**: `98e7b68a7565`
- **作者**: ouliyuan0129
- **信息**: fix: 更新文档索引与技能说明
- **文件**:
  - `.ai/README.md`
  - `.ai/rules/agents-template.md`
  - `.ai/skills/README.md`
  - `.ai/skills/agent-guide/SKILL.md`
  - `.ai/skills/document-indexing/SKILL.md`
  - `.ai/skills/document-indexing/reference.md`
  - `.ai/skills/knowledge-archive/SKILL.md`
  - `.ai/skills/knowledge-build/SKILL.md`
  - `.ai/skills/knowledge-extract/SKILL.md`
  - `.ai/skills/knowledge-upgrade/SKILL.md`
  - `.cursor/README.md`
  - `.cursor/skills/agent-guide/SKILL.md`
  - `.cursor/skills/document-change/SKILL.md`
  - `.cursor/skills/document-indexing/SKILL.md`
  - `.cursor/skills/knowledge-archive/SKILL.md`
  - `.cursor/skills/knowledge-build/SKILL.md`
  - `.cursor/skills/knowledge-upgrade/SKILL.md`
  - `AGENTS.md`
  - `INDEX.md`
  - `index.md`
  - `PROJECT_INDEX.md`
  - `README.md`
  - `applications/APPLICATIONS_INDEX.md`
  - `applications/INDEX.md`
  - `applications/README.md`
  - `applications/app-APPNAME/README.md`
  - `applications/app-APPNAME/application_meta.yaml`
  - `applications/app-APPNAME/knowledge/README.md`
  - `applications/app-APPNAME/knowledge/business/README.md`
  - `applications/app-APPNAME/knowledge/constitution/README.md`
  - … 另有 32 个文件

### 2026-03-21 14:49:27.000 · git
- **提交**: `5c4921b1869a`
- **作者**: ouliyuan0129
- **信息**: feat: 新增应用知识库元数据与文档结构
- **文件**:
  - `applications/app-APPNAME/README.md`
  - `applications/app-APPNAME/application_meta.yaml`
  - `applications/app-APPNAME/changelogs/CHANGELOG.md`
  - `applications/app-APPNAME/changelogs/README.md`
  - `applications/app-APPNAME/changelogs/changelogs_meta.yaml`
  - `applications/app-APPNAME/knowledge/README.md`
  - `applications/app-APPNAME/knowledge/business/README.md`
  - `applications/app-APPNAME/knowledge/business/business_meta.yaml`
  - `applications/app-APPNAME/knowledge/constitution/GLOSSARY.md`
  - `applications/app-APPNAME/knowledge/constitution/README.md`
  - `applications/app-APPNAME/knowledge/constitution/adr/adr-template.md`
  - `applications/app-APPNAME/knowledge/constitution/adr/adr_meta.yaml`
  - `applications/app-APPNAME/knowledge/constitution/constitution_meta.yaml`
  - `applications/app-APPNAME/knowledge/constitution/principles/architecture-principles.yaml`
  - `applications/app-APPNAME/knowledge/constitution/principles/principles_meta.yaml`
  - `applications/app-APPNAME/knowledge/constitution/standards/naming-conventions.md`
  - `applications/app-APPNAME/knowledge/constitution/standards/standards_meta.yaml`
  - `applications/app-APPNAME/knowledge/data/DATA-ARCHITECTURE.md`
  - `applications/app-APPNAME/knowledge/data/README.md`
  - `applications/app-APPNAME/knowledge/data/data_meta.yaml`
  - `applications/app-APPNAME/knowledge/knowledge_meta.yaml`
  - `applications/app-APPNAME/knowledge/product/README.md`
  - `applications/app-APPNAME/knowledge/product/product_meta.yaml`
  - `applications/app-APPNAME/knowledge/technical/README.md`
  - `applications/app-APPNAME/knowledge/technical/SYSTEM-ARCHITECTURE.md`
  - `applications/app-APPNAME/knowledge/technical/technical_meta.yaml`
  - `applications/app-APPNAME/manifest.yaml`
  - `applications/app-APPNAME/requirements/README.md`
  - `applications/app-APPNAME/requirements/requirements_meta.yaml`

### 2026-03-21 12:18:03.000 · git
- **提交**: `0a42ad3b96e4`
- **作者**: ouliyuan0129
- **信息**: fix: 统一知识库文档命名与路径规范
- **文件**:
  - `.ai/rules/CONVENTIONS.md`
  - `.ai/rules/analysis/analysis-template.md`
  - `.ai/rules/requirement/add-template.md`
  - `.ai/rules/requirement/prd-template.md`
  - `.ai/rules/solution/solution-template.md`
  - `.ai/skills/knowledge-archive/SKILL.md`
  - `.ai/skills/knowledge-upgrade/SKILL.md`
  - `.cursor/skills/knowledge-archive/SKILL.md`
  - `.cursor/skills/knowledge-upgrade/SKILL.md`
  - `.cursor/skills/sdx-analysis/SKILL.md`
  - `.cursor/skills/sdx-design/SKILL.md`
  - `.cursor/skills/sdx-prd/SKILL.md`
  - `.cursor/skills/sdx-solution/SKILL.md`
  - `AGENTS.md`
  - `INDEX.md`
  - `README.md`
  - `applications/INDEX.md`
  - `applications/app-APPNAME/INDEX.md`
  - `applications/app-APPNAME/README.md`
  - `applications/app-APPNAME/application_meta.yaml`
  - `applications/app-APPNAME/changelogs/CHANGELOG.md`
  - `applications/app-APPNAME/changelogs/README.md`
  - `applications/app-APPNAME/changelogs/changelogs_meta.yaml`
  - `applications/app-APPNAME/changelogs/indexing-log.jsonl`
  - `applications/app-APPNAME/knowledge/README.md`
  - `applications/app-APPNAME/knowledge/business/AGG_meta.yaml`
  - `applications/app-APPNAME/knowledge/business/BC_meta.yaml`
  - `applications/app-APPNAME/knowledge/business/BD_meta.yaml`
  - `applications/app-APPNAME/knowledge/business/BSD_meta.yaml`
  - `applications/app-APPNAME/knowledge/business/README.md`
  - … 另有 80 个文件

### 2026-03-20 14:00:23.000 · git
- **提交**: `0364a84bfd04`
- **作者**: ouliyuan0129
- **信息**: feat: 更新知识库结构与文档一致性
- **文件**:
  - `.ai/README.md`
  - `.ai/skills/README.md`
  - `.ai/skills/agent-guide/SKILL.md`
  - `.ai/skills/document-change/SKILL.md`
  - `.ai/skills/document-indexing/SKILL.md`
  - `.ai/skills/knowledge-archive/SKILL.md`
  - `.ai/skills/knowledge-build/SKILL.md`
  - `.ai/skills/knowledge-upgrade/SKILL.md`
  - `.cursor/README.md`
  - `.cursor/skills/agent-guide/SKILL.md`
  - `.cursor/skills/document-change/SKILL.md`
  - `.cursor/skills/document-indexing/SKILL.md`
  - `.cursor/skills/knowledge-archive/SKILL.md`
  - `.cursor/skills/knowledge-build/SKILL.md`
  - `.cursor/skills/knowledge-upgrade/SKILL.md`
  - `AGENTS.md`
  - `INDEX.md`
  - `README.md`
  - `applications/INDEX.md`
  - `applications/README.md`
  - `applications/app-APPNAME/INDEX.md`
  - `applications/app-APPNAME/README.md`
  - `applications/app-APPNAME/application_meta.yaml`
  - `applications/app-APPNAME/changelogs/CHANGELOG.md`
  - `applications/app-APPNAME/changelogs/README.md`
  - `applications/app-APPNAME/changelogs/changelogs_meta.yaml`
  - `applications/app-APPNAME/changelogs/indexing-log.jsonl`
  - `applications/app-APPNAME/knowledge/README.md`
  - `applications/app-APPNAME/knowledge/_meta.yaml`
  - `applications/app-APPNAME/knowledge/business/AGG_meta.yaml`
  - … 另有 117 个文件

### 2026-03-19 16:57:44.000 · git
- **提交**: `48c38a6c4d69`
- **作者**: ouliyuan0129
- **信息**: feat: 更新知识库结构与模板示例
- **文件**:
  - `.ai/skills/agent-guide/SKILL.md`
  - `.ai/skills/knowledge-archive/SKILL.md`
  - `.ai/skills/knowledge-build/SKILL.md`
  - `.ai/skills/knowledge-upgrade/SKILL.md`
  - `.cursor/skills/agent-guide/SKILL.md`
  - `.cursor/skills/knowledge-build/SKILL.md`
  - `.cursor/skills/sdx-analysis/SKILL.md`
  - `.cursor/skills/sdx-design/SKILL.md`
  - `.cursor/skills/sdx-prd/SKILL.md`
  - `.cursor/skills/sdx-solution/SKILL.md`
  - `.cursor/skills/sdx-test/SKILL.md`
  - `applications/INDEX.md`
  - `applications/README.md`
  - `applications/app-APPNAME/INDEX.md`
  - `applications/app-APPNAME/README.md`
  - `applications/app-APPNAME/changelogs/CHANGELOG.md`
  - `applications/app-APPNAME/changelogs/_meta.yaml`
  - `applications/app-APPNAME/knowledge/README.md`
  - `applications/app-APPNAME/knowledge/_meta.yaml`
  - `applications/app-APPNAME/knowledge/business/BD-ORDER/BSD-FULFILLMENT/BC-ORDER-MGMT/_meta.yaml`
  - `applications/app-APPNAME/knowledge/business/BD-ORDER/BSD-FULFILLMENT/BC-ORDER-MGMT/aggregates/AGG-ORDER.yaml`
  - `applications/app-APPNAME/knowledge/business/BD-ORDER/BSD-FULFILLMENT/_meta.yaml`
  - `applications/app-APPNAME/knowledge/business/BD-ORDER/_meta.yaml`
  - `applications/app-APPNAME/knowledge/business/README.md`
  - `applications/app-APPNAME/knowledge/business/_meta.yaml`
  - `applications/app-APPNAME/knowledge/constitution/GLOSSARY.md`
  - `applications/app-APPNAME/knowledge/constitution/README.md`
  - `applications/app-APPNAME/knowledge/constitution/adr/ADR-001-knowledge-repo-structure.md`
  - `applications/app-APPNAME/knowledge/constitution/principles/architecture-principles.yaml`
  - `applications/app-APPNAME/knowledge/constitution/standards/adr-template.md`
  - … 另有 81 个文件

### 2026-03-19 14:31:06.000 · git
- **提交**: `326ba72b1c64`
- **作者**: ouliyuan0129
- **信息**: feat: 更新文档结构与索引指南
- **文件**:
  - `.ai/skills/agent-guide/SKILL.md`
  - `.cursor/skills/agent-guide/SKILL.md`
  - `AGENTS.md`
  - `INDEX.md`
  - `README.md`

### 2026-03-19 12:23:59.000 · git
- **提交**: `4df47058656f`
- **作者**: ouliyuan0129
- **信息**: feat: 更新索引生成与变更记录功能
- **文件**:
  - `.ai/skills/README.md`
  - `.ai/skills/document-change/SKILL.md`
  - `.ai/skills/document-indexing/SKILL.md`
  - `.cursor/README.md`
  - `.cursor/skills/document-change/SKILL.md`
  - `.cursor/skills/document-indexing/SKILL.md`
  - `INDEX.md`
  - `system/changelogs/changes-index.json`
  - `system/changelogs/changes-index.md`
  - `system/changelogs/indexing-log.jsonl`

### 2026-03-19 10:09:57.000 · git
- **提交**: `84fbd9cc5d9f`
- **作者**: ouliyuan0129
- **信息**: feat: 删除过时的 AI 代理和工作流配置文件
- **文件**:
  - `.ai/agents.yaml`
  - `.ai/context/project-context.yaml`
  - `.ai/rules/CONVENTIONS.md`
  - `.ai/rules/agents-template.md`
  - `.ai/skills/README.md`
  - `.ai/workflows.yaml`
  - `scripts/README.md`
  - `scripts/knowledge-init.sh`
  - `system/INDEX.md`
  - `system/knowledge/technical/SYS-ECOMMERCE-BACKEND/APP-POLICY-APPEAL/APP-POLICY-APPEAL.yaml`

### 2026-03-18 22:16:43.000 · git
- **提交**: `907ea5a830fe`
- **作者**: ouliyuan0129
- **信息**: feat: 新增应用知识库索引和初始化脚本
- **文件**:
  - `applications/app-APPNAME/INDEX.md`
  - `applications/app-APPNAME/README.md`
  - `scripts/README.md`
  - `scripts/knowledge-init.sh`
  - `system/INDEX.md`

### 2026-03-18 21:34:49.000 · git
- **提交**: `6e362751db65`
- **作者**: ouliyuan0129
- **信息**: feat: 完善应用知识库结构与元数据
- **文件**:
  - `applications/INDEX.md`
  - `applications/README.md`
  - `applications/app-APPNAME/changelogs/CHANGELOG.md`
  - `applications/app-APPNAME/changelogs/_meta.yaml`
  - `applications/app-APPNAME/knowledge/README.md`
  - `applications/app-APPNAME/knowledge/_meta.yaml`
  - `applications/app-APPNAME/knowledge/business/BD-ORDER/BSD-FULFILLMENT/BC-ORDER-MGMT/_meta.yaml`
  - `applications/app-APPNAME/knowledge/business/BD-ORDER/BSD-FULFILLMENT/BC-ORDER-MGMT/aggregates/AGG-ORDER.yaml`
  - `applications/app-APPNAME/knowledge/business/BD-ORDER/BSD-FULFILLMENT/_meta.yaml`
  - `applications/app-APPNAME/knowledge/business/BD-ORDER/_meta.yaml`
  - `applications/app-APPNAME/knowledge/business/README.md`
  - `applications/app-APPNAME/knowledge/business/_meta.yaml`
  - `applications/app-APPNAME/knowledge/constitution/GLOSSARY.md`
  - `applications/app-APPNAME/knowledge/constitution/README.md`
  - `applications/app-APPNAME/knowledge/constitution/adr/ADR-001-knowledge-repo-structure.md`
  - `applications/app-APPNAME/knowledge/constitution/principles/architecture-principles.yaml`
  - `applications/app-APPNAME/knowledge/constitution/standards/adr-template.md`
  - `applications/app-APPNAME/knowledge/constitution/standards/naming-conventions.md`
  - `applications/app-APPNAME/knowledge/data/DATA-ARCHITECTURE.md`
  - `applications/app-APPNAME/knowledge/data/DS-ORDER-MYSQL-PRIMARY/README.md`
  - `applications/app-APPNAME/knowledge/data/DS-ORDER-MYSQL-PRIMARY/_meta.yaml`
  - `applications/app-APPNAME/knowledge/data/DS-ORDER-MYSQL-PRIMARY/schema/ENT-T_ORDER.yaml`
  - `applications/app-APPNAME/knowledge/data/DS-ORDER-MYSQL-PRIMARY/schema/ENT-T_ORDER_ITEMS.yaml`
  - `applications/app-APPNAME/knowledge/data/README.md`
  - `applications/app-APPNAME/knowledge/data/_meta.yaml`
  - `applications/app-APPNAME/knowledge/product/PM-SHOPPING-CART/BUSINESS-RULES.md`
  - `applications/app-APPNAME/knowledge/product/PM-SHOPPING-CART/FEATURE-MAP.md`
  - `applications/app-APPNAME/knowledge/product/PM-SHOPPING-CART/USER-STORIES.md`
  - `applications/app-APPNAME/knowledge/product/PM-SHOPPING-CART/_meta.yaml`
  - `applications/app-APPNAME/knowledge/product/PM-SHOPPING-CART/features/FT-ADD-TO-CART.yaml`
  - … 另有 25 个文件

### 2026-03-18 20:59:48.000 · git
- **提交**: `594e3a3f887a`
- **作者**: ouliyuan0129
- **信息**: feat: 新增各阶段目录元数据以支持项目结构化管理
- **文件**:
  - `system/analysis/_meta.yaml`
  - `system/changelogs/_meta.yaml`
  - `system/knowledge/_meta.yaml`
  - `system/knowledge/knowledge-base.config.yaml`
  - `system/requirements/_meta.yaml`
  - `system/solutions/_meta.yaml`
  - `system/specs/_meta.yaml`

### 2026-03-18 18:12:05.000 · git
- **提交**: `36fd1bd4b784`
- **作者**: ouliyuan0129
- **信息**: feat: 新增项目拷贝脚本以简化仓库内容复制
- **文件**:
  - `scripts/project-copy.sh`

### 2026-03-18 17:01:22.000 · git
- **提交**: `c3f8ccc10dbe`
- **作者**: ouliyuan0129
- **信息**: docs: 新增知识库根外内容清理步骤以防止双套知识库
- **文件**:
  - `.ai/skills/knowledge-build/SKILL.md`
  - `.cursor/skills/knowledge-build/SKILL.md`

### 2026-03-18 16:26:49.000 · git
- **提交**: `65a8ed7a3cda`
- **作者**: ouliyuan0129
- **信息**: Merge branch 'features/feature-1.0.0-federated-docs'

### 2026-03-18 16:13:17.000 · git
- **提交**: `8891828a066a`
- **作者**: ouliyuan0129
- **信息**: docs: 更新 README.md 以改进初始化说明和命令概述
- **文件**:
  - `README.md`

### 2026-03-18 15:15:09.000 · git
- **提交**: `a5c9a2f5099d`
- **作者**: ouliyuan0129
- **信息**: Merge branch 'features/feature-1.0.0-federated-docs'

### 2026-03-18 14:40:56.000 · git
- **提交**: `5376355e7caa`
- **作者**: ouliyuan0129
- **信息**: docs: 更新文档以反映新的知识库名称和结构
- **文件**:
  - `.ai/skills/agent-guide/SKILL.md`
  - `.ai/skills/document-indexing/SKILL.md`
  - `.ai/skills/knowledge-archive/SKILL.md`
  - `.ai/skills/knowledge-build/SKILL.md`
  - `.ai/skills/knowledge-upgrade/SKILL.md`
  - `.cursor/README.md`
  - `.cursor/skills/agent-guide/SKILL.md`
  - `.cursor/skills/document-indexing/SKILL.md`
  - `.cursor/skills/knowledge-archive/SKILL.md`
  - `.cursor/skills/knowledge-build/SKILL.md`
  - `.cursor/skills/knowledge-upgrade/SKILL.md`
  - `AGENTS.md`
  - `INDEX.md`
  - `README.md`
  - `applications/README.md`
  - `scripts/README.md`
  - `scripts/sdx-config.sh`
  - `scripts/sdx-init-bootstrap.sh`
  - `scripts/sdx-init.sh`

### 2026-03-18 11:32:42.000 · git
- **提交**: `6103e11916e6`
- **作者**: ouliyuan0129
- **信息**: Merge branch 'features/feature-1.0.0-federated-docs'

### 2026-03-18 11:31:33.000 · git
- **提交**: `d59114293f95`
- **作者**: ouliyuan0129
- **信息**: docs: 更新文档以反映 Bash 5+ 运行要求及初始化脚本改进
- **文件**:
  - `.trea/README.md`
  - `AGENTS.md`
  - `scripts/README.md`
  - `scripts/sdx-config.sh`
  - `scripts/sdx-init-bootstrap.sh`
  - `scripts/sdx-init.sh`

### 2026-03-17 15:24:15.000 · git
- **提交**: `de1e35af4700`
- **作者**: ouliyuan0129
- **信息**: docs: 新增全局知识文档库及应用知识库结构
- **文件**:
  - `.ai/skills/agent-guide/SKILL.md`
  - `.cursor/README.md`
  - `.cursor/skills/agent-guide/SKILL.md`
  - `AGENTS.md`
  - `README.md`
  - `applications/INDEX.md`
  - `applications/README.md`
  - `scripts/README.md`
  - `scripts/sdx-init.sh`
  - `system/CONTRIBUTING.md`
  - `system/DESIGN.md`
  - `system/INDEX.md`
  - `system/README.md`
  - `system/analysis/README.md`
  - `system/changelogs/CHANGELOG.md`
  - `system/knowledge/README.md`
  - `system/knowledge/business/BD-ORDER/BSD-FULFILLMENT/BC-ORDER-MGMT/_meta.yaml`
  - `system/knowledge/business/BD-ORDER/BSD-FULFILLMENT/BC-ORDER-MGMT/aggregates/AGG-ORDER.yaml`
  - `system/knowledge/business/BD-ORDER/BSD-FULFILLMENT/_meta.yaml`
  - `system/knowledge/business/BD-ORDER/_meta.yaml`
  - `system/knowledge/business/README.md`
  - `system/knowledge/constitution/GLOSSARY.md`
  - `system/knowledge/constitution/README.md`
  - `system/knowledge/constitution/adr/ADR-001-knowledge-repo-structure.md`
  - `system/knowledge/constitution/principles/architecture-principles.yaml`
  - `system/knowledge/constitution/standards/adr-template.md`
  - `system/knowledge/constitution/standards/naming-conventions.md`
  - `system/knowledge/data/DATA-ARCHITECTURE.md`
  - `system/knowledge/data/DS-ORDER-MYSQL-PRIMARY/README.md`
  - `system/knowledge/data/DS-ORDER-MYSQL-PRIMARY/_meta.yaml`
  - … 另有 24 个文件

### 2026-03-17 12:17:06.000 · git
- **提交**: `cec78dafcc6e`
- **作者**: ouliyuan0129
- **信息**: docs: 更新文档以反映新的知识库和技能结构
- **文件**:
  - `.ai/skills/agent-guide/SKILL.md`
  - `.ai/skills/knowledge-build/SKILL.md`
  - `.cursor/README.md`
  - `README.md`
  - `scripts/README.md`
  - `scripts/sdx-init.sh`

### 2026-03-16 18:41:38.000 · git
- **提交**: `c9aa6b5b0197`
- **作者**: ouliyuan0129
- **信息**: Merge branch 'features/feature-1.0.0-federated-docs'

### 2026-03-16 18:10:59.000 · git
- **提交**: `65e26bfcf5b9`
- **作者**: ouliyuan0129
- **信息**: docs: 更新文档以反映新的技能和模板结构
- **文件**:
  - `.ai/skills/sdx-analysis/SKILL.md`
  - `.ai/skills/sdx-design/SKILL.md`
  - `.ai/skills/sdx-prd/SKILL.md`
  - `.ai/skills/sdx-solution/SKILL.md`
  - `.ai/skills/sdx-test/SKILL.md`
  - `.cursor/README.md`
  - `.trea/README.md`
  - `CONTRIBUTING.md`
  - `INDEX.md`
  - `README.md`
  - `analysis/README.md`
  - `knowledge/knowledge-base.config.yaml`
  - `requirements/README.md`
  - `scripts/README.md`
  - `scripts/sdx-init-bootstrap.sh`
  - `scripts/sdx-init.sh`
  - `solutions/README.md`

### 2026-03-16 16:09:05.000 · git
- **提交**: `fb82b5fc15cf`
- **作者**: ouliyuan0129
- **信息**: docs: 更新初始化文档以反映新的知识库结构
- **文件**:
  - `README.md`
  - `scripts/README.md`
  - `scripts/sdd-init.sh`

### 2026-03-16 14:44:56.000 · git
- **提交**: `b59387e00be9`
- **作者**: ouliyuan0129
- **信息**: docs: 更新文档引用路径和内容一致性
- **文件**:
  - `.ai/rules/design/add-template.md`
  - `.ai/rules/design/architecture-template.md`
  - `.ai/rules/requirement/add-template.md`
  - `.ai/skills/knowledge-build/SKILL.md`
  - `.ai/skills/sdd-analysis/SKILL.md`
  - `.ai/skills/sdd-design/SKILL.md`
  - `.ai/skills/sdd-prd/SKILL.md`
  - `.ai/skills/sdd-solution/SKILL.md`
  - `.ai/skills/sdd-test/SKILL.md`
  - `.trea/README.md`
  - `CONTRIBUTING.md`
  - `INDEX.md`
  - `README.md`
  - `analysis/README.md`
  - `knowledge/knowledge-base.config.yaml`
  - `requirements/README.md`
  - `scripts/README.md`
  - `scripts/sdd-init-bootstrap.sh`
  - `scripts/sdd-init.sh`
  - `solutions/README.md`

### 2026-03-16 11:14:49.000 · git
- **提交**: `49ce22b7d3b0`
- **作者**: ouliyuan0129
- **信息**: docs: 更新 README.md 文档格式和内容
- **文件**:
  - `README.md`

### 2026-03-15 22:48:31.000 · git
- **提交**: `4a9e60348d61`
- **作者**: ouliyuan0129
- **信息**: fix: 从文档拷贝中排除scripts目录
- **文件**:
  - `README.md`
  - `scripts/README.md`
  - `scripts/sdd-init.sh`

### 2026-03-15 22:41:38.000 · git
- **提交**: `9eb168bb5d14`
- **作者**: ouliyuan0129
- **信息**: chore: 移除旧的全局知识文档库设计方案草稿文件
- **文件**:
  - `ideas/0 角色设定：你现在是一位资深的企业级架构师.md`
  - `ideas/1 第一部分：设计哲学与总体架构.md`
  - `ideas/2 第二部分：知识元模型设计.md`
  - `ideas/3 第三部分：文档库目录结构设计.md`
  - `ideas/4 第四部分：模型映射关系设计.md`
  - `ideas/5 第五部分：系统级与应用级协同机制.md`
  - `ideas/6 第六部分：元数据标签与规范体系.md`
  - `ideas/7 第七部分：面向未来的演进治理.md`
  - `ideas/8 第八部分：附录.md`
  - `ideas/全局软件系统知识文档库设计方案_精简版.md`

### 2026-03-15 22:38:48.000 · git
- **提交**: `ff38a1a53537`
- **作者**: ouliyuan0129
- **信息**: feat(scripts): 添加 sdd-init 引导脚本和初始化工具
- **文件**:
  - `README.md`
  - `scripts/README.md`
  - `scripts/sdd-init-bootstrap.sh`
  - `scripts/sdd-init.sh`

### 2026-03-15 21:38:12.000 · git
- **提交**: `ac11ee66a6ab`
- **作者**: ouliyuan0129
- **信息**: docs: 简化技能描述，移除冗余前缀
- **文件**:
  - `.cursor/skills/sdd-analysis/SKILL.md`
  - `.cursor/skills/sdd-design/SKILL.md`
  - `.cursor/skills/sdd-prd/SKILL.md`
  - `.cursor/skills/sdd-solution/SKILL.md`
  - `.cursor/skills/sdd-test/SKILL.md`

### 2026-03-15 21:30:29.000 · git
- **提交**: `c1875bda5e47`
- **作者**: ouliyuan0129
- **信息**: docs: 重构AI SDD文档结构并迁移至Cursor技能体系
- **文件**:
  - `.ai/CONVENTIONS.md`
  - `.ai/PROJECT_AGENTS_INIT.md`
  - `.ai/agents.yaml`
  - `.ai/prompts/analysis/README.md`
  - `.ai/prompts/requirements/ARCHITECTURE-DESIGN.md`
  - `.ai/prompts/requirements/PRD-TEMPLATE.md`
  - `.ai/prompts/requirements/PRODUCT-REQUIREMENT.md`
  - `.ai/prompts/requirements/README.md`
  - `.ai/prompts/requirements/REQUIREMENT-DEVELOPE.md`
  - `.ai/prompts/solutions/README.md`
  - `.ai/rules/analysis/requirement-template.md`
  - `.ai/rules/requirement/add-template.md`
  - `.ai/rules/requirement/prd-template.md`
  - `.ai/rules/requirement/requirement-analyse.md`
  - `.ai/rules/requirement/requirement-template.md`
  - `.ai/rules/requirement/tdd-template.md`
  - `.ai/rules/solution/solution-template.md`
  - `.cursor/README.md`
  - `.cursor/skills/knowledge-build/SKILL.md`
  - `.cursor/skills/sdd-analysis/SKILL.md`
  - `.cursor/skills/sdd-design/SKILL.md`
  - `.cursor/skills/sdd-prd/SKILL.md`
  - `.cursor/skills/sdd-solution/SKILL.md`
  - `.cursor/skills/sdd-test/SKILL.md`
  - `CONTRIBUTING.md`
  - `INDEX.md`
  - `analysis/README.md`
  - `knowledge/knowledge-base.config.yaml`
  - `requirements/README.md`
  - `solutions/README.md`

### 2026-03-15 20:37:39.000 · git
- **提交**: `d13d2adacd72`
- **作者**: ouliyuan0129
- **信息**: docs: 重构开发指南文档结构并添加规范索引
- **文件**:
  - `.ai/CONVENTIONS.md`

### 2026-03-15 20:32:02.000 · git
- **提交**: `5f14143932ef`
- **作者**: ouliyuan0129
- **信息**: docs: 更新知识库文档结构并新增设计文档
- **文件**:
  - `.ai/PROJECT_AGENTS_INIT.md`
  - `CONTRIBUTING.md`
  - `DESIGN.md`
  - `INDEX.md`
  - `README.md`
  - `ideas/0 角色设定：你现在是一位资深的企业级架构师.md`
  - `ideas/1 第一部分：设计哲学与总体架构.md`
  - `ideas/2 第二部分：知识元模型设计.md`
  - `ideas/3 第三部分：文档库目录结构设计.md`
  - `ideas/4 第四部分：模型映射关系设计.md`
  - `ideas/5 第五部分：系统级与应用级协同机制.md`
  - `ideas/6 第六部分：元数据标签与规范体系.md`
  - `ideas/7 第七部分：面向未来的演进治理.md`
  - `ideas/8 第八部分：附录.md`
  - `ideas/全局软件系统知识文档库设计方案_精简版.md`
  - `knowledge/README.md`

### 2026-03-15 20:01:36.000 · git
- **提交**: `108b4b14ab82`
- **作者**: ouliyuan0129
- **信息**: refactor(docs): 重构文档结构，迁移至知识库四视角模型
- **文件**:
  - `.ai/PROJECT_AGENTS_INIT.md`
  - `.ai/README.md`
  - `.ai/agents.yaml`
  - `.ai/context/project-context.yaml`
  - `.ai/prompts/analysis/README.md`
  - `.ai/prompts/analysis/REQUIREMENT-TEMPLATE.md`
  - `.ai/prompts/instructions/README.md`
  - `.ai/prompts/requirements/ADD-TEMPLATE.md`
  - `.ai/prompts/requirements/ARCHITECTURE-DESIGN.md`
  - `.ai/prompts/requirements/PRD-TEMPLATE.md`
  - `.ai/prompts/requirements/PRODUCT-REQUIREMENT.md`
  - `.ai/prompts/requirements/REQUIREMENT-DEVELOPE.md`
  - `.ai/prompts/solutions/README.md`
  - `.ai/prompts/solutions/SOLUTION-TEMPLATE.md`
  - `.ai/rules/requirement/business-logical.md`
  - `.ai/rules/requirement/business-process.md`
  - `.ai/rules/requirement/journey-analyse.md`
  - `.ai/rules/requirement/lean-value.md`
  - `.ai/rules/requirement/product-design.md`
  - `.ai/rules/requirement/prototype-design.md`
  - `.ai/workflows.yaml`
  - `CONTRIBUTING.md`
  - `DESIGN.md`
  - `INDEX.md`
  - `README.md`
  - `analysis/README.md`
  - `from/0 角色设定：你现在是一位资深的企业级架构师.md`
  - `from/1 第一部分：设计哲学与总体架构.md`
  - `from/2 第二部分：知识元模型设计.md`
  - `from/3 第三部分：文档库目录结构设计.md`
  - … 另有 66 个文件

### 2026-03-13 15:19:07.000 · git
- **提交**: `cea9a53082e9`
- **作者**: ouliyuan0129
- **信息**: Add comprehensive documentation for system architecture and guidelines
- **文件**:
  - `README.md`
  - `changelogs/CHANGELOG.md`
  - `instructions/CHANGELOG.md`
  - `instructions/GLOSSARY.md`
  - `instructions/INDEX.md`
  - `instructions/api/API-CONVENTIONS.md`
  - `instructions/api/API-OVERVIEW.md`
  - `instructions/architecture/DATA-ARCHITECTURE.md`
  - `instructions/architecture/DECISION-RECORDS/ADR-001-jwt-authentication.md`
  - `instructions/architecture/DECISION-RECORDS/ADR-003-saga-pattern.md`
  - `instructions/architecture/DECISION-RECORDS/README.md`
  - `instructions/architecture/DEPLOYMENT-ARCHITECTURE.md`
  - `instructions/architecture/INTEGRATION-MAP.md`
  - `instructions/architecture/SYSTEM-ARCHITECTURE.md`
  - `instructions/dependency/CHANGE-RISK-MAP.md`
  - `instructions/dependency/CHANGELOG.md`
  - `instructions/dependency/DEPENDENCY-MATRIX.md`
  - `instructions/dependency/IMPACT-ANALYSIS-GUIDE.md`
  - `instructions/domain/BOUNDED-CONTEXTS.md`
  - `instructions/domain/CONTEXT-MAPPING.md`
  - `instructions/domain/DOMAIN-EVENTS.md`
  - `instructions/domain/DOMAIN-MODEL.md`
  - `instructions/domain/DOMAIN-OVERVIEW.md`
  - `instructions/product/BUSINESS-RULES.md`
  - `instructions/product/CONSTRAINTS.md`
  - `instructions/product/FEATURE-MAP.md`
  - `instructions/product/PRODUCT-OVERVIEW.md`
  - `instructions/product/USER-GUIDE.md`
  - `instructions/product/USER-JOURNEY.md`
  - `instructions/product/USER-STORIES.md`
  - … 另有 7 个文件

### 2026-03-13 15:12:26.000 · git
- **提交**: `7c8a0f9ec4b3`
- **作者**: ouliyuan0129
- **信息**: Add AI SDD guidelines and update documentation structure
- **文件**:
  - `.ai/README.md`
  - `.ai/prompts/instructions/README.md`
  - `docs/README.md`

### 2026-03-13 14:45:08.000 · git
- **提交**: `790c28833c32`
- **作者**: ouliyuan0129
- **信息**: Update architecture design documentation and restructure specs directory
- **文件**:
  - `.ai/prompts/requirements/ARCHITECTURE-DESIGN.md`
  - `docs/README.md`
  - `docs/specs/example-service/service.yaml`

### 2026-03-13 14:28:29.000 · git
- **提交**: `f00f9bc8c3b7`
- **作者**: ouliyuan0129
- **信息**: Add AI Agent guidelines and restructure documentation
- **文件**:
  - `.ai/AGENTS.md`
  - `.ai/README.md`
  - `docs/README.md`

### 2026-03-13 14:10:03.000 · git
- **提交**: `b67082ef40e0`
- **作者**: ouliyuan0129
- **信息**: Refactor AI documentation structure and guidelines
- **文件**:
  - `.ai/CONVENTIONS.md`
  - `.ai/PROJECT_AGENTS_INIT.md`
  - `.ai/README.md`
  - `.ai/prompts/analysis/README.md`
  - `.ai/prompts/analysis/REQUIREMENT-TEMPLATE.md`
  - `.ai/prompts/instructions/README.md`
  - `.ai/prompts/requirements/ADD-TEMPLATE.md`
  - `.ai/prompts/requirements/ARCHITECTURE-DESIGN.md`
  - `.ai/prompts/requirements/PRD-TEMPLATE.md`
  - `.ai/prompts/requirements/PRODUCT-REQUIREMENT.md`
  - `.ai/prompts/requirements/README.md`
  - `.ai/prompts/requirements/REQUIREMENT-DEVELOPE.md`
  - `.ai/prompts/requirements/TDD-TEMPLATE.md`
  - `.ai/prompts/solutions/README.md`
  - `.ai/prompts/solutions/SOLUTION-TEMPLATE.md`
  - `.ai/rules/agents-template.md`
  - `.ai/rules/coding/git-guidelines.md`
  - `.ai/rules/coding/java-guidelines.md`
  - `.ai/rules/coding/maven-guidelines.md`
  - `.ai/rules/coding/project-structure.md`
  - `.ai/rules/design/add-template.md`
  - `.ai/rules/design/api-readme-template.md`
  - `.ai/rules/design/architecture-template.md`
  - `.ai/rules/design/design-guidelines.md`
  - `.ai/rules/design/design-template.md`
  - `.ai/rules/document/document-guidelines.md`
  - `.ai/rules/requirement/business-logical.md`
  - `.ai/rules/requirement/business-process.md`
  - `.ai/rules/requirement/journey-analyse.md`
  - `.ai/rules/requirement/lean-value.md`
  - … 另有 24 个文件

### 2026-03-13 13:11:05.000 · git
- **提交**: `bb93c5339f8d`
- **作者**: ouliyuan0129
- **信息**: Enhance AI SDD documentation and templates
- **文件**:
  - `.ai/CONVENTIONS.md`
  - `.ai/README.md`
  - `.ai/prompts/analysis/README.md`
  - `.ai/prompts/analysis/REQUIREMENT-TEMPLATE.md`
  - `.ai/prompts/instructions/README.md`
  - `.ai/prompts/requirements/ADD-TEMPLATE.md`
  - `.ai/prompts/requirements/ARCHITECTURE-DESIGN.md`
  - `.ai/prompts/requirements/PRD-TEMPLATE.md`
  - `.ai/prompts/requirements/PRODUCT-REQUIREMENT.md`
  - `.ai/prompts/requirements/README.md`
  - `.ai/prompts/requirements/REQUIREMENT-DEVELOPE.md`
  - `.ai/prompts/requirements/TDD-TEMPLATE.md`
  - `.ai/prompts/solutions/README.md`
  - `.ai/prompts/solutions/SOLUTION-TEMPLATE.md`
  - `AGENTS.md`
  - `docs/README.md`
  - `docs/instructions/CHANGELOG.md`
  - `docs/instructions/GLOSSARY.md`
  - `docs/instructions/INDEX.md`
  - `docs/instructions/api/API-CONVENTIONS.md`
  - `docs/instructions/architecture/DATA-ARCHITECTURE.md`
  - `docs/instructions/architecture/DECISION-RECORDS/ADR-001-jwt-authentication.md`
  - `docs/instructions/architecture/DECISION-RECORDS/ADR-003-saga-pattern.md`
  - `docs/instructions/architecture/DECISION-RECORDS/README.md`
  - `docs/instructions/architecture/DEPLOYMENT-ARCHITECTURE.md`
  - `docs/instructions/architecture/INTEGRATION-MAP.md`
  - `docs/instructions/architecture/SYSTEM-ARCHITECTURE.md`
  - `docs/instructions/dependency/CHANGE-RISK-MAP.md`
  - `docs/instructions/dependency/CHANGELOG.md`
  - `docs/instructions/dependency/DEPENDENCY-MATRIX.md`
  - … 另有 10 个文件

### 2026-03-12 20:48:03.000 · git
- **提交**: `3d796fa1fb97`
- **作者**: ouliyuan0129
- **信息**: 初始化 AI SDD 文档体系与 Agent 配置
- **文件**:
  - `.ai/agents.yaml`
  - `.ai/context/project-context.yaml`
  - `.ai/workflows.yaml`
  - `AGENTS.md`
  - `docs/README.md`
  - `docs/analysis/README.md`
  - `docs/analysis/REQUIREMENT-TEMPLATE.md`
  - `docs/changelogs/CHANGELOG.md`
  - `docs/instructions/api/API-OVERVIEW.md`
  - `docs/instructions/architecture/DATA-ARCHITECTURE.md`
  - `docs/instructions/architecture/DEPLOYMENT-ARCHITECTURE.md`
  - `docs/instructions/architecture/SYSTEM-ARCHITECTURE.md`
  - `docs/instructions/domain/BOUNDED-CONTEXTS.md`
  - `docs/instructions/domain/DOMAIN-MODEL.md`
  - `docs/instructions/domain/DOMAIN-OVERVIEW.md`
  - `docs/instructions/product/FEATURE-MAP.md`
  - `docs/instructions/product/PRODUCT-OVERVIEW.md`
  - `docs/instructions/product/USER-GUIDE.md`
  - `docs/instructions/test/TEST-COVERAGE.md`
  - `docs/instructions/test/TEST-STRATEGY.md`
  - `docs/requirements/ADD-TEMPLATE.md`
  - `docs/requirements/ARCHITECTURE-DESIGN.md`
  - `docs/requirements/PRD-TEMPLATE.md`
  - `docs/requirements/PRODUCT-REQUIREMENT.md`
  - `docs/requirements/README.md`
  - `docs/requirements/REQUIREMENT-DEVELOPE.md`
  - `docs/requirements/REQUIREMENT-EXAMPLE/MVP-Phase-1/.gitkeep`
  - `docs/requirements/REQUIREMENT-EXAMPLE/README.md`
  - `docs/requirements/TDD-TEMPLATE.md`
  - `docs/solutions/README.md`
  - … 另有 3 个文件

<!-- docs-change:baseline_time_ms=1781754915314 -->