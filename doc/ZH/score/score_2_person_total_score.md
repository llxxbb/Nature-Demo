# 求出每个人的总成绩

现在我们来求每个人所有科目的`总成绩`。首先定义`Meta`

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/trainee/all-subject', 'all subject\'s score for a person', 1, '', '', '{"is_state":true}');
```

- **Nature 要点**：请注意 `config` 字段的值为空，因为在这里我们不需要任何状态，所以Nature 会将之视为非状态数据既常规数据来处理。然而个人成绩是一条一条汇总过来的，所以总成绩是在不断变化的，这就需要 `all-subject`是一个状态数据。为了达到这个目的，我们需要强制`all-subject`成为状态数据，这也是Nature 引入 `is_state` 属性的原因，此属性可以将任何非状态数据转换成状态数据。

有了`个人总成绩`的定义后，我们就可以进行计算了，建立下面的`Relation`

```mysql
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:score/trainee/subject:1', 'B:score/trainee/all-subject:1', '{"target":{"copy_para":[0]},"executor":{"protocol":"builtIn","url":"sum","settings":"{\\"key_from_para\\":[1]}"}}');
```

里面有几个点需要说明一下：

```json
"target":{"copy_para":[0]}
```

`target`指的是 `B:score/trainee/all-subject:1`，`copy_para` 指的是`B:score/trainee/subject:1`的 para 的哪个部分， 还记得吗，这个para的形式是 “学号/学科”。整个的意思是总成绩需要记录到 `B:score/trainee/all-subject:1|0|学号` 对应的`Instance`上。

```json
"executor":{"protocol":"builtIn","url":"sum","settings":"{\\"key_from_para\\":[1]}"}
```

- **Nature 要点**：sum 内置执行器的作用是将上游 context 的值和下游的上一个版本的 content 中的 total 值进行相加并形成新版本的 total 值

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

