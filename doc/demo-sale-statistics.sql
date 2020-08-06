TRUNCATE TABLE `meta`;
TRUNCATE TABLE `relation`;
TRUNCATE TABLE `instances`;
TRUNCATE TABLE `task`;
TRUNCATE TABLE `task_error`;

-- order to item ---------------------------------------------
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/order', 'order', 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/money', 'item money', 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/count', 'item count', 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('M', 'sale/order/to_item', '', 1, '', '', '{"multi_meta":["B:sale/item/count:1","B:sale/item/money:1"]}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/order:1', 'M:sale/order/to_item:1', '{"executor":{"protocol":"localRust","url":"nature_demo_executor:order_to_item"}}');

-- time range for every item --------------------------------------------------------------------

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/money/tag_second', 'time range for second' , 1, '', '', '{"cache_saved":true}');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/count/tag_second', 'time range for second' , 1, '', '', '{"cache_saved":true}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/item/money:1', 'B:sale/item/money/tag_second:1', '{"target":{"append_para":[0]},"executor":{"protocol":"builtIn","url":"time_range"}}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/item/count:1', 'B:sale/item/count/tag_second:1', '{"target":{"append_para":[0]},"executor":{"protocol":"builtIn","url":"time_range"}}');


-- item statistics ---------------------------------------------

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/money/second', 'time range for second' , 1, '', '', '{"cache_saved":true}');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/count/second', 'time range for second' , 1, '', '', '{"cache_saved":true}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/item/money/tag_second:1', 'B:sale/item/money/second:1', '{"delay_on_para":[2,1],"executor":{"protocol":"builtIn","url":"time_range"}}');


-- item statistics ---------------------------------------------



-- "filter_before":[{"protocol":"builtIn","url":"instance-loader","settings":"{\\"key_gt\\":\\"B:sale/order:1|\\",\\"key_lt\\":\\"B:sale/order:2|\\",\\"time_part\\":[0,1],\\"filters\\":[{\\"protocol\\":\\"localRust\\",\\"url\\":\\"nature_demo_executor:order2item\\"}]}"}]


-- minute data
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/tag_minute', 'minute time range for minute' , 1, '', '', '{"cache_saved":true}');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/counter/m', 'how many item sold in minute' , 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/money/m', 'how much money received in minute' , 1, '', '', '');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/item/tag_second:1', 'B:sale/item/tag_minute:1', '{"executor":{"protocol":"builtIn","url":"time_range","settings":"{\\"on_para\\":true,\\"unit\\":\\"m\\",\\"value\\":5}"}}');
