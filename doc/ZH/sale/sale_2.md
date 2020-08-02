# 订单->区间统计任务

在本示例里我们将使用批量处理模式来解决上一个 demo (学习成绩统计) 中的性能问题。而且这中统计方式**不需要用到状态数据**。

我们首先要解决的时批量的边界问题，业界常规的做法是按时间区间进行划分，所以我们也按这种方式进行统计。其大体思路是依据订单的生成时间来界定时间区间并生成对应的数据用于驱动下一环节的统计。我们来看下 `meta` 和 `relation` 的定义。

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/order', 'order', 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/tag_second', 'time range for second' , 1, '', '', '{"cache_saved":true}');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/tag_minute', 'minute time range for minute' , 1, '', '', '{"cache_saved":true}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/order:1', 'B:sale/item/tag_second:1', '{"executor":{"protocol":"builtIn","url":"time_range"}}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/item/tag_second:1', 'B:sale/item/tag_minute:1', '{"executor":{"protocol":"builtIn","url":"time_range","settings":"{\\"on_para\\":true,\\"unit\\":\\"m\\",\\"value\\":5}"}}');
```

在这里我们采用递进的方式进行统计，既：秒销量统计->分销量统计。当然你可以再加上天、周、月甚至是年等统计维度，详细请看[内置执行器](https://github.com/llxxbb/Nature/blob/master/doc/ZH/help/build-in.md)中的 time_range。为了简化起见我们只统计到分钟。下面让我们来关注下这些配置里的新元素。

- **Nature 要点**：`cache_saved` 这个配置的作用是，Nature 在写入 `Instance` 后同时在内存里也缓存一份 `Instance`，当有新的相同 `Instance`生成时，只要 Nature 检测到内存里有这个 `Instance` Nature就不会进行写盘操作了。这在大并发请情境下会极大的提升性能。对于本节来讲，同一秒内可能有好多笔订单，而这些订单都会生成相同的 tag_second `Instance`，`cache_saved` 则告诉 Nature 只写一次就好了。**危险提醒**：这个选项不是必须的，如果用错了反而会有很大的负作用。详细请看：[meta.md](https://github.com/llxxbb/Nature/blob/master/doc/ZH/help/meta.md)
- **Nature 要点**：`time_range`  是一个内置执行器。用于为`Instance`自动生成带有时间范围的 `para` 。请参考[内置执行器](https://github.com/llxxbb/Nature/blob/master/doc/ZH/help/build-in.md)中的 time_range。在本示例里 `time_range`  一共用了两次，第一次用于生成1秒范围的 `tag_second`，第二次是用于生成5分钟范围的 `tag_minute`。需要注意的是，第一次的时间来源于订单的创建时间，而第二次的时间来源与第一次生成的`tag_second.para`。这一点非常重要，如果第二次的时间也来源于`tag_second`的创建时间，则可能造成统计数据的不一致，因为`tag_second`的创建时间是不等于订单的创建时间的。或者用下面的 `relation` 来替代 上面的最后一个 `relation`，既`tag_minute`也是以订单的创建时间来构造，这样就没有问题了。

```mysql
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/order:1', 'B:sale/item/tag_minute:1', '{"executor":{"protocol":"builtIn","url":"time_range","settings":"{\\"unit\\":\\"m\\",\\"value\\":5}"}}');
```

但这是一种不建议的方式，原因如下：

- 失去递进统计的含义，我们需要优先处理最需要的数据，而不是并行处理。
- 因为订单包含很多内容，传递一个订单要比传递一个`tag_second`成本要高。

订单的输入代码请参考 nature-demo::sale_statistics::sale_statistics_test()

让我们执行下面的命令来看一下运行结果：

```shell
nature.exe
cargo.exe test --color=always --package nature-demo --lib sale_statistics::sale_statistics_test
```

结果类似于下面的数据：

| ins_key                                                  | content                                                      | from_key |
| -------------------------------------------------------- | ------------------------------------------------------------ | -------- |
| B:sale/order:1\|3827f37003127855b32ea022daa04cd\|        | {"user_id":123,"price":1000,"items":[{"item":{"id":1,"name":"phone","price":800},"num":1},{"item":{"id":2,"name":"battery","price":100},"num":2}],"address":"a.b.c"} |          |
| B:sale/order:1\|4e7c0395030d2bb06f323d5355a9d957\|       | {"user_id":124,"price":305,"items":[{"item":{"id":3,"name":"cup","price":5},"num":1},{"item":{"id":2,"name":"battery","price":100},"num":3}],"address":"a.b.c"} |          |
| B:sale/order:1\|7a51a15c385f7ca5a9356eef60033b2f\|       | {"user_id":125,"price":7006,"items":[{"item":{"id":1,"name":"phone","price":700},"num":10},{"item":{"id":3,"name":"cup","price":6},"num":1}],"address":"a.b.c"} |          |
| B:sale/item/tag_second:1\|0\|1594449384000/1594449385000 |                                                              |B:sale/order:1\|3827f37003127855b32ea022daa04cd\|\|0|
| B:sale/item/tag_minute:1\|0\|1594449300000/1594449600000 |                                                              |B:sale/item/tag_second:1\|0\|1594449384000/1594449385000\|0|
| B:sale/item/tag_second:1\|0\|1594449387000/1594449388000 |                                                              |B:sale/order:1\|4e7c0395030d2bb06f323d5355a9d957\|\|0|

我们可以看到 `time_range` 所生成的 para 都已经附加到对应的 `meta` 上了。 其形式是：开始时间/结束时间。现在我们需要进入到下一个环节。