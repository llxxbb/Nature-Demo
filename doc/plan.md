# plan for demo

## Multi-Meta

有了`成绩单`后我们需要有两个维度的统计：学员和学科。我们可以定义两个关系来解决这个问题，但从性能上来讲不是最优的，一是表格数据的多次传递，二是一次扫描就可以得到两个结果而不需要两次扫描。所以我们这里引入了一个新的`Meta`类型:Multi。

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('M', 'score/dimensions', '', 1, '', '', '{"master":"B:score/table:1","multi_meta":["B:score/trainee/subject:1"]}');
```

### Nature 要点

Multi-Meta 的类型用 **M** 来表示。此种类型的`Meta`还需要设置 “multi_meta”配置项，以声明执行器可以生成的`Meta`。这些`Meta` 必须是定义过的。

## `MetaType::Null`

This `converter` does not generate any thing to Nature, the reason is `to_meta` is "**/N:1**", it's `MetaType::Null`.  But why this is usable?  in this demo, we want to notify the warehouse,  and Nature can achieve it **reliably**.  

## Converter settings

use_upstream_id

| field           | value description                                            |
| --------------- | ------------------------------------------------------------ |
| use_upstream_id | If this is set to "true", the `orderState` instance's id will use `order` instance's id. |

### Nature key points

**`use_upstream_id`** property will be convenient for state data and it can only used to **state data**, because converter can return many **normal data**, the same id would make them conflict.

## Define `converter`

| field  | value description                                            |
| ------ | ------------------------------------------------------------ |
| weight | weight value among the executor list. high weight will get high chance to process the job. |



## plan goals

This is the first step for manager, Let list what data we wanted.

![plan goals](doc/plan_goals.png)

All this must defined in Nature. otherwise Nature will refuse to accept it. Don't be afraid of the class diagram, you need not to write any code, just fill these goals to Nature DB's table: `meta`.  I had written the sql for you

```mysql

```

__Notice:__ I used the form "/B/level1/level2/../level_n/your_goal" for each goal.  The "/B" is `Meta Type` for `Businuss`, this is must be the first part of the `full_key`. And the "level1" to "level_n" are used to organize you goals, they are important for a great deal of goals.

__Notice:__  I specified status field for the `OrderStatus` goal, it is the only one for this example.

I drew the picture intent to make you understand easily. in actually the data makes up this picture comes from another table: `one_step_flow`. Let's see:

```mysql
INSERT INTO one_step_flow
(from_meta, from_version, to_meta, to_version, settings)
VALUES('/B/Sale/Order', 1, '/B/Sale/OrderStatus', 1, '{"executor":[{"protocol":"LocalRust","url":"nature_integrate_test_executor.dll:rtn_one","weight":1}]}'),
('/B/multi_downstream/from', 1, '/B/multi_downstream/toA', 1, '{"executor":[{"protocol":"LocalRust","url":"local://multi_downstream","weight":1}]}'),
('/B/multi_downstream/from', 1, '/B/multi_downstream/toB', 1, '{"executor":[{"protocol":"LocalRust","url":"local://multi_downstream","weight":1}]}');

```

The `from_meta`, `from_version`, `to_meta`, `to_version` represent the arrow's direction on the picture. The settings is little complex. It's a [JSON object](../Nature/doc/help/reference.md#settings)







Just like the table name, each row only flow one step. and we can connect the rows to the picture above.







## runtime

多个库房的问题

多次中转的问题