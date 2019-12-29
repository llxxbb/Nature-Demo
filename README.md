# Nature 应用示例
[English](README_EN.md)|中文

如果你是第一次了解 Nature , 建议你从头到尾阅读这些 Demo。 每个章节都包含一些不同的 **Nature 要点**，以帮助你更好的了解 Nature 以及如何用 Nature 独有的方式来解决问题；同时阐述Nature 是如何简化技术性代码，使开发人员的聚焦于业务本身。下面为 Demo 相关的项目列表。

- [示例的入口](https://github.com/llxxbb/Nature-Demo)
- [服务于示例的一些通用封装](https://github.com/llxxbb/Nature-Demo-Common)
- [示例项目的转换器实现](https://github.com/llxxbb/Nature-Demo-Converter)
- [基于Restful的转换器实现](https://github.com/llxxbb/Nature-Demo-Converter-Restful)

如何启动 Nature 项目请参考：[项目准备](doc/ZH/prepare.md)

## 网上商城 DEMO

这个Demo涉及的场景比较多，如订单，支付，库房，配送以及多维度的销售统计等。

这并不是一个完整的用于实际生产的例子，我们只关注业务核心逻辑。

| 章节                                               | 内容摘要                                   | Nature 要点                                                  |
| -------------------------------------------------- | ------------------------------------------ | ------------------------------------------------------------ |
| [生成订单](doc/ZH/emall/emall-1-order-generate.md) | 用户向 Nature 提交一个订单                 | `Meta`, master `meta`, target-state, `Converter` ，提交`Instance`到Nature。 |
| [支付订单](doc/ZH/emall/emall-2-pay-the-bill.md)   | 用户可以对一个金额比较大的订单进行多次支付 | 选择上游，上下文（sys.target）, 并发冲突控制                 |
| [出库](doc/ZH/emall/emall-3-stock-out.md)          | 库房的系统比较老旧，处理订单比较慢         | 提交`state-instance` ，回调，与已有系统的对接。              |
| [配送](doc/ZH/emall/emall-4-delivery.md)           | 和第三方协作                               | 参数化输入                                                   |
| [签收](doc/ZH/emall/emall-5-signed.md)             | 用户接收了订单中的货物                     | 延迟转换                                                     |

[Q&A](doc/ZH/q&a.md)

## 查分

因为Nature 的所有特性不能在网上商城上都能体现出来，"查分"可以弥补一下这些批处理特性介绍。

下列内容还没有完成

| chapter                                 | digest                                                       | key points                                |
| --------------------------------------- | ------------------------------------------------------------ | ----------------------------------------- |
| [sale statistics](doc/ZH/emall/emall-6-statistics.md) | from goods view, make statistics freely, extensible, no coding. | context, embedded counter, serial process |
| user consumption data                   | make data which can be got by user id, such as order list    | parallel process                          |

