# 定义统计区间

在本示例里我们将使用批量处理模式来解决上一个 demo (学习成绩统计) 中的性能问题。而且这种统计方式**不需要用到状态数据**。

对于一个销量火爆的在线销售系统来讲，业界常规的做法是按时间区间进行统计，这样可以及时了解商品的销量情况。所以我们也按这种方式进行统计，来看下 `meta` 和 `relation` 的定义。

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/money/tag_second', 'time range for second' , 1, '', '', '{"cache_saved":true}');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/count/tag_second', 'time range for second' , 1, '', '', '{"cache_saved":true}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/item/money:1', 'B:sale/item/money/tag_second:1', '{"executor":{"protocol":"builtIn","url":"time_range"}}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/item/count:1', 'B:sale/item/count/tag_second:1', '{"executor":{"protocol":"builtIn","url":"time_range"}}');
```

我们为商品的销量和销售额都配置了一个 `tag_second` 的 `Meta` 用于保存时间区间信息，而这个时间区间是通过[内置执行器](https://github.com/llxxbb/Nature/blob/master/doc/ZH/help/build-in.md)： time_range 来完成的，不需要我们写一行代码。

- **Nature 要点**：`cache_saved` 会 让 Nature 暂时记住已经写入的 `Instance` ，当有新的相同 `Instance` 提交时，Nature 因为知道已经写过了所以自动忽略此次提交。这在大并发请情境下会极大的提升性能。对于本节来讲，同一秒内的多笔数据都会生成同一个 tag_second `Instance`，所以应用`cache_saved` 会显著提高性能。**危险提醒**：这个选项不是必须的，如果用错了反而会有很大的负作用。详细请看：[meta.md](https://github.com/llxxbb/Nature/blob/master/doc/ZH/help/meta.md)
- **Nature 要点**：`time_range`  是一个内置执行器。用于为下游`Instance`自动生成带有时间范围的 `para` 。这里依据上游 `Instance` 的创建时间来确定时间范围。具体请参考[内置执行器](https://github.com/llxxbb/Nature/blob/master/doc/ZH/help/build-in.md)中的 time_range。

让我们执行下面的命令来看一下运行结果：

```shell
nature.exe
cargo.exe test --package nature-demo --lib sale_statistics::sale_statistics_test
```

结果类似于下面的数据：

| ins_key                                                  |
| -------------------------------------------------------- |
| B:sale/item/count/tag_second:1\|0\|1596367993/1596367994 |
| B:sale/item/money/tag_second:1\|0\|1596367993/1596367994 |

我们可以看到 `time_range` 所生成的 para 都已经附加到对应的 `meta` 上了。 其形式是：开始时间/结束时间。现在我们需要进入到下一个环节。