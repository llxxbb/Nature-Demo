-- all class's all subjects score to personal subject score ---------------------------------------------

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/table', 'store original score data', 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/trainee/subject', 'person original score', 1, '', '', '');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:score/table:1', 'B:score/trainee/subject:1', '{"executor":{"protocol":"builtIn","url":"dimensionSplit","settings":"{\\"wanted_dimension\\":[[\\"\\",[0,1,2]]]}"}, "filter_after":[{"protocol":"localRust","url":"nature_demo_executor:person_score_filter"}]}');

-- sum for personal subject ---------------------------------------------

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/trainee/all-subject', 'all subject\'s score for a person', 1, '', '', '{"is_state":true}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:score/trainee/subject:1', 'B:score/trainee/all-subject:1', '{"use_upstream_id":true,"target":{"upstream_para":[0,1]},"executor":{"protocol":"builtIn","url":"sum","settings":"{\\"para_part\\":2}"}}');
