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

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/order:1', 'B:sale/item/tag_second:1', '{"executor":{"protocol":"builtIn","url":"time_range"}}');

-- item statistics index ---------------------------------------------
-- second data
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/counter/s', 'how many item sold in second' , 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/money/s', 'how much money received in a second for one item' , 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('M', 'sale/order/second', '', 1, '', '', '{"multi_meta":["B:sale/item/counter/s:1","B:sale/item/money/s:1"]}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/item/tag_second:1', 'M:sale/order/second:1', '{"filter_before":[{"protocol":"builtIn","url":"instance-loader","settings":"{\\"key_gt\\":\\"B:sale/order:1|\\",\\"key_lt\\":\\"B:sale/order:2|\\",\\"time_part\\":[0,1],\\"filters\\":[{\\"protocol\\":\\"localRust\\",\\"url\\":\\"nature_demo_executor:order2item\\"}]}"}],"delay_on_para":[2,1],"executor":{"protocol":"localRust","url":"nature_demo_executor:item_statistics"}}');
-- \\"filters\\":[{\\"protocol\\":\\"localRust\\",\\"url\\":\\"nature_demo_executor:order2item\\"}]

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
