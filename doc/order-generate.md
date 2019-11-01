# Generate order

We suppose the user have goods selected, and use it to generate an order.

## Define `meta`

[Here](https://github.com/llxxbb/Nature/blob/master/doc/help/concept-meta.md) you can know more about `meta`.

First we will define two `meta`s. please insert the follow data to nature.sqlite. 

- /B/sale/order: includes normal order properties.

- /B/sale/orderState: the status for new, paid, outbound, dispatching, signed etcetera.

```sqlite
INSERT INTO meta
(full_key, description, version, states, fields, config)
VALUES('/B/sale/order', 'order', 1, '', '', '{}');

INSERT INTO meta
(full_key, description, version, states, fields, config)
VALUES('/B/sale/orderState', 'order state', 1, 'new|paid|picked|outbound|dispatching|signed|canceling|canceled', '', '{"master":"/B/sale/order:1"}');
```
  
### Nature key points

In tradition design, order and order state will be fill into one table, in this condition, new state will overwrite the old one, so it's difficult to trace the changes. **In Nature, normal data and state data are separated strictly**, You must define them separately. And furthermore, Nature will trace every change for the state data by state version.

mutex state are separated by "|". 

`master` means if you did not appoint a `executor` for `orderState`,  Nature will give a default convert with empty body. You will see a implement `executor` in the next chapter.

## Define `converter`

When we input an `Order` from outside, we set a `new` state for this order by converter. Execute the following sql please:

```sqlite
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('/B/sale/order:1', '/B/sale/orderState:1', '{"target_states":{"add":["new"]}}');
```

Let's see some explanation:

| field     | value description                                            |
| --------- | ------------------------------------------------------------ |
| from_meta | The `order` defined in `meta` , the form is [full_key]:[version] |
| to_meta   | `orderState` defined in `meta` , the form is [full_key]:[version] |
| settings  | A `JSON` string for converter's setting. It's value described in following table |

Converter settings

| field           | value description                                            |
| --------------- | ------------------------------------------------------------ |
| use_upstream_id | If this is set to "true", the `orderState` instance's id will use `order` instance's id. |
| target_states   | after convert Nature will add and or remove the states which target_states defined. |

### Nature key points

**`use_upstream_id`** property will be convenient for state data and it can only used to **state data**, because converter can return many **normal data**, the same id would make them conflict.

Through the same id, you will get the normal data and state data directly, do not need a foreign key be translated like relation database does. 

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

Nature generate an `orderState` instance Automatically.  It's id is same with `order`' instance because of the converter setting **`use_upstream_id`**, and it will has a **"new"** state will because of the setting `target_states` in converter definition. The demo will queried it and show it for you.

## Different with traditional development

To finish a business logic you must separate it into two part clearly:  

- Business logic define, 
- Business logic implement

Who can finish business logic define need not to be a developer maybe a business designer. **That is great for collaboration: less argument strong constrain** and easy for each other. Traditional way is not that clear, the developer do the tow parts all. And the "definitions" coupled to the code very tightly that make the business system complex and difficult to maintain.

Compare to traditional the business logic implement is easy. you need not to take care about database work, transaction, idempotent and retries. Nature separate it into pieces and that make it easy too to dev and maintain. Even more Nature may automatically generate state data. More easy more correctable and more stable!

There is also a disadvantage in Nature that is Nature do all the job in asynchronized way except the fist `instance` you inputted.