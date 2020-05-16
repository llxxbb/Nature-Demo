# 对订单进行支付

现在到了支付环节了，我们虚构了一些复杂情景，我们假设用户的每张银行卡里的钱都不足以全额支付这笔订单，但是三张卡加起来是可以的。

## 记录每笔支付数据

我们需要支付系统告诉 Nature 用户支付的每一笔费用，为此我们需要定义一个支付单 `Meta`:

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'finance/payment', 'order payment', 1, '', '', '');
```

其输入的数据体现在 instance 数据表如下所示：

| ins_key                                           | content | states | state_version | from_key |
| ------------------------------------------------- | ------- | ------ | ------------- | -------- |
| B:sale/order:1\|3827f37003127855b32ea022daa04cd\| |         |        |               |          |

 ## 为订单建立账户

为了能够使一个订单能够支持多次支付，我们需要为每一笔订单建立一个独立的账户。其`Meta`定义如下：

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'finance/orderAccount', 'order account', 1, 'unpaid|partial|paid', '', '{"master":"B:sale/order:1"}');
```

我们可以看到这也是一个状态数据，里面有一组互斥的状态定义。另外它的 `master`也指到了 `order`上。有关这两个点已经在[上一节](emall-1-order-generate.md)中解释过了，这里不再说明。

## 将支付数据关联到订单账上





## 定义 `Relation`

```mysql
-- order --> orderAccount
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/order:1', 'B:finance/orderAccount:1', '{"executor":{"protocol":"localRust","url":"nature_demo_executor:order_receivable"},"target":{"states":{"add":["unpaid"]}}}');

-- payment --> orderAccount
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:finance/payment:1', 'B:finance/orderAccount:1', '{"executor":{"protocol":"localRust","url":"nature_demo_executor:pay_count"}}');

-- orderAccount --> orderState
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:finance/orderAccount:1', 'B:sale/orderState:1', '{"selector":{"state_all":["paid"]},"target":{"states":{"add":["paid"]}}}');
```

我们需要几个Nature 外的`Converter` 来完成我们的任务：

**order --> orderAccount** ：用于为每个订单创建一个订单账并记录订单地应收信息。

**payment --> orderAccount** ：用于记录订单的每一笔支付，并根据支付情况设置支付状态。

**orderAccount --> orderState** ：因为没有指定`executor`，所以是一个自动的转换器，

### `settings`中的属性说明

| 属性                 | 描述                                                         |
| -------------------- | ------------------------------------------------------------ |
| executor             | 用于告诉 Nature 使用用户自定义的转换器                       |
| protocol             | 告诉 Nature 如何与 `executor`通讯。`LocalRust` 告诉 Nature `executor` 是本地的一个 lib 包。 |
| url                  | 告诉Nature 哪里可以找到这个 `executor`。                     |
| source_state_include | 是一个过滤器，在本示例里，只有上游的状态包含“paid” `Converter` 才可以进行转换 |

## 定义业务对象

我们需要在`Nature-Demo-Common`项目中定义一些业务对象，它们会被接下来的 `Nature-Demo` 和 `Nature-Demo-Converter`项目使用。

```rust
#[derive(Serialize, Deserialize, Debug, Default, Clone, PartialEq, Eq)]
pub struct Payment {
    pub order: u128,
    pub from_account: String,
    pub paid: u32,
    pub pay_time: i64,
}

#[derive(Serialize, Deserialize, Debug, Default, Clone, PartialEq, Eq)]
pub struct OrderAccount {
    pub receivable: u32,
    /// 不能超过应收的值， 过多的钱需要放到 diff 中去。
    /// 这样每一笔的超出都可以被跟踪
    pub total_paid: u32,
    pub last_paid: u32,
    /// 变账的原因
    pub reason: OrderAccountReason,
    /// 正: 超付, 负 : 欠款
    pub diff: i32,
}

#[derive(Serialize, Deserialize, Debug, Clone, PartialEq, Eq)]
pub enum OrderAccountReason {
    NewOrder,
    Pay,
    CancelOrder,
}

impl Default for OrderAccountReason {
    fn default() -> Self {
        OrderAccountReason::Pay
    }
}
```

## 实现执行器 "**order --> orderAccount**"

这个实现我们把它放在 `Nature-Demo-Converter` 项目里如下:

```rust
#[no_mangle]
pub extern fn order_receivable(para: &ConverterParameter) -> ConverterReturned {
    let order: Order = serde_json::from_str(&para.from.content).unwrap();
    let oa = OrderAccount {
        receivable: order.price,
        total_paid: 0,
        last_paid: 0,
        reason: OrderAccountReason::NewOrder,
        diff: 0 - order.price as i32,
    };
    let mut instance = Instance::default();
    instance.content = serde_json::to_string(&oa).unwrap();
    ConverterReturned::Instances(vec![instance])
}
```

这个实现没有什么秘密，但是你需要知道如何实现一个本地执行器。

### Nature 要点

在执行器里可以通过下面的语句来获得业务对象。

```rust
let biz_obj = serde_json::from_str(&para.from.content).unwrap();
```

执行器需要将返回的业务对象赋值给 `Instance.content` 属性。

对于像 `orderAccount` 这样的`state-meta`你只能返回一个 `Instance`。

## 实现执行器 **payment --> orderAccount**"

```rust
#[no_mangle]
pub extern fn pay_count(para: &ConverterParameter) -> ConverterReturned {
    let payment: Payment = serde_json::from_str(&para.from.content).unwrap();
    if para.last_state.is_none(){
        return ConverterReturned::EnvError;
    }
    let old = para.last_state.as_ref().unwrap();
    let mut oa: OrderAccount = serde_json::from_str(&old.content).unwrap();
    let mut state = String::new();
    if payment.paid > 0 {
        state = "partial".to_string();
    }
    oa.total_paid += payment.paid;
    oa.diff = oa.total_paid as i32 - oa.receivable as i32;
    if oa.diff > 0 {
        oa.total_paid = oa.receivable;
    }
    if oa.diff == 0 {
        state = "paid".to_string();
    }
    oa.last_paid = payment.paid;
    oa.reason = OrderAccountReason::Pay;
    let mut instance = Instance::default();
    instance.content = serde_json::to_string(&oa).unwrap();
    instance.states.insert(state);
    ConverterReturned::Instances(vec![instance])
}
```

### Nature 要点

如果 `orderAccount` 还没有被初始化，表示应收还没有写入，我们需要等待其写入。这时需要返回`ConverterReturned::EnvError`，这样Nature 在将来的某一个时刻可以重试这次的执行过程。

你可以通过`&para.from.content`来得到`Payment`。

如果目标是一个`state-meta`，Nature 会将其当前最新的一个`Instance`传递给执行器。如下面的代码可以得到最新的`orderAccount`，

```rust
    let old = para.last_state.as_ref().unwrap();
    let mut oa: OrderAccount = serde_json::from_str(&old.content).unwrap();
```

但是Nature 如何知道要加载的`orderAccount`的id呢？答案在下一下节。

因为 `orderAccount` 是一个 `state-meta`，所以当你返回一个新的`orderAccount` `Instance`时，Nature 将自动增加它的`state_version` 值。你**不必担心冲突问题**，Nature 会检测到这种情况并重新调用执行器，以修正结果。如示例中演示的那样。

## 提交支付数据到 Nature

You will see the whole codes in project `Nature-Demo`,  key codes list here only:

```rust
pub fn user_pay(order_id: u128) {
    let _first = pay(order_id, 100, "a", Local::now().timestamp_millis());
    let time = Local::now().timestamp_millis();
    let _second = pay(order_id, 200, "b", time);
    let _third = pay(order_id, 700, "c", Local::now().timestamp_millis());
    let _second_repeat = pay(order_id, 200, "b", time);
}

fn pay(id: u128, num: u32, account: &str, time: i64) -> u128 {
    let payment = Payment {
        order: id,
        from_account: account.to_string(),
        paid: num,
        pay_time: time,
    };
    let mut sys_context: HashMap<String, String> = HashMap::new();
    sys_context.insert("target.id", id.to_string());
    match send_instance_with_context("finance/payment", &payment, &sys_context) {
        Ok(id) => id,
        _ => 0
    }
}
```

### Nature 要点

还记得上一小节的问题吗？秘密就在于 **"target.id"** 系统上下文上。调用者是知道要为那个订单付款的，而`orderAccount`和`order`共享同一个ID，所以上一小节中的`orderAccount`的ID值就来源于**target.id** 的值。可见相同ID如果应用的恰当，业务逻辑上会有简化。在这个示例中，我们就不需要自己写代码查`orderAccount`数据了，Nature 可以自动为我们查出来。

## Nature 幕后为你做了什么

在这个示例里我们还是没有为`orderState`写一行代码，但是我们可以看到数据库里有两条数据，也就是说Nature 自动为我们生成了一条新的状态数据。版本1 的状态是“new”， 版本2的状态是“paid”，**这就是Nature的原则，永远不会修改和删除数据**。

## 与传统开发方式的区别

我们大约写了100行的代码完成了这个复杂的业务逻辑。包含并发，状态冲突控制，重试策略等，这在传统开发模式下是不太可能做到的。

你可以看到，我们在增加 `orderAccount` 是，没有变更上一节中已有的逻辑。在传统开发方式下一般是自上而下控制，很可能的情形是，在生成`order`的时候同时生成`orderState`和`orderAccount`，并用事务来保证一致性。这是一种非常复杂和低效的方式，而Nature 利用`自由选择`上游的方式实现了插拔式的工件，使得既有系统非常容易扩展和维护。





**Nature 要点**：Nature 对互斥支持的很好，你无需先删除一个状态再增加一个状态，如果你输入一个新的状态，Nature 会自动替换掉与之互斥的其它状态。

