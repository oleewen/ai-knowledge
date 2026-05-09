# 共现候选词算法

种子词命中章节 → 提词 → 频次 → 去停用词 / 种子 → Top N。共现多则相关性强。

## 步骤

1. 扫 `--scan-dir` 下 `.md`（排除目标所在**直接子目录**）  
2. 按 `#` 标题切段，段内含任一种子则纳入  
3. 中英文词抽取（规则见下）  
4. `Counter` 汇总  
5. 过滤停用词与种子，按频降序取前 TOP_N  

## 抽取规则

- 中文：`[\u4e00-\u9fff]{2,8}`  
- 英文：`[A-Z][a-zA-Z]{2,}|[A-Z]{2,}`  

## 停用词表（维护在脚本 `collect_candidates` 内可扩展）

### 中文虚词 / 连接词

的、了、在、是、和、与、或、及、等、对、为、中、上、下、内、外、前、后、该、其、此、
通过、进行、实现、支持、包含、关联、定义、描述、查询、获取、更新、删除、创建、配置、处理、生成

### 过于宽泛的架构/业务词

管理、系统、服务、数据、业务、应用、技术、架构、设计、方案、策略、规则、模块、功能、接口、流程、
信息、内容、说明、概述、概览、文档、章节、小节、业务架构、应用架构、技术架构、数据架构、产品架构

### Java / 编程通用词

String、List、Map、Set、Object、Class、Type、ID、Id、Key、Value、Code、Name、Flag、Status、
Basic、Unit、Condition、Element、Base、Item、Request、Response、Result、Error、Exception、
Service、Manager、Handler、Factory、Builder、Controller、Repository、Entity、Model、DTO、VO、
NULL、TRUE、FALSE、GET、POST、PUT、DELETE

### 通用编程描述词（中文）

入参、出参、返回值、参数、字段、属性、方法、函数、唯一标识、编码、枚举、聚合根、值类型、对象类型、
单位、类型、名称、标识、状态、标志、编号

### 噪音 / 占位符

README、TODO、TBD、XX、YY、ZZ、Xxx

## 调优

- 种子尽量具体  
- 差则加大 `--top-n` 或换种子  
- 缩小 `--scan-dir` 降噪  
