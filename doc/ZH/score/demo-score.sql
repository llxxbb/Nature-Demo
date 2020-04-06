-- dimension split ---------------------------------------------

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/table', 'store original score data', 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/trainee/subject', 'person original score', 1, '', '', '{"master":"B:score/table:1"}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:score/table:1', 'B:score/trainee/subject:1', '{"executor":[{"protocol":"builtIn","url":"dimensionSplit","settings":"{\\"wanted_dimension\\":[[\\"\\",[0,1,2]]]}"}]}');

-- xxx  ---------------------------------------------
