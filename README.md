# Nature 应用示例
[English](README_EN.md)|中文

如果你是第一次了解 Nature , 建议你从头到尾阅读这些 Demo。 每个章节都包含一些不同的 **Nature 要点**，以帮助你更好的了解 Nature 以及如何用 Nature 独有的方式来解决问题；同时阐述Nature 是如何简化技术性代码，使开发人员的聚焦于业务本身。如何启动 Nature 项目请参考：[项目准备](doc/ZH/prepare.md)

## 网上商城 DEMO

这个Demo涉及的场景比较多，如订单，支付，库房，配送以及多维度的销售统计等。

这并不是一个完整的用于实际生产的例子，我们只关注业务核心逻辑。

| 章节                                               | 内容摘要                                   | Nature 要点                                                  |
| -------------------------------------------------- | ------------------------------------------ | ------------------------------------------------------------ |
| [生成订单](doc/ZH/emall/emall-1-order-generate.md) | 用户向 Nature 提交一个订单                 | `Meta`, master `meta`, target-state, `Converter` ，提交`Instance`到Nature。 |
| [支付订单](doc/ZH/emall/emall-2-pay-the-bill.md)   | 用户可以对一个金额比较大的订单进行多次支付 | 选择上游，系统上下文（target.id）, 并发冲突控制                 |
| [出库](doc/ZH/emall/emall-3-stock-out.md)          | 库房的系统比较老旧，处理订单比较慢         | 提交`state-instance` ，回调，与已有系统的对接。              |
| [配送](doc/ZH/emall/emall-4-delivery.md)           | 和第三方协作                               | 参数化输入                                                   |
| [签收](doc/ZH/emall/emall-5-signed.md)             | 用户接收了订单中的货物                     | 延迟转换                                                     |

## 统计DEMO

可以把Nature 看做一个简单的流式计算框架。

下面给出一个班级成绩统计的例子，具体需求是这样的。

- 求出每个人各科的总分
- 求出班级每科的Top
- 求出班级总分的top

| chapter                                                      | digest                             | key points         |
| ------------------------------------------------------------ | ---------------------------------- | ------------------ |
| [求出每个人各科的总分](doc/ZH/score/score_1_persion_total.md) | 利用状态数据完成个人所有科目的统计 | 参数化输入状态数据 |
| 求出班级每科的Top                                            |                                    |                    |
| 求出班级总分的top                                            |                                    |                    |

