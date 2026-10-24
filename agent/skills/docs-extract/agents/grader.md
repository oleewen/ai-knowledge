# docs-extract Grader

按 [evals.json](../evals/evals.json) 的用例断言评分；[元数据模板](../evals/eval-metadata-template.json) 用于保存结果，不代替实际证据。

## 执行与判定

1. 读取用例的 `category`、`prompt` 与 `files`。`files` 相对技能目录定位；把 `tests/fixtures/` 的内容复制为临时工作目录根，保留其内部布局，使 `sources/`、`system/` 直接位于临时根下。任何写入只发生在临时副本。
2. 只把请求、技能入口和输入文件交给执行者，不提供 `expected_output`、断言或预期答案。保留回复、工具轨迹及前后文件。
3. 只检查本次已到达阶段。明确的只读预览不要求写前确认；正式写入未获授权时评价澄清与未写入。已有确认的续轮不能因重问确认而算完成。
4. 逐条记录 `assertion_id`、通过与否、可定位证据。`must_include` 检查要求出现并被证据支持的行为；`must_not_conflict` 检查禁止行为未发生。dry-run/无命中需查文件前后内容，不能仅凭“未写入”一句话；口头承诺不算失败恢复测试。
5. 任一适用断言失败则整例 fail；无失败但有未执行或缺证据断言则 not_run；全部适用断言有证据通过才为 pass。未到达且不适用的阶段说明原因，不假造执行。

受众 A/B/C/E 全过允许静默；评价内容和轨迹，不要求回复包含维度字母。路由负例须选正确下游，不能只提到技能名称就算通过。

## 结果格式

```json
{
  "text": "本例 dry-run 保持目标不变；证据见执行记录。",
  "status": "pass",
  "evidence": [
    {
      "assertion_id": "dry-run-no-write",
      "status": "pass",
      "observed": "前后目标文件内容一致"
    }
  ],
  "unverified": []
}
```

无完整输入的路由/澄清样本不等同于落盘行为测试。评分依据是观察结果，不是将 `expected_output` 复制为报告。
