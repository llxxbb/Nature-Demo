# plan for demo

## create order

explanation following:

```
{"is_empty_content":true}
```

## pay for an order

use the upstream instance and last target status.



## Define `converter`

When we input an `Order` from outside, we set a `new` state for this order by converter. Execute the following sql please:

```sqlite
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('/B/sale/order:1', '/B/sale/orderState:1', '{"executor":[{"protocol":"LocalRust","url":"nature_demo_converter.dll:order_new","proportion":1}],"use_upstream_id":true,"target_states":{"add":["new"]}}');
```

Let's see some explanation:

| field     | value description                                            |
| --------- | ------------------------------------------------------------ |
| from_meta | The `order` defined in `meta` , the form is [full_key]:[version] |
| to_meta   | `orderState` defined in `meta` , the form is [full_key]:[version] |
| settings  | A `JSON` string for converter's setting. It's value described in following table |

Converter settings

| field           | value description                                            |
| --------------- | ------------------------------------------------------------ |
| executor        | Who will do the convert job, it's a list. The following table show the detail for it's item. |
| use_upstream_id | If this is set to "true", the `orderState` instance's id will use `order` instance's id. |
| target_states   | after convert Nature will add and or remove the states which target_states defined. |

Executor settings: 

| field      | value description                                            |
| ---------- | ------------------------------------------------------------ |
| protocol   | how to communicate with the executor: `LocalRust` or `http`, to simplify this demo, we use `LocalRust` |
| url        | where to find the executor                                   |
| proportion | weight value among the executor list. high weight will get high chance to process the job. |

### Nature key points

**`use_upstream_id`** property will be convenient for state data and it can only used to **state data**, because converter can return many **normal data**, the same id would make them conflict.

Through the same id, you will get the normal data and state data directly, do not need a foreign key be translated like relation database does. 

## refund



## unfinished

###### ![process flow](processing_flow.png)

## plan goals

This is the first step for manager, Let list what data we wanted.

![plan goals](doc/plan_goals.png)

All this must defined in Nature. otherwise Nature will refuse to accept it. Don't be afraid of the class diagram, you need not to write any code, just fill these goals to Nature DB's table: `meta`.  I had written the sql for you

```sqlite
INSERT INTO meta ("full_key",description,version,states,fields) VALUES
('/B/Sale/Order',NULL,1,NULL,NULL),
('/B/Sale/OrderStatus',NULL,1,'new,payed,stock removing,shipping,finished',NULL),
('/B/Finance/Order/Payment',NULL,1,NULL,NULL),
('/B/Warehouse/ReleaseApplication',NULL,1,NULL,NULL),
('/B/Warehouse/OutboundOrder',NULL,1,NULL,NULL),
('/B/Logistics/DeliverApplication',NULL,1,NULL,NULL),
('/B/Logistics/ReceiptForm',NULL,1,NULL,NULL);
```

__Notice:__ I used the form "/B/level1/level2/../level_n/your_goal" for each goal.  The "/B" is `Meta Type` for `Businuss`, this is must be the first part of the `full_key`. And the "level1" to "level_n" are used to organize you goals, they are important for a great deal of goals.

__Notice:__  I specified status field for the `OrderStatus` goal, it is the only one for this example.

## Specify how and who achieve the goals

The second step is design path from one goal to another, let's see:

![how](how.png)

I drew the picture intent to make you understand easily. in actually the data makes up this picture comes from another table: `one_step_flow`. Let's see:

```sqlite
INSERT INTO one_step_flow
(from_meta, from_version, to_meta, to_version, settings)
VALUES('/B/Sale/Order', 1, '/B/Sale/OrderStatus', 1, '{"executor":[{"protocol":"LocalRust","url":"nature_integrate_test_converter.dll:rtn_one","proportion":1}]}'),
('/B/multi_downstream/from', 1, '/B/multi_downstream/toA', 1, '{"executor":[{"protocol":"LocalRust","url":"local://multi_downstream","proportion":1}]}'),
('/B/multi_downstream/from', 1, '/B/multi_downstream/toB', 1, '{"executor":[{"protocol":"LocalRust","url":"local://multi_downstream","proportion":1}]}');

```

The `from_meta`, `from_version`, `to_meta`, `to_version` represent the arrow's direction on the picture. The settings is little complex. It's a [JSON object](../Nature/doc/help/reference.md#settings)







Just like the table name, each row only flow one step. and we can connect the rows to the picture above.







## runtime

多个库房的问题

多次中转的问题