---
type: Manifest
title: application 目录清单
---

```yaml
# 机器可读目录清单
schema_version: "1.1"
template_id: app-APPNAME
description: 联邦单元目录布局与元库 application/ 对照

mirrors_system_paths:
 - application/knowledge/** → knowledge/**
 - application/requirements/README.md → requirements/README.md

central_library:
 system_root: ../../application/
 repository_root: ../../
```
