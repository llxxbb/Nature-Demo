# 配送

接下来我们需要一些快递公司来帮助我们将包裹送给消费者，Nature 将记录这些派件单信息并在以后的某个时间进行查询，如每个月的结算。

我们想按照快递公司名称和派件单ID来与对方进行结算，假设我们不想在Nature 外单独建立一个数据库来存储这些信息，让我们看一下Nature 是怎么面对这个问题的。

## 记录`派送单`信息

首先我们来定义一下`派送单`信息，用于日后的结算：

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'third/waybill', 'waybill', 1, '', '', '');
```

因为快递公司是直接来人取件，所以快递公司名称和派件单ID等信息需要在出库时记录到上一节中提到的库房系统中。我们可以设计一个`订单出库状态 -> 派件单`的`关系`来从库房中将这些信息提取出来并形成派件单。定义如下：

```mysql
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/orderState:1', 'B:third/waybill:1', '{"selector":{"state_all":["outbound"]}, "executor":{"protocol":"localRust","url":"nature_demo_executor:go_express"}}');
```

有关选择器的使用在[支付订单](emall-3-pay-the-bill.md)中已经介绍过，请参考 [meta.md](https://github.com/llxxbb/Nature/blob/master/doc/ZH/help/meta.md)。

`执行器`的具体实现方式请参考对应的源代码，这里有两点需要说明一下：

- **系统上下文**：我们需要设置 `target.id` 为派件单对应的订单ID以简化订单下一环节`派件单 -> 订单状态:配送`的处理，我们在[支付订单](emall-3-pay-the-bill.md)中也应用了这一技巧。
- **设置`Instance.para`属性**：用于记录派件单相关信息，其形式为：“/[快递公司ID]/[派件单ID]”。**参数之间请务必用“/”进行分隔**（你可以通过改变 Nature 的启动参数来将它变成其它字符）。

让我们看一下运行结果，运行：

- nature.exe

- nature_demo_executor_restful.exe

- nature-demo::emall::emall_test()

结束后我们会发现有下面的数据产生：

| ins_key                                                | system_context                                  | from_key                                                  |
| ------------------------------------------------------ | ----------------------------------------------- | --------------------------------------------------------- |
| B:third/waybill:1\|\|/ems/3827f37003127855b32ea022daa04cd | {"target.id":"3827f37003127855b32ea022daa04cd"} | B:sale/orderState:1\|3827f37003127855b32ea022daa04cd\|\|4 |








```mysql
-- waybill --> orderState:dispatching
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:third/waybill:1', 'B:sale/orderState:1', '{"target":{"states":{"add":["dispatching"]}}}');
```

## 实现`executor`

```rust
#[no_mangle]
#[allow(unused_attributes)]
#[allow(improper_ctypes)]
pub extern fn go_express(para: &ConverterParameter) -> ConverterReturned {
    // "any one" 会被Nature修正为正确的目标`Meta，这里只是说明 `executor`无法重定向目标`Meta`,否则容易引发流程上的混乱和不可控。
    let mut ins = Instance::new("any one").unwrap();
    ins.id = para.from.id;
    // 服务于下一个转换器，用于找出 orderState 对应的 `Instance`
    ins.sys_context.insert("target.id".to_owned(), para.from.id.to_string());
    // ... 将包裹信息发送给快递公司，并等待其返回派件单ID,
    // 模拟一个派件单ID，快递公司模拟为：ems
    ins.para = "/ems/".to_owned() + &generate_id(&para.master.clone().unwrap().data).unwrap().to_string();
    ConverterReturned::Instances(vec![ins])
}
```





Nature 提供的检索能力是有限度的，毕竟 Nature 的主要目的不是用来检索数据而是用来处理数据。