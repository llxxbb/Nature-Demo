# Pay the bill

Now the user will pay for the order.  Here we make it a little complex,  we suppose any one of the user's card is not enough to pay the bill, but the total of three of them is ok. Let's define the business logic.

 ## Define `orderPaid` `meta`

```sqlite
INSERT INTO meta
(full_key, description, version, states, fields, config)
VALUES('/B/finance/orderPaid', 'order paid', 1, 'unpaid|partial|paid', '', '{}');
```

`orderPaid` is also a state `meta`.

## Define `converter` from `orderState[new]` to `orderPaid[unpaid]` 

```sqlite
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('/B/sale/orderState:1', '/B/finance/orderPaid:1', '{"selector":{"source_state_include":["new"]},"executor":[{"protocol":"LocalRust","url":"nature_demo_converter.dll:order_receivable","proportion":1}],"use_upstream_id":true,"target_states":{"add":["unpaid"]}}');
```

We can see a new converter setting: 

| field    | value description                                            |
| -------- | ------------------------------------------------------------ |
| selector | upstream or downstream must satisfy conditions defined in this field. |

selector setting:


| field                | value description                    |
| -------------------- | ------------------------------------ |
| source_state_include | upstream must include defined state. |

This setting means `orderPaid` need a `orderState` with a "**new**" state, other state will be ignored.

## Implement `order_receivable` converter

## Define `converter` from `orderPaid[paid]`  to `orderState[paid]`

```sqlite
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('/B/sale/orderPaidorderState:1', '/B/finance/orderState:1', '{"selector":{"source_state_include":["paid"]},"executor":[{"protocol":"LocalRust","url":"nature_demo_converter.dll:order_paid","proportion":1}],"use_upstream_id":true,"target_states":{"add":["paid"]}}');
```

## Implement `order_paid` converter