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
