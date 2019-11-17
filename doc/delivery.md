# Delivery

Now we need some express companies to help us to transfer the goods to the customs, we want Nature to record the waybill info and query them at some time later, such as to finish the payment with express company.

The problem is that we want to query express info by waybill id, and we do not want to create a table outside of Nature to hold **"company id + waybill id"** and converter it to an **unique id**. Let's see how Nature to face on it.

## Define `meta`

```sqlite
INSERT INTO meta
(full_key, description, version, states, fields, config)
VALUES('/B/third/waybill', 'waybill', 1, '', '', '{}');
```

## Define converter

```sqlite
-- orderState:outbound --> waybill
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('/B/sale/orderState:1', '/B/third/waybill:1', '{"selector":{"source_state_include":["outbound"]}, "executor":[{"protocol":"localRust","url":"nature_demo_converter.dll:go_express"}]}');

-- waybill --> orderState:dispatching
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('/B/third/waybill:1', '/B/sale/orderState:1', '{"target_states":{"dispatching":["new"]}}');
```

## Converter Implement

### 

"any one"