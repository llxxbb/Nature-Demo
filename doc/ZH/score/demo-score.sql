-- all class's all subjects score to personal subject score ---------------------------------------------

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/table', 'store original score data', 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/trainee/subject', 'person original score', 1, '', '', '');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:score/table:1', 'B:score/trainee/subject:1', '{"executor":{"protocol":"builtIn","url":"dimensionSplit","settings":"{\\"wanted_dimension\\":[[\\"\\",[0,1,2]]]}"}, "filter_after":[{"protocol":"localRust","url":"nature_demo_executor:person_score_filter"},{"protocol":"http","url":"http://127.0.0.1:8082/add_score"}]}');

-- sum for personal subject ---------------------------------------------

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/trainee/all-subject', 'all subject\'s score for a person', 1, '', '', '{"is_state":true}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:score/trainee/subject:1', 'B:score/trainee/all-subject:1', '{"use_upstream_id":true,"target":{"upstream_para":[0,1]},"executor":{"protocol":"builtIn","url":"sum","settings":"{\\"para_part\\":2}"}}');

-- generate cron ---------------------------------------------

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/subject/time_range', 'indicate the time_range from the upstream instance.create_time' , 1, '', '', '{"cache_saved":true}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:score/trainee/subject:1', 'B:score/subject/time_range:1', '{"use_upstream_id":true,"executor":{"protocol":"builtIn","url":"time_range","settings":"{}"}}');

-- subject top 3 ---------------------------------------------

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/subject/top', 'subject score top', 1, '', '', '{"is_state":true}');
