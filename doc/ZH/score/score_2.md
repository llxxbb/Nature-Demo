# 求出每个人的总成绩

现在我们来求每个人的所有科目的总成绩。首先定义`Meta`

## 定义`Meta`

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/trainee/all-subject', 'all subject\'s score for a person', 1, '', '', '{"is_state":true}');
```

对于`score/trainee/all-subject`来讲它应该是一个状态数据，个人成绩是一条一条汇总过来的，所以为了能够和上次的成绩进行叠加，我们需要用Nature的状态`Meta`来解决这个问题。

### Nature 要点

`score/trainee/all-subject`虽然是状态数据，但我们又不需要对每个状态进行描述，因此`states`字段的值为‘’。然而 Nature 任务`states`字段为空的`Meta`为非状态的，这时候我们就可以用`is_state`来强制为状态数据。

## 定义`Relation`

```

```

