# 生成订单

我们假设用户已经选择了商品，并以此生成订单。

## 定义 `Meta`

你可以在[这里](https://github.com/llxxbb/Nature/blob/master/doc_zh/help/concept-meta.md)了解 `Meta` 的信息。首先我们需要定义两个 `Meta`，请执行下面的sql脚本

```sqlite
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/order', 'order', 1, '', '', '{}');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/orderState', 'order state', 1, 'new|paid|package|outbound|dispatching|signed|canceling|canceled', '', '{"master":"B:sale/order:1"}');
```

- B:sale/order: 为订单 `Meta`。里面包含了商品，用户等信息.

- B:sale/orderState: 为订单状态`Meta`。里面定义了订单所用到的各种状态信息.

### Nature 关键点

在传统的设计方式里，“订单”和“订单状态”一般情况下会放到一张数据表中，新的状态会覆盖掉旧的状态，所以要跟踪这些状态变化是一件比较困难的事。但 **Nature 不建议这么做**，因为订单里有很多内容，而状态改变只会影响非常少的数据，所以 这里将订单信息拆分成常规数据和状态数据两个部分。

**常规数据一旦生成将不允许改变或者删除，而状态数据的每次变化都会生成一个新的状态版本数据，并不会覆盖掉旧的数据。**这样既满足了状态跟踪需求，又减少了存储空间，而这个复杂性对Nature的使用人员来讲是无感知的。

**“|”**：表示 `orderState` 的状态是**互斥**的，既当生成一个 `paid` 状态的`orderState` 实例时，这个实例的状态不允许包含诸如 `new`等的其它状态。Nature 对互斥支持的很好，如果你输入一个状态，她自动会替换掉与之互斥的其它状态。

`master` 说明 `orderState` 依附于 `order`，这是个非常重要的属性，如果应用的好，你只需定义 `converter` 而可无需实现 `converter` 就可以实现`Meta`间示例的转换，请看下面小节的说明。

## 定义 `converter`

当你从外部输入一个`order`实例到 Nature 后，我们需要设置这个 `order` 的状态为 `new`。要实现这个功能我们需要定义一个 `converter`， 请执行下面的 sql。

```sqlite
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/order:1', 'B:sale/orderState:1', '{"target_states":{"add":["new"]}}');
```

`relation`数据表用于存储 `converter` 的定义，相关说明如下：

| 字段或属性      | 说明                                                         |
| --------------- | ------------------------------------------------------------ |
| from_meta       | `converter`的输入，格式为 [`MetaType`]:[key]:[version]       |
| to_meta         | `converter`的输出，格式同 from_meta                          |
| settings        | 是一个 `JSON` 形式的配置对象， 详细说明请看[这里](https://github.com/llxxbb/Nature/blob/master/doc_zh/help/converter.md)。 |
| `target_states` | 当 `converter` 转换完成后，会自动在返回的实例上添加或移除状态。 |

`master` means if you did not appoint a `executor` for `orderState`,  Nature will give a default conversion with empty body, and it's id will be same as `B:sale/order`. You will see a `converter` that need a implement in the next chapter.

## Define `Order` and other related business objects

In project `Nature-Demo-Common` we need define some business entities. They would be used in `Nature-Demo` project.

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

### Nature key points

**You need not to give an id to `Order`, because it will becomes to Nature's `Instance`**. an `Instance` would have it's own id.

There is no struct defined for `OrderState`, it is only defined as a `meta` and the `meta` hold its whole states, it does not need to have a body to contain any other things.

## Commit an `Order` to Nature

In project Nature-Demo we create an `Order` which include a phone and two battery.

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

And boxed it into an `Instance` of `meta` "/B/order:1"

```rust
        // create an order
        let order = create_order();
        // ---- create a instance with meta: "/B/order:1"
        let mut instance = Instance::new("/sale/order").unwrap();
        instance.content = serde_json::to_string(&order).unwrap();
```

Then send it to Nature

```rust
        let response = CLIENT.post(URL_INPUT).json(&instance).send();
        let id_s: String = response.unwrap().text().unwrap();
        let id: Result<u128, NatureError> = serde_json::from_str(&id_s).unwrap();
        let id = id.unwrap();
```

The `URL_INPUT` would be "http://{server}:{port}/input".  Nature will save the `Order` and return the `instance`'s id if it success. At the same time Nature will call the converter to generate the `OrderState` `instance`.

#### Nature key points

Nature only accept JSON data of `instance` and it's `meta` must be registered or use `Dynamic-Meta`, if the `meta` did not register Nature will reject it.

You can call `input` many time when failed with the same parameter, but nature will only accept once, it is idempotent. 

If you did not provide the id Nature will generated one based on 128-bits hash algorithm for you.

## What did Nature do for you after committing

Nature generate an `orderState` instance Automatically.  It's id is same with `order`' instance because of the `orderState`'s `master` setting , and it will has a **"new"** state because of the setting `target_states` in converter definition. The demo will queried it and show it for you.

## Different with traditional development

Nature use design impose **strong** constrains on implement. In traditional way the design is wake. because when we write the code we re-write the design again at the same. In Nature the code can't overwrite the design and needn't also yet. The Strong constrains will make team less argument and easy for each other, then save your money and time. 

In other way. you need not to take care about database work, transaction, idempotent and retries, Nature will take care of them. Even more Nature may automatically generate state data. More easy more correctable and more stable!

In this example you can get `order` and `orderState` by the same id, and in the next chapter you will see the same id can get `orderAccount` also. In tradition way the ids would be different and connected them together by the the relation-tables or foreign-keys.

There is also a disadvantage in Nature that is Nature do all the job in asynchronized way except the fist `instance` you inputted.