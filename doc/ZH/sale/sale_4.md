# 销售额top

这是 Nature 最难解决的问题之一，我在上面花了很长时间，不过我花这么长时间就是为了节省您的时间，所以在这一小节里，您还可以继续享受到“无码”乐趣。

在这部分内容里我们还是用秒为单位进行统计，为了能够更好的理解这部分内容，您可以把统计单位由秒想象成天，并且一天有百万以上的订单需要处理。在这个基础上我们再来想如何算出销售额统计问题。

## 定义统计任务

我们先来看第一组配置：

```mssql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/money/second_tag', 'top of money task' , 1, '', '', '{"cache_saved":true}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/item/money/second:1', 'B:sale/money/second_tag:1', '{"target":{"append_para":[0,1],"context_name":"(time)"}}');
```

配置里没有新鲜元素，只是依据秒销售额数据生成了新的秒统计任务。我们之前定义过一个 `sale/item/money/tag_second` 元数据，两者的区别在于：先前的是最对给定的商品ID，而这里是针对所有商品的。

- **Nature 要点**：对于秒内所有商品的统计我们其实可以直接用`sale/item/money/second`来驱动，之所以用 `second_tag` 来驱动是因为同一目标数据 `sale/item/money/second` 可能会驱动多次，如果换做天为单位进行，可能会被驱动成千上万次。我们将会看到下面有一个比较恐怖的配置，所以多次驱动会无谓的浪费很多资源，能避免尽量避免，而上面的配置则可以有效避免这一问题。

另外说一点：上面这个关系中的 `sale/item/money/second` 完全可以换成 `sale/item/money/tag_second` 因为它们的实例除了 `Meta` 之外 para 是完全相同的。

## 销售额 Top

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/money/secondTop', 'top of money' , 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('L', 'sale/money/secondTopLooper', 'top looper' , 1, '', '', '{"multi_meta":["B:sale/money/secondTop:1"], "only_one":true}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/money/second_tag:1', 'L:sale/money/secondTopLooper:1', '{
"filter_before":[
    {"protocol":"builtIn","url":"task-checker","settings":"{\\"key_gt\\":\\"B:sale/item/money:1|0\\",\\"key_lt\\":\\"B:sale/item/money:1|1\\",\\"time_part\\":[0,1]}"},
    {"protocol":"builtIn","url":"task-checker","settings":"{\\"key_gt\\":\\"B:sale/item/money/tag_second:1|0|(time)/\\",\\"key_lt\\":\\"B:sale/item/money/tag_second:1|0|(time)0\\"}"},
    {"protocol":"builtIn","url":"task-checker","settings":"{\\"key_gt\\":\\"B:sale/item/money/second:1|0|(time)/\\",\\"key_lt\\":\\"B:sale/item/money/second:1|0|(time)0\\",\\"time_part\\":[0,1]}"},
    {"protocol":"builtIn","url":"instance-loader","settings":"{\\"key_gt\\":\\"B:sale/item/money/second:1|0|(time)/\\",\\"key_lt\\":\\"B:sale/item/money/second:1|0|(time)0\\",\\"page_size\\":1,\\"filters\\":[{\\"protocol\\":\\"builtIn\\",\\"url\\":\\"para_as_key\\",\\"settings\\":\\"{\\\\\\"plain\\\\\\":true,\\\\\\"part\\\\\\":[2]}\\"}]}"}
],"delay_on_para":[2,1],"executor":{"protocol":"builtIn","url":"merge","settings":"{\\"key\\":\\"Content\\",\\"sum_all\\":true,\\"top\\":{\\"MaxTop\\":1}}"}}');
```

元数据 `secondTop` 用于存放我们最终的统计结果

- **Nature 要点**：`secondTopLooper` 是一种新型的元数据：`MetaType::Loop`。Loop 类型的引入主要是为了应对一次分批统计问题，百万以上的数据是不能一次加载处理的。Loop 只是个过渡型元数据，其目标元数据需要用 `multi_meta`属性给出。
- 为了配合 Loop 使用，Nature 提供了 instance-loader 内置执行器。





第一个 task_checker 用于保障**创建时间**范围内的任务都完成了

对于第二个task_checker 我们就不用再用创建时间来约束了，因为一步情况下，任务很可能被分散到不同的时间段内完成了，这时候我们只能依赖于task_key。



## 回顾

我们相对完整的演示了一些统计的关键应用情景，在此期间您可以看到除了数据格式转换需要用到代码外，其它问题我们全都是用内置执行器来解决的。而且在整个示例里我们只用了一次外部代码转换，其余的转换也是通过内置执行器来完成的。我不否认这些内置执行器是为构建演示而创建的，但如果您仔细评阅这些内置执行器的说明，您会发现它们是通用的，一个很好的例子就是 merge 内置执行器被用在了三个不同的地方。

我想说的是这些内置执行器加上这种处理模式可以真正的节省了您的代码，而不是仅能于我设定的固定场景。也就是说 Nature 要解决的是真正的通用性问题，这会为大数据处理的标准化、简单化和规范化提供了基础保障并降低大数据的技术门槛。