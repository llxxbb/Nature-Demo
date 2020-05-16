## 签收

这是订单处理流程的最后一步：签收。但是物流公司并不主动将签收信号反馈给我们，我们需要用户登录到我们的系统上来，然后点击签收按钮，但是他们中的很多人根本不这么做。那么我们怎么完成这些订单呢?一个可行的方法是，我们等待两个星期，如果这期间没有投诉，我们就自动签收它。

为了我们的时间着想，示例中我们将两星期压缩到1s，这样你就能够很快的看到结果。



## 定义`meta`

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/orderSign', 'order finished', 1, '', '', '{}');
```

## 定义`Relation`

```mysql
-- orderState:dispatching --> orderSign
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/orderState:1', 'B:sale/orderSign:1', '{"delay":1,"selector":{"source_state_include":["dispatching"]}, "executor":{"protocol":"localRust","url":"nature_demo_executor:auto_sign"}}');

-- orderSign --> orderState:signed
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/orderSign:1', 'B:sale/orderState:1', '{"target":{"states":{"add":["signed"]}}}');
```

### Nature 要点

`delay`：这个属性告诉Nature 不要让执行器立即执行任务，而是要等待指定的时间后再执行。

被推迟的任务只能通过`Nature-Retry`项目才能重新执行，所以本示例你需要将它启动起来。



## 与传统开发方式的区别

- **谁在主导数据类型**：传统方式下数据类型是在代码里定义的，而在 Nature 里 `Meta` 是主导者，她贯穿所有的流程处理。一个是编程实现，一个是配置实现，优劣自现。

- **状态控制**：状态控制对业务逻辑来讲是最为复杂的部分之一，一般需要有更技能的人员进行支持，但 Nature 对状态进行了强大的支撑，只需要配置配置就完事了。

- **设计时对运行时的约束作用**：传统设计方式，只能让大家在思想上达成一致，设计没有直接的支配能力，必须借助实施人员来翻译，所以设计的好，结果并不一定好。对于 Nature 来讲，**我们不应当将`Meta`和`Relation`仅仅当做配置，而更应该认为是一种设计**，她能够对业务流转起到决定性的直接的支配作用。

- **业务变更**：传统方式下的代码实际上设计时和运行时的统一体，两者无法分离；因为这种耦合，设计变更一般比较困难，在一些关键的点上甚至不敢变更。但Nature 将设计时和运行时完全分离，变更起来就没有这些问题。而且设计时的变更是有版本的，这就不会对既有的设计产生任何不良影响。

- **简易性，稳定性，可维护性，可扩展性**：虽然这里只讲了本示例的第一步，后续更多的是为了介绍这里没有介绍的Nature的其他特性而展开，但模式基本上是一致的。Nature 的这种模式，可以看成是一种更高级别的AOP（Aspect Oriented Programming），Nature 利用这个 AOP 做了很多技术上的工作，如幂等、状态数据操作、数据一致性保障等，甚至可以规范行业上的一项操作（如后面会讲到用于统计的通用的 sum `执行器`）。**对于一个传统业务系统来讲，技术性代码和业务性代码的比例应该符合帕累托的80/20法则**，而 Nature将这些技术性的代码用统一的方式实现了，也就是说开发人员的工作变得简单了，简单了稳定性和可维护性也就上来了，这就为程序员增产提效创造了有利条件。更进一步，Nature 将业务系统间的链接都砍断，将控制完全打断

  



Demo中有反复提交的演示，以说明Nature 是幂等的。不仅如此Nature 还会为你默默的处理好像重试、最终一致性等问题，大幅度减少传统业务系统的技术复杂度，使开发人员更专注于业务的实现。

Nature 对业务系统简化的不仅仅是技术复杂性，对业务逻辑的简化也是比较显著。本示例中业务系统只是提交一个 order 的`Instance`到 Nature， Nature 就自动生成了orderState 并维护了它的状态。状态处理在业务系统中是非常难以维护的业务逻辑，尤其是业务一致性保障及状态跟踪。而Nature 几乎不用写代码就可以实现复杂的状态处理。

业务系统越简单就越不容易出错，也就越健壮、稳定。