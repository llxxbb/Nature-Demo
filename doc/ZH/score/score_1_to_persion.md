# 全员成绩单->个人成绩

## 成绩单

在本示例里，我们采用批量的方式将学生的成绩输入到 Nature.。输入的内容是一个二维数组，示例如下：

```rust
let mut content: Vec<KV> = vec![];
content.push(KV::new("class5/name1/subject2", 33));
content.push(KV::new("class5/name3/subject2", 76));
content.push(KV::new("class5/name4/subject2", 38));
content.push(KV::new("class5/name5/subject2", 65));
...
```

第一列说明了班级，学员和学科之间的关系，第二列则是成绩。

数据输入的 `Meta` 定义如下：

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/table', 'store original score data', 1, '', '', '');
```

在demo 运行后，Nature 会将上面的数据存到`Instance`数据表中，其数据会是下面的样子：

| ins_key                                             | content                                                      |
| --------------------------------------------------- | ------------------------------------------------------------ |
| B:score/table:1\|f4c850bb749bd1bff135b578e428492e\| | [{"key":"class5/name1/subject2","value":33},{"key":"class5/name3/subject2","value":76},{"key":"class5/name4/subject2","value":38},{"key":"class5/name5/subject2","value":65}] |

`ins_key`的结构是 meta|id|para 因为我们没有指定 id, Nature会自动取 hash 值作为 id.

## 个人学科数据

接下来我们想要做的事情是，将上面这个成绩单拆分成一条一条的个人学科数据。以方便个人成绩查询，且杜绝学员之间相互串查。

个人学科成绩的 `Meta` 定义如下：

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/trainee/subject', 'person original score', 1, '', '', '{"master":"B:score/table:1"}');
```

### Nature 要点

统计一定要构建原子数据，在原子数据的基础上再构建复合数据，这样可以改善流式计算的负荷。此例中个人学科成绩就是原子数据，可以用于后面的各种总成绩，排名等。

## 定义关系和处理程序

有了上面的`成绩单`和`个人学科成绩`两个**元数据**后我们就可以编织他们的关系了，并指定处理程序来完成转换工作。

```mysql
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:score/table:1', 'B:score/trainee/subject:1', '{"executor":{"protocol":"builtIn","url":"scatter"}, "filter_after":[{"protocol":"http","url":"http://127.0.0.1:8082/add_score"},{"protocol":"localRust","url":"nature_demo_executor:name_to_id"}]}');
```

## `scatter` 内置执行器

我们先看 executor 的定义 ：

```json
{"executor":{"protocol":"builtIn","url":"scatter"}
```

首先他是`builtIn`的也就是说，我们不需要开发这个功能，直接拿来用就好了。他的工作方式其实很简单，就是

将`成绩单`中的每一个数据形成一条独立的`个人学科成绩`。并将 `成绩单`数据的第一列 等作为`个人学科成绩`数据的`para` 而成绩放到数据的`content`中。

运行后我们在`Instance`数据表中应该看到下面的数据，

| ins_key                                             | content |
| --------------------------------------------------- | ------- |
| B:score/trainee/subject:1\|0\|class5/name1/subject2 | 33      |
| B:score/trainee/subject:1\|0\|class5/name3/subject2 | 76      |
| B:score/trainee/subject:1\|0\|class5/name4/subject2 | 38      |
| B:score/trainee/subject:1\|0\|class5/name5/subject2 | 65      |

我们可以看到上面的一个`成绩单`被拆成了4条`个人学科成绩`，而且`成绩单`的两列分别放到的 `int_key.para` 和 content位置。这里需要注意的是，**如果指定了para 而没有指定 id， Nature则会将id自动置为0，而不再是一个hash值**，所以这里你看到了 meta|0|para 这种形式。

## filter_after

然而当我们运行完Demo实际看到的却是下面的数据：

| ins_key                                    | content |
| ------------------------------------------ | ------- |
| B:score/trainee/subject:1\|0\|001/subject2 | 37      |
| B:score/trainee/subject:1\|0\|003/subject2 | 80      |
| B:score/trainee/subject:1\|0\|004/subject2 | 42      |
| B:score/trainee/subject:1\|0\|005/subject2 | 69      |

这是因为我们在 `Relation`中额外定义了`后置过滤器`相关的内容:

```json
"filter_after":[{"protocol":"http","url":"http://127.0.0.1:8082/add_score"},{"protocol":"localRust","url":"nature_demo_executor:name_to_id"}]
```

`后置过滤器`的作用是在`执行器`执行完后Nature 保存数据前，对数据进行一些修正。这里定义了两个`后置过滤器`，一个是基于http 方式调用，用于给所有参加学科2考试的人补分；一个是基于静态链接库调用，用于将 `班级\姓名`替换成学号。 这两个过滤器的实现请自行查看源代码，这里就不贴出来了。

### Nature 要点

我们完全可以定义多个`Relation`来完成这个工作而不用学习一个新的内容，但这里有两点需要说明：

- 性能：上面的 4 条数据是一次性被`后置过滤器`处理的，如果我们改用`Relation`的 `执行器` 来完成，对应的则需要定义两个`执行器`，而每个`执行器`只能一条一条地处理数据，这样我们就需要8次 IO 才能完成这个工作。性能不可同日而语。
- `过滤器`一般是技术处理语义，而`Relation`主导的是业务语义，我还是不希望你的老板去理解这么一个技术性的“业务概念”。这条说明也同样适用于`前置过滤器`

## 运行Demo

- 启动 nature.exe,  
- 启动  nature_demo_executor_restful.exe
- 运行 nature-demo::score::score_test 
- 查看`instance`数据表中的数据以验证结果，其结果示例已在上面给出了。