# Pay the bill

Now the user will pay for the order.  Here we make it a little complex,  we suppose any one of the user's card is not enough to pay the bill, but the total of three of them is ok. Let's define the business logic.

 ## Define `orderPaid` `meta`

```sqlite
INSERT INTO meta
(full_key, description, version, states, fields, config)
VALUES('/B/finance/orderPaid', 'order paid', 1, 'unpaid,partial,paid', '', '{}');
```

## Define `converter` from `orderState[new]` to `orderPaid` 

```sqlite
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('/B/sale/orderState:1', '/B/finance/orderPaid:1', '{"executor":[{"protocol":"LocalRust","url":"nature_demo_converter.dll:order_receivable","proportion":1}],"use_upstream_id":true,"target_states":{"add":["unpaid"]}}');
```

