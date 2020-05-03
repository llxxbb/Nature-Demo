-- generate time range based on `order` ---------------------------------------------

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/order', 'order', 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/time_range/second', 'time range for second' , 1, '', '', '{"cache_saved":true}');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/time_range/minute', 'minute time range for minute' , 1, '', '', '{"cache_saved":true}');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/time_range/hour', 'minute time range for hour' , 1, '', '', '{"cache_saved":true}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/order:1', 'B:sale/time_range/second:1', '{"executor":{"protocol":"builtIn","url":"time_range","settings":"{}"}}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/time_range/second:1', 'B:sale/time_range/minute:1', '{"executor":{"protocol":"builtIn","url":"time_range","settings":"{\\"on_para\\":true,\\"unit\\":\\"m\\"}"}}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/time_range/minute:1', 'B:sale/time_range/hour:1', '{"executor":{"protocol":"builtIn","url":"time_range","settings":"{\\"on_para\\":true,\\"unit\\":\\"h\\"}"}}');

-- item statistics index ---------------------------------------------

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/volume/s', 'how many item sold in second' , 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/volume/m', 'how many item sold in minute' , 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/money/s', 'how much money received in second' , 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/money/m', 'how much money received in minute' , 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('M', 'sale/order/to_item', '', 1, '', '', '{"multi_meta":["B:sale/item/volume/s:1","B:sale/item/money/s:1"]}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/time_range/minute:1', 'M:sale/order/to_item:1', '{"executor":{"protocol":"localRust","url":"nature_demo_executor:order_to_item"}}');
