-- generate order ---------------------------------------------
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/order', 'order', 1, '', '', '{}');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/orderState', 'order state', 1, 'new|paid|package|outbound|dispatching|signed|canceling|canceled', '', '{"master":"B:sale/order:1"}');

-- order --> orderState
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/order:1', 'B:sale/orderState:1', '{"target_states":{"add":["new"]}}');

-- pay for the bill  ---------------------------------------------

-- order --> orderAccount

-- payment --> orderAccount

-- orderAccount --> orderState

-- stock out  ---------------------------------------------
-- orderState:paid --> orderState:package

-- stock out  ---------------------------------------------

-- orderState:outbound --> waybill

-- waybill --> orderState:dispatching

-- signed  ---------------------------------------------

-- orderState:dispatching --> orderSign

-- orderSign --> orderState:signed
