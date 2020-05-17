# 接收订单

我们假设已经有了一个商城系统，用户在在这个系统里可以选购商品并提交订单。现在我们想借助 Nature 来接管订单的后续处理过程。

**Q**:是否可以将选购商品等这些商城的职能用 Nature 来实现？

**A**:Nature 目前倾向于后端处理，没有前端交互能力，但可以为前端提供数据，即使是提供数据，现在功能上还不完备，如缓存等。

## 外系统提交订单

我们需要将订单数据用 json 提交到 Nature 的这个地址下：`http://localhost:8080/input`，如果成功该接口则会返回一个ID。

Nature 的 json 格式如下：

```rust
{"data":{"meta":"B:sale/order:1","content":"my order detail"}}
```

- `data.meta=“B:sale/order:1”`：说明这是一个订单数据，必须事先在 Nature 中注册，否则 Nature 拒绝接受这个数据。这个下面会讲怎么注册。
- `data.content="abc"`则是订单的内容，请用实际内容替换掉无意义的 abc 就好。

## 在Nature里注册`Meta`：订单

要想让Nature 接受 上面的订单信息输入，我们需要向 meta 数据表里插入下面的数据：

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/order', 'order', 1, '', '', '');
```

**注**：本demo中所用的sql 都可以再 [demo-emall.sql](doc/demo-emall.sql) 中找到。

我们逐一解释一下：

- meta_type='B': 为`Meta`指定类型，B指的是`MetaType::Business`，代表这是一个业务对象，其他类型可参考[meta.md](https://github.com/llxxbb/Nature/blob/master/doc/ZH/help/meta.md)
- meta_key='sale/order' : 为`Meta`的名字，用于区别其他`Meta`。
- description=‘order’：向别人介绍一下这个`Meta`是干什么的，意义是什么等。
- version=1: 每当业务发生变更时，可以通过变更版本号来跟踪业务变化，当遇到这种情况时请不要 `update` 当前的 `Meta` 而是要插入一条新的数据。这种做法是一种兼容方式的变化，因为老的版本并没有消失。

插入后 Nature 就可以接收 `data.meta`  标记为 “B:sale/order:1” 的数据了，**“B:sale/order:1” 实际上就是”meta_type:meta_key:version“的值的表现形式**，Nature 称之为 `meta_string`。

## 查看输入的数据

- 启动 nature.exe
- 运行 nature-demo::emall::emall_test()

打开 instance 数据表，我们会发现多了一条下面的数据：

| ins_key                                           | content                                                      |
| ------------------------------------------------- | ------------------------------------------------------------ |
| B:sale/order:1\|3827f37003127855b32ea022daa04cd\| | {"user_id":123,"price":1000,"items":[{"item":{"id":1,"name":"phone","price":800},"num":1},{"item":{"id":2,"name":"battery","price":100},"num":2}],"address":"a.b.c"} |
- ins_key：用于唯一标记此条数据。器构成为 “meta_string|id|para”。此例中我们没有输入id,Nature会用输入数据的 hash 值来作为此条数据的 ID 这样做的目的是为了追求**幂等**。此例中我们也没有输入 para 所以此条数据尾巴上只有一个“|”
- content 是我们模拟的订单数据，这个数据是 emall_test() 给出的，大家可以自行去看源码。

## 定义订单状态

先结束 nature.exe 的运行，我们继续我们的示例。

这个示例的要点就是要跟踪订单的处理状态。状态数据是不建议直接放到`B:sale/order:1`上的，因为Nature 对数据的每次状态变更都会创建一条新的完整的数据，如果放到`B:sale/order:1`上会造成大量的数据冗余！性能自然也好不到哪里去。

为此我们需要为订单状态单独创建一个`Meta`:

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/orderState', 'order state', 1, 'new|paid|package|outbound|dispatching|signed|canceling|canceled', '', '{"master":"B:sale/order:1"}');
```

- states='new|paid|package|outbound|dispatching|signed|canceling|canceled': 这里定义了我们订单里要用的的状态。“|”说明这些状态**不能共存**，同一时间里只能是其中的一个。具体语法请参考：[使用meta](https://github.com/llxxbb/Nature/blob/master/doc/ZH/help/meta.md)。
- master="B:sale/order:1"：说明 orderState 依附于 order。其作用有两个：
  - orderState  会使用 order的ID作为自己的ID
  - orderState 作为上游驱动下游数据时，Nature 会顺便将 order 数据传递给下游，这样下游就不需要单独再查询一次订单数据了。


## 定义`订单`和`订单状态`之间的关系

要想生成订单状态数据，我们需要建立起订单和订单状态之间的`关系`。请执行下面的sql：

```mysql
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/order:1', 'B:sale/orderState:1', '{"target":{"states":{"add":["new"]}}}');
```

| 字段或属性 | 说明                                                         |
| ---------- | ------------------------------------------------------------ |
| from_meta  | `关系`的起点，为 meta_string                                 |
| to_meta    | `关系`的终点，为 meta_string                                 |
| settings   | 是一个 `JSON` 形式的配置对象，用于对这个`关系`进行一些附加控制，如`执行器`，`过滤器`以及对上下游实例的一些要求等。请参考[使用 Relation](https://github.com/llxxbb/Nature/blob/master/doc/ZH/help/relation.md) |

- **Nature 要点**：在Nature `关系`是有方向的，这个方向说明了数据的流转方向，上面的`关系`定义说明了数据只能从 B:sale/order:1 流向 B:sale/orderState:1。
- target.states.add=["new"]：是说在新生成的数据实例（B:sale/orderState:1）上附加上”new“ 状态。这个语法是数组，也就是说我们可以同时附加多个状态。**注意：这个附加是在上一个版本的状态基础上进行附加的**。对于本例来讲上一版本还不存在，则认为上一状态为“”。

## 运行 Demo 并查看生成的订单状态数据

让我们见证一个魔法时刻

- 启动 nature.exe
- 运行 nature-demo::emall::emall_test()

打开 instance 数据表，我们会发现有类似于下面的数据：

| ins_key                                                | states  | state_version | from_key        |
| ------------------------------------------------------ | ------- | ------------- | --------------- |
| B:sale/orderState:1\|3827f37003127855b32ea022daa04cd\| | ["new"] | 1             | B:sale/order:1\|3827f37003127855b32ea022daa04cd\| |

我们只 `meta` 和 `relation`数据表里加了两条配置数据，神奇的是`instance`数据表里自动生成一条“sale/order”数据。

- **Nature 要点**：当`关系`中的下游`Instance.content`没有意义时，我们就不需要一个明确的`执行器`来完成`关系`要求的数据转换任务，在此种情况下Nature 会为`关系`自动生成一个类型为`auto`的`执行器`，正式这个`执行器`帮助我们生成了上面这条数据。有关使用`执行器`的例子，下面会讲到。

如果仔细看，你会发现上面这条数据的`ins_key` 和 `from_key` 中的 ID 是相同的，这是“B:sale/orderState:1”对应的`Meta.master`设置在起作用。

* **Nature 要点** ： 在Nature里多个不同元数据实例共享相同的 ID 是一种推荐的做法，这个ID 可以被视为一个**事务ID**。既**用一个ID就可以把相关的所有数据提取出来**。这要比传统数据表依赖于外键转换才能提取数据有效率的多，而且还减少了关系数据的维护。更重要的是这种处理方式**减少了保障数据一致性的技术复杂度**。
* **Nature 要点**：`from_key` 是 Nature 自动添加的，可用于追溯数据，这会为排查问题提供极大的方便。

同时我们发现`target.states.add=["new"]`也发挥了作用：这条数据的`states`被设置成`["new"]`了。

- **Nature 要点**：对于状态数据，传统处理方式一般是采用update的方式将新状态覆盖到旧状态上，而要跟踪这些变化需要额外的措施来保障，复杂度较高。而Nature 已经将这种机制内建，会大幅度简化状态数据的处理。**Nature 绝不修改、删除数据**，状态的每次变化都会形成新的数据，并用递增的版本号进行标记，这样所有的数据都可以被**追溯**。
- **Nature 要点**：将订单数据和状态数据分开存储，相较于传统方式的合并存储，看似复杂化了设计，但对Nature的使用者来讲几乎无感知的，甚至更简单，拿本示例来讲程序员无需对关心状态数据的设计、存储及操作相关内容；而且分开后，不同数据的使用目的会更加明确，有利于流程梳理；同时这种方式对 Nature 来讲还优化了存储和数据传输效率，所以Nature 是非常提倡将基本信息和状态分开这种做法的。
- **Nature 要点**：在本示例的源码中，我们多次提交了相同的订单数据，Nature 会返回相同的ID，也就是说 **Nature 是幂等的**。
