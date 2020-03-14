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
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'finance/payment', 'order payment', 1, '', '', '{}');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'finance/orderAccount', 'order account', 1, 'unpaid|partial|paid', '', '{"master":"B:sale/order:1"}');

-- order --> orderAccount
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/order:1', 'B:finance/orderAccount:1', '{"executor":[{"protocol":"localRust","url":"nature_demo_converter.dll:order_receivable"}],"target_states":{"add":["unpaid"]}}');

-- payment --> orderAccount
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:finance/payment:1', 'B:finance/orderAccount:1', '{"executor":[{"protocol":"localRust","url":"nature_demo_converter.dll:pay_count"}]}');

-- orderAccount --> orderState
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:finance/orderAccount:1', 'B:sale/orderState:1', '{"selector":{"source_state_include":["paid"]},"target_states":{"add":["paid"]}}');

-- stock out  ---------------------------------------------
-- orderState:paid --> orderState:package
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/orderState:1', 'B:sale/orderState:1', '{"selector":{"source_state_include":["paid"]},"executor":[{"protocol":"http","url":"http://localhost:8082/send_to_warehouse"}],"target_states":{"add":["package"]}}');

-- delivery  ---------------------------------------------
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'third/waybill', 'waybill', 1, '', '', '{}');

-- orderState:outbound --> waybill
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/orderState:1', 'B:third/waybill:1', '{"selector":{"source_state_include":["outbound"]}, "executor":[{"protocol":"localRust","url":"nature_demo_converter.dll:go_express"}]}');

-- waybill --> orderState:dispatching
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:third/waybill:1', 'B:sale/orderState:1', '{"target_states":{"add":["dispatching"]}}');

-- signed  ---------------------------------------------
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/orderSign', 'order finished', 1, '', '', '{}');

-- orderState:dispatching --> orderSign
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/orderState:1', 'B:sale/orderSign:1', '{"delay":1,"selector":{"source_state_include":["dispatching"]}, "executor":[{"protocol":"localRust","url":"nature_demo_converter.dll:auto_sign"}]}');

-- orderSign --> orderState:signed
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/orderSign:1', 'B:sale/orderState:1', '{"target_states":{"add":["signed"]}}');

