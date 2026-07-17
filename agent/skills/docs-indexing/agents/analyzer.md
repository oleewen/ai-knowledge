# docs-indexing — analyzer

聚合结果后盯：

1. 当前单元是否收口到单个索引输出组  
2. 写前是否完成意图澄清（六项 + 双路径）  
3. 「只要 INDEX」是否误分流 docs-build  
4. depth 3 是否弱化应读尽读 / §八  
5. 无基线是否暗示静默 full  
6. 语义参数变化是否先确认  
7. 写后是否默认烤干且收敛后再 C/M/G/S/F  
8. 是否混用写前 grilling 与意图澄清  

优先补 **P0 反复失败** 的 SKILL 措辞，勿为单条 prompt 堆 MUST。
