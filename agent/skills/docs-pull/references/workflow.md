# workflow

## system（application → system）

1. 在 system 知识库根执行 docs-link 建联（创建 `application-{app_name}/` 槽位）
2. 在 system 知识库根执行 docs-pull：
   - `--app <app_name>` 同步单槽位
   - `--all` 同步全部 application link（失败汇总，整体 exit 1）

## company（system → company）

1. 在 company 知识库根执行 docs-link 建联（创建 `system-{sys_name}/` 槽位）
2. 在 company 知识库根执行 docs-pull：
   - `--sys-name <sys_name>` 同步单槽位
   - `--all` 同步全部 system link（失败汇总，整体 exit 1）

