# Pay the bill

Now the user will pay for the order.  Here we make it a little complex,  we suppose any one of the user's card is not enough to pay for the bill, but the total of three of them is ok. Let's define the business logic.

 ## Define `meta`

```sqlite
INSERT INTO meta
(full_key, description, version, states, fields, config)
VALUES('/B/finance/payment', 'order payment', 1, '', '', '{}');

INSERT INTO meta
(full_key, description, version, states, fields, config)
VALUES('/B/finance/orderAccount', 'order account', 1, 'unpaid|partial|paid', '', '{}');
```

`orderAccount` is also a state `meta`. but it's body is not empty! see follow.

## Define `converter`

```sqlite
-- order --> orderAccount
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('/B/sale/order:1', '/B/finance/orderAccount:1', '{"executor":[{"protocol":"LocalRust","url":"nature_demo_converter.dll:order_receivable"}],"use_upstream_id":true,"target_states":{"add":["unpaid"]}}');

-- payment --> orderAccount
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('/B/finance/payment:1', '/B/finance/orderAccount:1', '{"executor":[{"protocol":"LocalRust","url":"nature_demo_converter.dll:pay_count"}]}');

-- orderAccount --> orderState
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('/B/finance/orderAccount:1', '/B/sale/orderState:1', '{"selector":{"source_state_include":["paid"]},"use_upstream_id":true,"target_states":{"add":["paid"]}}');
```

## Business objects and pay logic

```

```







## Implement converter

In project Nature-Demo-Converter we will create a converter which can convert a `Order` to `OrderState`. The main code :



### order_receivable` 

### `pay_count`

last_

### `order_paid` 

### Nature key points

In [here](https://github.com/llxxbb/Nature/blob/master/doc/help/howto_localRustConverter.md) you will learn how to create a local-converter.

Like `input` interface of Nature, converter must return `instance` , but a array of instance.  there are some rules for the array.

- If the converter's target is a state `meta` you can return only one instance.
- You can not return empty array unless the target `meta type` is Null

## unfinished

payment how to find which instance of OrderAccound to operate

pay idempotent

state version conflict will auto fix by recall converter

all version of OrderAccount will be seen;

developer doesn't care about `orderState`'s value. this is done by Nature automatically.  like a cashier that she only do her own work. It's easy and correctable and stable.


