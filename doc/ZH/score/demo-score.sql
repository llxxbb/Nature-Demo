-- dimension split ---------------------------------------------

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/table', 'store original score data', 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('M', 'score/dimensions', '', 1, '', '', '{"master":"B:score/table:1","multi_meta":["B:score/trainee/original:1","B:score/subject/original:1"]}');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/trainee/original', 'person original score', 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/subject/original', 'subject original score', 1, '', '', '');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:score/table:1', 'M:score/dimensions:1', '{"executor":[{"protocol":"builtIn","url":"dimensionSplit","settings":"{\\"wanted_dimension\\":[[\\"B:score/trainee/original:1\\",[0,1]],[\\"B:score/subject/original:1\\",[0,2]]]}"}]}');

-- xxx  ---------------------------------------------
