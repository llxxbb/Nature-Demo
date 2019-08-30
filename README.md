# A concrete example
At here we would build an Online-Shop based on Nature.  The project will involves order, pay, warehouse and delivery domain. Don't worry about the complexity, we start at simple first, then step by step to achieve the final target. 

Nature have provide all implement for this demo. you will find all of them in the following projects.

- [test entry](https://github.com/llxxbb/Nature-Demo)
- [common defines](https://github.com/llxxbb/Nature-Demo-Common)
- [converter](https://github.com/llxxbb/Nature-Demo-Converter)

## How to read it

If you are the first time to know Nature,  It's best to read it from top to bottom.

In the whole demo description. there are some sections titled with **"Nature key points"** that would mind your attention how to do the thing in Nature way.

## Now let‘s begin

[prepare](doc/prepare.md)

[generate order](doc/order-generate.md)

pay

outbound

[delivery](doc/delivery.md)

[Q&A](doc/q&a.md)







###### ![process flow](doc/processing_flow.png)

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

![how](doc/how.png)

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







## Unfinished

When there is a `Order` we want to generate an `OrderStatus` and marked with `new`







## runtime

多个库房的问题

多次中转的问题

