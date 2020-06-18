# 多个库房

### 多个库房怎么玩？

Nature 建议的方法：在`订单状态`和`出库申请`间添加一个`订单拆分单`，以库房为维度进行订单拆分。这样**一个事务ID会变成多个事务ID**，后续流程如物流、配送等自此以后不能再使用订单的ID，而是用拆分单的ID。

这里有个问题要解决：如何标记拆分单该由哪个库房生产以及如何触发相应的处理呢？

- 可能的玩法：将库房相关的参数放到 `出库申请.content` 中，程序员在下一节点编程提取并处理。
- Nature 推荐的玩法：将库房相关的参数放到 `出库申请.context`中，这样做的好处是我们可以以非编程的方式控制流程。举例来说，我们现在用的是自建库房，现在要扩大规模，但为了节省成本，我们选择了业务外包，而外包的库房有些状态是无法跟踪的，所以后续流程是不一样的。这时候我们只需在`instance.context`增加类似于“warehouse.isOuter”的内容，便可以通过 Nature 的上下文选择技术以非编程方式进行流程控制，请参考 [relation.md](https://github.com/llxxbb/Nature/blob/master/doc/ZH/help/relation.md)。

为了简单起见，此演示只演示用到的技术，流程可能不具有实用价值。运行本示例前请用 demo-multi-warehouse.sql 进行数据初始化。

## 建立订单和库房的元数据

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'order', '', 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'warehouse/self', '', 1, '', '', '');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'warehouse/third', '', 1, '', '', '');
```

我们需要创建三个元数据，一个用于订单，一个用于自建库房，一个是第三方库房。注意：这里的订单和商城 Demo 不一样，这里是简化版的订单。

下面我们来定义流程：

```mysql
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:order:1', 'B:warehouse/self:1', '{"selector":{"context_all":["self"]}}');

INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:order:1', 'B:warehouse/third:1', '{"selector":{"context_all":["third"]}}');
```

这里我们会看到之前没有使用过的新的 `selector`: context_all。其作用是订单的上下文中如果有 “self” 就会创建 `warehouse/self` 实例， 如果订单上下文中如果含有 “third” 就会生成 `warehouse/third` 实例。

订单上下文是可以通过 `Instance.context` 属性进行设置的。具体请看示例代码：nature-demo::multi_warehouse::multi_warehouse

- **Nature 要点**：Nature 的上下文选择器只对`上下文`的 key 进行选择。因为`上下文`的 Value 是用户自定义内容，为了减少复杂性及从性能上的考量，不对其进行选择。
- **Nature 要点**：关系里没有指定`执行器`，所以这两个关系的下游数据是 Nature 自动生成的。我们只需要输入订单就好。

让我们看下运行效果，启动：

```shell
- nature.exe
- cargo.exe test --color=always --package nature-demo --lib multi_warehouse::multi_warehouse
```

在 `multi_warehouse` 里一共提交了 A、B、C、D 四个订单，A的上下文是 self， B的上下文是 third， C的上下文 是 self 和 third.  D没有上下文。

运行后的数据如下：

| ins_key                                                 | content | context                         | from_key                                         |
| ------------------------------------------------------- | ------- | ------------------------------- | ------------------------------------------------ |
| B:order:1\|38b047cd1ef153bdd636426fb9dd428e\|           | "D"     |                                 |                                                  |
| B:order:1\|74c5d1d825d15cac88330edb45268624\|           | "C"     | {"self":"self","third":"third"} |                                                  |
| B:order:1\|a75366d1b120cb8b633d05fd2eff3426\|           | "B"     | {"third":"third"}               |                                                  |
| B:order:1\|fb7ca936097235b790390b68d1fba90c\|           | "A"     | {"self":"self"}                 |                                                  |
| B:warehouse/self:1\|13e769c238d944909e349b9ca51bdc8d\|  |         |                                 | B:order:1\|fb7ca936097235b790390b68d1fba90c\|\|0 |
| B:warehouse/self:1\|70a8d67d64bd2b86253d7c4452056685\|  |         |                                 | B:order:1\|74c5d1d825d15cac88330edb45268624\|\|0 |
| B:warehouse/third:1\|8aa0337559cd5091d83ce40d3442a76d\| |         |                                 | B:order:1\|74c5d1d825d15cac88330edb45268624\|\|0 |
| B:warehouse/third:1\|d264929013427f9b9739abb87e9d7ff2\| |         |                                 | B:order:1\|a75366d1b120cb8b633d05fd2eff3426\|\|0 |

- **Nature 要点**：在真实情况下，C订单的上下文是不能同时设置两个库房的，这里只是演示`选择器`的工作方式。这种使用方式在其它场景下可能会非常有用，如对用户的兴趣进行分类统计时，一条上游数据就需要同时匹配多条下游数据。