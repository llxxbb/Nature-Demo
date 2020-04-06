# 生成订单

我们假设用户已经选择了商品，并以此生成订单。

## 定义 `Meta`

首先我们需要定义两个 `Meta`，请执行下面的sql脚本

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/order', 'order', 1, '', '', '{}');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/orderState', 'order state', 1, 'new|paid|package|outbound|dispatching|signed|canceling|canceled', '', '{"master":"B:sale/order:1"}');
```

- B: `MetaType::Business`
- sale/order: 为订单 `Meta`。里面包含了商品，用户等信息.
- sale/orderState: 为订单状态`Meta`。里面定义了订单所用到的各种状态信息。
- master：说明 orderState 依附于 order。这会 让Nature 对 orderState的处理方式产生影响，如 ID 属性，下面会有说明。

### Nature 关键点

在传统的设计方式里，“订单”和“订单状态”一般情况下会放到一张数据表中，新的状态会覆盖掉旧的状态，所以要跟踪这些状态变化需要额外的机制来保障，这是一件比较困难的事。Nature 建议将订单和订单状态分开存放，原因是订单数据是不变的而订单状态是需要变化的。

**Nature 中的常规数据一旦生成将不允许改变或者删除，而状态数据的每次变更都会生成一个新副本。**所以如果将订单和订单状态合在一起， Nature 将产生过多的冗余数据。用好 Nature 的这种机制既满足了状态跟踪需求，又减少了存储空间,而这个复杂性对Nature 的使用人员来讲是无感知的。

**“|”**：表示 `orderState` 的状态是**互斥**的，既当生成一个 `paid` 状态的`orderState` 实例时，这个实例的状态不允许包含诸如 `new`等的其它状态。Nature 对互斥支持的很好，如果你输入一个新的状态，她自动会替换掉与之互斥的其它状态。

`master` 说明 `orderState` 依附于 `order`，这是个非常重要的属性，如果应用的好，你只需定义 `converter` 而可无需实现 `converter` 就可以实现`Meta`间示例的转换。

## 定义 `Relation`

当你从外部输入一个`order Instance`到 Nature 后，我们需要设置这个 `order` 的状态为 `new`。要实现这个功能我们需要定义一个 `converter`， 请执行下面的 sql。

```mysql
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/order:1', 'B:sale/orderState:1', '{"target_states":{"add":["new"]}}');
```

`relation`数据表用于存储 `converter` 的定义，相关说明如下：

| 字段或属性      | 说明                                                         |
| --------------- | ------------------------------------------------------------ |
| from_meta       | `converter`的输入，格式为 [`MetaType`]:[key]:[version]       |
| to_meta         | `converter`的输出，格式同 from_meta                          |
| settings        | 是一个 `JSON` 形式的配置对象，用于说明如何这个关系。         |
| `target_states` | 当 `converter` 转换完成后，该属性会要求 Nature 在返回的实例上添加或移除状态。 |

## 定义`Order`和相关的业务对象

在 `Nature-Demo-Common` 项目中我们需要定义一些业务对象，它们会被 `Nature-Demo`项目用到。

```rust
#[derive(Serialize, Deserialize, Debug, Default, Clone, PartialEq, Eq)]
pub struct Commodity {
    pub id: u32,
    pub name: String,
}

#[derive(Serialize, Deserialize, Debug, Default, Clone, PartialEq, Eq)]
pub struct SelectedCommodity {
    pub item: Commodity,
    pub num: u32,
}

#[derive(Serialize, Deserialize, Debug, Default, Clone, PartialEq, Eq)]
pub struct Order {
    pub user_id: u32,
    pub price: u32,
    pub items: Vec<SelectedCommodity>,
    pub address: String,
}
```

### Nature 要点

**我们不需要为`Order`定义ID属性**, `Order` 实例在运行时会依附于一个 `Instance`，而Nature会自动为`Instance`创建一个ID。 

在这里我们没有定义 `OrderState`对象, 这是因为除了 `Meta`中定义的状态列表外我们不在需要什么其他属性。

## 提交 `Instance` 到 Nature

在 Nature-Demo 项目中，我们构建了一个 `Order` 的实例，它包含了一部电话和两块电池。

```rust
fn create_order() -> Order {
    Order {
        user_id: 123,
        price: 1000,
        items: vec![
            SelectedCommodity {
                item: Commodity { id: 1, name: "phone".to_string() },
                num: 1,
            },
            SelectedCommodity {
                item: Commodity { id: 2, name: "battery".to_string() },
                num: 2,
            }
        ],
        address: "a.b.c".to_string(),
    }
}
```

并且把这个实例的JSON形式绑定到 `Instance。content` 上，这个`Instance`的 `MetaType` 为 "/B/order:1"。

```rust
        // 创建一个订单对象
        let order = create_order();
        // ---- 闯将一个 instance, 其 meta 为: "B:order:1"
        let mut instance = Instance::new("/sale/order").unwrap();
        instance.content = serde_json::to_string(&order).unwrap();
```

然后我们把这个`Instance` 提交给 Nature

```rust
        let response = CLIENT.post(URL_INPUT).json(&instance).send();
        let id_s: String = response.unwrap().text().unwrap();
        let id: Result<u128, NatureError> = serde_json::from_str(&id_s).unwrap();
        let id = id.unwrap();
```

`URL_INPUT` 参数的形式是： "http://{server}:{port}/input"。Nature 将保存这个 `Instance`，如果成功Nature 将返回这个`Instance`的ID，否则返回错误信息。

#### Nature 要点

用于创建 `instance` 的 `meta` 必须已经在meta 数据表中定义过。

如果你没有为 `Instance` 指定一个ID，Nature 会为你生成一个 128 位的 hash 值作为它的ID

同一个`Instance`你可以提交多次，它们会返回相同的ID，Nature 是幂等的。

## Nature 幕后为你做了什么

 `Order` 和 `OrderState` 的 `Relation` 是没有 `Executor`的， Nature 会**自动进行转换**，将 order `Instance` 转换为 orderState  `Instance` 。

因为 orderState 的 master 是 order ，所以Nature 将orderState `Instance` 的 ID 设置为 order `Instance` 的ID。

又因为`Relation` 的  target_states 属性指定了“new” 状态。所以 orderState实例的状态里有一个“new”。

### Nature 要点

在这个示例中 order 和 orderState 的 `Instance` **具有相同的 ID**， 这样做的好处就是，我可以用一个ID就可以将所有相关联的业务数据一次性提取出来。而传统数据库的设计方式往往是需要外键转换的，这会影响性能。

这是**非常关键的一个特性**，源数据可以被认为是一个事务，而源数据的ID可用于跟踪这个事务的一切处理结果，而不需要通过中间的关系来查找，这一方面提升的查询的性能。另一方面会大量减少关系数据的维护。更重要的是该特性还可以有效的应对数据不一致问题，从未减少不必要的技术复杂度。

以后的示例中会大量应用这一特性。

## 与传统开发方式的区别

传统方式下设计对代码的约束是比较弱的，但通过上面的例子你可以看到，虽然我们的代码里面有 order 的定义，但是我们无法对`Meta`中的 order 进行重新定义，甚至orderState的值我们都不能自由设置。这说明Nature 的`设计时`会对`运行时`进行强制约束。

这种约束就像接口对实现的约束效果是一样的。只不过接口只能由代码来体现，而Nature的约束则可以有业务方来直接表达。这就减少的很多中间环节，时间和人员成本也就跟着降下来了。另一方面，因为减少的中间环节，信息就不会失真，目标表达更准确，代码也就少走了很多弯路，

不知道你有没有发现，所有的 `Instance` 都是由Nature 进行存储的，也就是说业务系统可以完全不用考虑数据库的事情，我不知道这会为业务系统减少多少负担。

Demo中有反复提交的演示，以说明Nature 是幂等的。不仅如此Nature 还会为你默默的处理好像重试、最终一致性等问题，大幅度减少传统业务系统的技术复杂度，使开发人员更专注于业务的实现。

Nature 对业务系统简化的不仅仅是技术复杂性，对业务逻辑的简化也是比较显著。本示例中业务系统只是提交一个 order 的`Instance`到 Nature， Nature 就自动生成了orderState 并维护了它的状态。状态处理在业务系统中是非常难以维护的业务逻辑，尤其是业务一致性保障及状态跟踪。而Nature 几乎不用写代码就可以实现复杂的状态处理。

业务系统越简单就越不容易出错，也就越健壮、稳定。