# 求出每个人的总成绩

现在我们来求每个人的所有科目的总成绩。首先定义`Meta`

## 定义`Meta`

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/trainee/all-subject', 'all subject\'s score for a person', 1, '', '', '{"is_state":true}');
```

对于`score/trainee/all-subject`来讲它应该是一个状态数据，个人成绩是一条一条汇总过来的，所以为了能够和上次的成绩进行叠加，我们需要用Nature的`State-Meta`来解决这个问题。

### Nature 要点

`score/trainee/all-subject`虽然是状态数据，但我们又不需要对每个状态进行描述，因此`states`字段的值为空。然而 Nature 任务`states`字段为空的`Meta`为非状态的，这时候我们就可以用`is_state`来强制为状态数据。

## 定义`Relation`

```mysql
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:score/trainee/subject:1', 'B:score/trainee/all-subject:1', '{"use_upstream_id":true,"target":{"upstream_para":[0,1]},"executor":{"protocol":"builtIn","url":"sum","settings":"{\\"para_part\\":2}"}}');
```

### Nature 要点

`use_upstream_id` :说明`score/trainee/all-subject`实例ID会使用`score/trainee/subject`的实例ID.

`sum`:用于求和的内建的执行器。`settings.para_part`则说明用`Instance.para`从0开始的那个部分来标记要求和的数据。`Instance.para`的其他部分则会作为要生成实例的`para`。如本例中输入的`para`为"class5/name1/subject3"，则输出的`para`为“class5/name1”，而生成`Instance.content`的内容可能如下：

```json
{"detail":{"subject2":33,"subject3":100,"subject1":62},"total":195}
```



