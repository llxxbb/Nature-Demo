# Pay the bill

Now the user will pay for the order.  Here we make it a little complex,  we suppose any one of the user's card is not enough to pay the bill, but the total of three of them is ok. Let's define the business logic.

 ## Define `meta`

```sqlite
INSERT INTO meta
(full_key, description, version, states, fields, config)
VALUES('/B/finance/payment', 'order payment', 1, '', '', '{}');

INSERT INTO meta
(full_key, description, version, states, fields, config)
VALUES('/B/finance/orderAccount', 'order account', 1, 'unpaid|partial|paid', '', '{}');
```

`orderAccount` is also a state `meta`.

## Define `converter`

```sqlite
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('/B/sale/orderState:1', '/B/finance/orderAccount:1', '{"selector":{"source_state_include":["new"]},"executor":[{"protocol":"LocalRust","url":"nature_demo_converter.dll:order_receivable","proportion":1}],"use_upstream_id":true,"target_states":{"add":["unpaid"]}}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('/B/finance/payment:1', '/B/finance/orderAccount:1', '"executor":[{"protocol":"LocalRust","url":"nature_demo_converter.dll:pay_count","proportion":1}]');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('/B/finance/orderAccount:1', '/B/sale/orderState:1', '{"selector":{"source_state_include":["paid"]},"executor":[{"protocol":"LocalRust","url":"nature_demo_converter.dll:order_paid","proportion":1}],"use_upstream_id":true,"target_states":{"add":["paid"]}}');
```

We can see a new converter setting: 

| field    | value description                                            |
| -------- | ------------------------------------------------------------ |
| selector | upstream or downstream must satisfy conditions defined in this field. |

selector setting:


| field                | value description                    |
| -------------------- | ------------------------------------ |
| source_state_include | upstream must include defined state. |

The first relation's setting means `orderAccount` need a `orderState` with a "**new**" state, other state will be ignored.

## Business objects and pay logic

```

```



## Implement converter

### `order_receivable` 

### `pay_count`

### `order_paid` 



## unfinished

all version of OrderAccount will be seen;


