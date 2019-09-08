# Generate order

We suppose the user have goods selected, and use it to generate an order.

### Define `meta`s

First we will define two `meta`s. please insert the follow data to nature.sqlite.

- /B/sale/order: includes normal order properties.

- /B/sale/orderState: the status for new, paid, outbound, dispatching, signed etcetera.

  ```sqlite
  INSERT INTO meta
  (full_key, description, version, states, fields, config)
  VALUES('/B/sale/order', 'order', 1, '', '', '{}');
  
  INSERT INTO meta
  (full_key, description, version, states, fields, config)
  VALUES('/B/sale/orderState', 'order state', 1, 'new,paid,picked,outbound,dispatching,signed', '', '{}');
  ```

### Nature key points

In tradition design, order and order state will be fill into one table, in this condition, new state will overwrite the old one, so it's difficult to trace the changes. **In Nature, normal data and state data are separated strictly**, You must define them separately. And furthermore, Nature will trace every change for the state data.

## Define converter

When we input an `Order` from outside, we set a `new` state for this order by converter. Execute the following sql please:

```sqlite
INSERT INTO one_step_flow
(from_meta, to_meta, settings)
VALUES('/B/sale/order:1', '/B/sale/orderState:1', '{"executor":[{"protocol":"LocalRust","url":"nature_demo_converter.dll:order_new","proportion":1}],"use_upstream_id":true}');
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
| executor        | Who will do the convert job, it's a list. The following table show the detail for it's item. |
| use_upstream_id | If this is set to "true", the `orderState` instance's id will use `order` instance's id. |
|                 |                                                              |

Executor settings: 

| field      | value description                                            |
| ---------- | ------------------------------------------------------------ |
| protocol   | how to communicate with the executor: `LocalRust` or `http`, to simplify this demo, we use `LocalRust` |
| url        | where to find the executor                                   |
| proportion | weight value among the executor list. high weight will get high chance to process the job. |

### Nature key points

**`use_upstream_id`** property will be convenient for state data. Through the same id, you will get the normal data and state data directly. 

## Define `Order` and other related objects

In project Nature-Demo-Common we need define some business entities which would be used in Nature-Demo and Nature-Demo-Converter, such as `Order`. Let's do it.

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





