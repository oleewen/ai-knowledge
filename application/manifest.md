---
type: Manifest
title: application 目录清单
---

```yaml
# 机器可读目录清单（与 docs-meta.md 互补）
schema_version: "1.1"
template_id: app-APPNAME
description: 联邦单元目录布局与中央库 application/ 下对应物对照

mirrors_system_paths:
  - application/changelogs/README.md → changelogs/README.md
  - application/knowledge/** → knowledge/**
  - application/requirements/README.md → requirements/README.md
  - application/docs-meta.md → docs-meta.md（目标工程内文件名；安装时内容替换见知识库安装）

central_library:
  system_root: ../../application/
  repository_root: ../../
```
