# Nature 应用示例
[English](README_EN.md)|中文

如果你是第一次了解 Nature , 建议你从头到尾阅读这些 Demo。 每个章节都包含一些不同的 **Nature 要点**，以说明如何用 Nature 独有的方式来解决问题。如何启动 Nature 项目请参考：[项目准备](doc/ZH/prepare.md)

## 网上商城 DEMO

这个Demo涉及的场景比较多，如订单，支付，库房，配送以及签收等。这不是一个具有生产力的示例，但却简练的勾勒出系统的骨架以及她所具有的强大的支撑及扩展能力。

| 章节                                               | 内容摘要                                                     | Nature 要点                                                  |
| -------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| [生成订单](doc/ZH/emall/emall-1-order-generate.md) | 大致讲解一下Nature的使用方式，介绍Nature的一个重要的能力：有些业务只需要配置一下不需要代码就能自动完成！ | `Meta`, master `meta`, target-state, `Converter` ，提交`Instance`到Nature，自动执行器 |
| [支付订单](doc/ZH/emall/emall-2-pay-the-bill.md)   | 我们只写了很少的业务代码，就实现了复杂的业务逻辑，Nature 会在幕后提供很多保障，如数据一致性，并发冲突等问题。 | 选择上游，系统上下文（target.id）, 并发冲突控制              |
| [出库](doc/ZH/emall/emall-3-stock-out.md)          | 这里涉及到如何离线处理。                                     | 提交`state-instance` ，回调，与已有系统的对接。              |
| [配送](doc/ZH/emall/emall-4-delivery.md)           | 这里展示了和外系统协作的方法                                 | 参数化输入                                                   |
| [签收](doc/ZH/emall/emall-5-signed.md)             | 这里描述了Nature 对时间敏感性任务的处理                      | 延迟转换                                                     |

## 统计DEMO

可以把 Nature 看做一个流式计算框架，但你不需要为技术框架和专业技术团队而头痛，这个也许不是性能最好的，但我想是生产力非常高的一个。

下面给出一个成绩统计的例子：

| 章节                                                         | 内容摘要                           | Nature 要点                                                |
| ------------------------------------------------------------ | ---------------------------------- | ---------------------------------------------------------- |
| [全员成绩单->个人成绩](doc/ZH/score/score_1_to_persion.md)   | 将多个成绩单按人进行拆分           | builtin-executor: dimensionSplit，后置过滤器               |
| [求出每个人各科的总分](doc/ZH/score/score_2_person_total_score.md) | 利用状态数据完成个人所有科目的统计 | `para`作为选择条件，use_upstream_id，builtin-executor: sum |
| [生成定时统计任务](doc/ZH/score/score_3_make_time_range.md)      | 如何玩转流逝计算                   | cache_saved, builtin-executor: timer                       |
| [求出班级每科的Top 3](doc/ZH/score/score_3_make_time_range.md)   |                                    |                                                            |
| 求出班级总分的top                                            |                                    |                                                            |

## 审批流程

必须两人同意才通过

任何一人同意就可通过

多级审批