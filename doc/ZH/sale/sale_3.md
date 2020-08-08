# 销量统计和销售额统计

在上一节中我们生成了以时间为单位的区间统计任务，考虑到一个区间内的数据量有可能非常的大，比如以月为单位，此时我们将需要一些技巧了。对于这些技巧的支持不是 Nature 本身具有的，而是因为其普遍性，Nature 就之提炼到 builtin 中，以方便大家的使用。我们来看一下：

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/money/second', 'second summary of money' , 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/item/count/second', 'second summary of count' , 1, '', '', '');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/item/count/tag_second:1', 'B:sale/item/count/second:1', '{"filter_before":[{"protocol":"builtIn","url":"instance-loader","settings":"{\\"key_gt\\":\\"B:sale/item/count:1|0|(item)/\\",\\"key_lt\\":\\"B:sale/item/count:1|0|(item)0\\",\\"time_part\\":[0,1]}"}],"delay_on_para":[2,1],"executor":{"protocol":"builtIn","url":"merge"}}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/item/money/tag_second:1', 'B:sale/item/money/second:1', '{"filter_before":[{"protocol":"builtIn","url":"instance-loader","settings":"{\\"key_gt\\":\\"B:sale/item/money:1|0|(item)/\\",\\"key_lt\\":\\"B:sale/item/money:1|0|(item)0\\",\\"time_part\\":[0,1]}"}],"delay_on_para":[2,1],"executor":{"protocol":"builtIn","url":"merge"}}');
```

我们一开始先定义了单品的两个统计指标一个是销量一个是销售额。两个都是以秒为统计单位。然后定义了两个`关系`，分别统计两个指标。这两个关系的 settings 有点复杂，我们只需说明其中的一个就好，因为两个几乎一样。

- **Nature 要点**："delay_on_para":[2,1] 是说该转换执行器需要延迟2秒后运行。是在哪个基础上延迟呢？是在上游 para [1] 的时间基础上延迟。为什么要延迟？因为如果我们在 tag_second 创建之后立马执行，则可能统计不到当前秒内后进入的数据，所以要等待当前要统计的时间完全结束后才能统计。
- **Nature 要点**：[merge](https://github.com/llxxbb/Nature/blob/master/doc/ZH/help/built-in.md) 我们有一次见到了这个 builtin. 只不过相较于之前，这里使用了更为高效的方式来同时对一批数据进行求和。至于这批数据是怎么来的，请看下面的要点。
- **Nature 要点**：[instance-loader](https://github.com/llxxbb/Nature/blob/master/doc/ZH/help/built-in.md)  加载用于统计的批量 Instance 数据。注意 (item)/ 和(item)0 用于限定哪个商品。其中（item）在运行时很会被替换掉，因为[上一节](sale_2.md)在sys_context 中指定了 para.dynamic.

虽然 settings 比较复杂，但我们不用写一行代码就可以完成数据团队才可以完成的事。让我们运行程序

```shell
nature.exe
retry.exe
cargo.exe test --package nature-demo --lib sale_statistics::sale_statistics_test
```

结果类似于下面的数据：

| ins_key                                                | sys_context |
| ------------------------------------------------------ | ----------- |
| B:sale/item/money/second:1\|0\|1596367993/1596367994/3 | 11          |
| B:sale/item/count/second:1\|0\|1596367993/1596367994/3 | 2           |

至于 money 为什么不是12 ，大家可以在 sale_statistics_test 的提交代码中找一下答案。

