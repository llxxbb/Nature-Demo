TRUNCATE TABLE `meta`;
TRUNCATE TABLE `relation`;
TRUNCATE TABLE `instances`;
TRUNCATE TABLE `task`;
TRUNCATE TABLE `task_error`;

-- generate time range based on `order` ---------------------------------------------

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/order', 'order', 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/tag_second', 'time range for second' , 1, '', '', '{"cache_saved":true}');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/tag_minute', 'minute time range for minute' , 1, '', '', '{"cache_saved":true}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/order:1', 'B:sale/item/tag_second:1', '{"executor":{"protocol":"builtIn","url":"time_range"}}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/item/tag_second:1', 'B:sale/item/tag_minute:1', '{"executor":{"protocol":"builtIn","url":"time_range","settings":"{\\"on_para\\":true,\\"unit\\":\\"m\\",\\"value\\":5}"}}');

-- item statistics index ---------------------------------------------
--
-- INSERT INTO meta
-- (meta_type, meta_key, description, version, states, fields, config)
-- VALUES('B', 'sale/item/sold/s', 'how many item sold in second' , 1, '', '', '');
--
-- INSERT INTO meta
-- (meta_type, meta_key, description, version, states, fields, config)
-- VALUES('B', 'sale/item/sold/m', 'how many item sold in minute' , 1, '', '', '');
--
-- INSERT INTO meta
-- (meta_type, meta_key, description, version, states, fields, config)
-- VALUES('B', 'sale/item/money/s', 'how much money received in second' , 1, '', '', '');
--
-- INSERT INTO meta
-- (meta_type, meta_key, description, version, states, fields, config)
-- VALUES('B', 'sale/item/money/m', 'how much money received in minute' , 1, '', '', '');
--
-- INSERT INTO meta
-- (meta_type, meta_key, description, version, states, fields, config)
-- VALUES('M', 'sale/order/to_item', '', 1, '', '', '{"multi_meta":["B:sale/item/sold/s:1","B:sale/item/money/s:1"]}');
--
-- INSERT INTO relation
-- (from_meta, to_meta, settings)
-- VALUES('B:sale/item/second:1', 'M:sale/order/to_item:1', '{"delay_on_para":[2,1],"executor":{"protocol":"http","url":"http://localhost:8082/order_to_item"}}');
