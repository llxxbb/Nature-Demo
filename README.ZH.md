# Nature 应用示例
[English](README.md)|中文

为了说明 Nature 的功能特性，这里举几个较为实际的例子来加以说明。

- 网上商城：这是个比较大的Demo，涉及到订单，支付，库房，配送以及多维度的销售统计等。请不要担心它的复杂性，我们先从简单的入手，一步一步达成我们的最终目标。虽然如此我想总得代码行数保守估计会比传统的开发方式至少要少一半以上。而且还非常高效、稳定，并且健壮，更为重要的是，它很容易扩展。
- 查分：因为Nature 的所有特性不能在网上商城上都能体现出来，"查分"可以弥补一下这些确实的特性介绍。

## 如何阅读

如果你是第一次了解 Nature , 建议你从头到尾阅读这些 Demo。 每个章节都包含一些不同的 **Nature 要点**，以帮助你更好的了解 Nature 以及如何用 Nature 独有的方式 来解决问题。

## 示例项目

Nature 的示例项目都提供了完整的实现。

- [示例的入口](https://github.com/llxxbb/Nature-Demo)
- [服务于示例的一些通用封装](https://github.com/llxxbb/Nature-Demo-Common)
- [示例项目的转换器实现](https://github.com/llxxbb/Nature-Demo-Converter)
- [基于Restful的转换器实现](https://github.com/llxxbb/Nature-Demo-Converter-Restful)

## 章节列表

| chapter                                    | digest                                                    | key points                                                   |
| ------------------------------------------ | --------------------------------------------------------- | ------------------------------------------------------------ |
| [项目准备](doc_zh/prepare.md)              | 为运行示例项目做准备                                      | 如何启动 Nature                                              |
| [生成订单](doc_zh/order-generate.md)       | user commit an order into to Nature                       | `Meta`, master `meta`, define target-state, `Converter`  and how to commit business object to Nature |
| [pay for the bill](doc_zh/pay-the-bill.md) | user can pay many times for the big bill.                 | upstream select, state conflict control                      |
| [stock-out](doc_zh/stock-out.md)           | the warehouse system is slow to process the order's goods | input state instance, callback                               |
| [delivery](doc_zh/delivery.md)             | collaborate with the third-party                          | parameterization input                                       |
| [signed](doc_zh/signed.md)                 | user received the goods                                   | delay converter                                              |


The following unfinished yet.

| chapter                                 | digest                                                       | key points                                |
| --------------------------------------- | ------------------------------------------------------------ | ----------------------------------------- |
| [sale statistics](doc_zh/statistics.md) | from goods view, make statistics freely, extensible, no coding. | context, embedded counter, serial process |
| user consumption data                   | make data which can be got by user id, such as order list    | parallel process                          |

[Q&A](doc_zh/q&a.md)



