# 求出每个人的总成绩

现在我们来求每个人的所有科目的总成绩。首先定义`Meta`

## 定义个人总成绩`Meta`

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/trainee/all-subject', 'all subject\'s score for a person', 1, '', '', '{"is_state":true}');
```

### Nature 要点

对于`score/trainee/all-subject`来讲它应该是一个状态数据，个人成绩是一条一条汇总过来的，因为 Nature 的数据不可变更性，我们只能用状态数据来进行成绩叠加操作。

`score/trainee/all-subject`虽然是状态数据，但我们又不需要对每个状态进行描述，因此`states`字段的值为空。然而 Nature 认为`states`字段为空的`Meta`是非状态的，这时候就需要我们用`is_state`来强制它作为状态数据。

## 计算个人总成绩

有了`个人中成绩`的定义后，我们就可以进行计算了，先建立`个人学科成绩`于`个人总成绩`的的`Relation`

```mysql
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:score/trainee/subject:1', 'B:score/trainee/all-subject:1', '{"target":{"upstream_para":[0]},"executor":{"protocol":"builtIn","url":"sum","settings":"{\\"para_part\\":1}"}}');
```

### 设置计算结果叠加的目标实例

这里出现了一个新的用法：

```json
"target":{"upstream_para":[0]}
```

这个是告诉 Nature 我们的计算结果要往哪个`Instance`上叠加，`target`指的是 `B:score/trainee/all-subject:1`，`upstream_para` 指的是`B:score/trainee/subject:1`的 para 的哪个部分， 还记得吗，这个para的形式是 “学号/学科”。整个的意思是要在 `B:score/trainee/all-subject:1|0|学号` 上进行叠加计算。

### 内置执行器：sum

很高兴的是，我们在`Relation`中又看到了一个`builtin-executor`：`sum`也就是说我们只需要配置一下而无需编码就可以完成这个工作了。在使用 sum 之前我们需要先设置一下

```json
"settings":"{\\"para_part\\":1}"
```

`para_part`的作用有两个：

- 说明用上游数据`Instance.para`的哪个部分来标记要求和的数据。对于此例来讲`上游.para`便是“学号/学科”,  1 对应的就是“学科”的位置（para的起始位置为0）。
- 未被标记的 para 自动会形成当前输出的 para。 对于此 Demo 来讲“学号”讲作为 `B:score/trainee/all-subject:1`的 para 进行输出。

## 运行 Demo

- 启动 nature.exe
- 启动  nature_demo_executor_restful.exe
- 运行 nature-demo::score::score_test 
- 查看`instance`数据表中的数据以验证结果。

我们会看到类似于下面的数据输出：

| ins_key | state_version | content |
| ------- | ------------- | ------- |
|B:score/trainee/all-subject:1\|0\|001|1| {"detail":{"subject2":37},"total":37} |
|B:score/trainee/all-subject:1\|0\|001|2| {"detail":{"subject2":37,"subject3":100},"total":137} |
|B:score/trainee/all-subject:1\|0\|001|3| {"detail":{"subject2":37,"subject3":100,"subject1":62},"total":199} |

## 这不是最好的

**本示例仅限于有限计算结果的叠加**。其实这是一种低效的统计方法，我们看到每次叠加都会形成一个版本，这对于高并发的电商销量统计而言显然是一种灾难。这就需要用一种新的统计方法。请参考[销量统计demo](../sale/sale_1_make_time_range.md)

