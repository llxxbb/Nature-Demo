# 配送

现在我们需要一些快递公司来帮助我们将包裹送给消费者，Nature 将记录这些派件单信息并在以后的某个时间进行查询，如每个月的结算。

我们想按照快递公司名称和派件单ID来与对方进行结算，假设我们不想在Nature 外单独建立一个数据库来存储这些信息，让我们看一下Nature 是怎么面对这个问题的。

## 定义`meta`

```sqlite
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'third/waybill', 'waybill', 1, '', '', '{}');
```

## 定义`Converter`

```sqlite
-- orderState:outbound --> waybill
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/orderState:1', 'B:third/waybill:1', '{"selector":{"source_state_include":["outbound"]}, "executor":[{"protocol":"localRust","url":"nature_demo_executor.dll:go_express"}]}');

-- waybill --> orderState:dispatching
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:third/waybill:1', 'B:sale/orderState:1', '{"target_states":{"add":["dispatching"]}}');
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
    ins.context.insert("sys.target".to_owned(), para.from.id.to_string());
    // ... 将包裹信息发送给快递公司，并等待其返回派件单ID,
    // 模拟一个派件单ID，快递公司模拟为：ems
    ins.para = "/ems/".to_owned() + &generate_id(&para.master.clone().unwrap().data).unwrap().to_string();
    ConverterReturned::Instances(vec![ins])
}
```

### Nature 要点

Nature 使用`Instance.para`保存**"company id + waybill id"**。这样你就可以用 `para`来获取`Instance`了。

再一次我们使用了`sys.target context`，这可能让人有一些奇怪，因为 `waybill`根本不需要它。但是下一个`Converter` **waybill --> orderState:dispatching**  的 `orderState` 的`Instance`ID如何确定呢？因为这是个`auto converter`，`waybill`本身是没有这个信息的，所以这个信息只能放到`sys.target`里。