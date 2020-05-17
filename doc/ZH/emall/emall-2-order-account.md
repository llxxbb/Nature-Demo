# 建立支持多次支付的订单账

 ## 为订单建立账户

为了能够使一个订单能够支持多次支付，我们需要为每一笔订单建立一个独立的账户，来记录应收和实收情况。其`Meta`定义如下：

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'finance/orderAccount', 'order account', 1, 'unpaid|partial|paid', '', '{"master":"B:sale/order:1"}');
```

我们可以看到这也是一个状态数据，里面有一组互斥的状态定义。另外它的 `master`也指到了 `order`上。有关这两个点已经在[上一节](emall-1-order-generate.md)中解释过了，这里不再说明。

## 将应收写入订单账

订单信息里含有应收信息，所以我们需要建立订单和订单账之间的关系。

```mysql
-- order --> orderAccount
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/order:1', 'B:finance/orderAccount:1', '{"executor":{"protocol":"localRust","url":"nature_demo_executor:order_receivable"},"target":{"states":{"add":["unpaid"]}}}');
```

这里 Nature 不能再为我们自动创建`orderAccount`实例了，因为 Nature 是不知道如何写它的 `content`。这就需要我们借助外部来实现了，为此我们引入了新的 配置项：`executor`。`executor`的实现方式有多种，这里使用的是`localRust`方式，实际上就是c静态库。`url`则说明了是哪个静态库的哪个方法。方法的入参、出参请参考 [reladtion.md](https://github.com/llxxbb/Nature/blob/master/doc/ZH/help/relation.md)，方法的具体实现请自行查看示例代码。

这个方法的主要作用就是从订单（入参）中提取应收数据，并将应收写入到出参实例的 `content`中。

- **Nature 要点**：Nature 以非编程方式主导了业务流程，并对编程的范围进行了强制规范和约束。
- **Nature 要点**：Nature 将编程任务进行了最小力度的分解，使实施者能够快速聚焦和实施。

## 运行 demo

请将本例对应的 nature_demo_executor.dll 放入到包含 nature.exe的目录中，运行：

- 启动 nature.exe
- 运行 nature-demo::emall::emall_test()

运行完成后我们就可以在 instance 数据表里看到下面新生成的订单账数据：

| ins_key                                                     | content                                                      | states     | state_version | from_key                                             |
| ----------------------------------------------------------- | ------------------------------------------------------------ | ---------- | ------------- | ---------------------------------------------------- |
| B:finance/orderAccount:1\|3827f37003127855b32ea022daa04cd\| | {"receivable":1000,"total_paid":0,"last_paid":0,"reason":"NewOrder","diff":-1000} | ["unpaid"] | 1             | B:sale/order:1\|3827f37003127855b32ea022daa04cd\|\|0 |

