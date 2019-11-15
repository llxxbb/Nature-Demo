# A concrete example
At here we would build an Online-Shop based on Nature.  The project will involves order, pay, warehouse and delivery domain. Don't worry about the complexity, we start at simple first, then step by step to achieve the final target. 

Nature have provide all implement for this demo. you will find all of them in the following projects.

- [test entry](https://github.com/llxxbb/Nature-Demo)
- [common defines](https://github.com/llxxbb/Nature-Demo-Common)
- [converter](https://github.com/llxxbb/Nature-Demo-Converter)

For the benefit of the simplicity, here use local-converter to instead of http based converter.

## How to read it

If you are the first time to know Nature,  It's best to read it from top to bottom.

In the whole demo description. there are some sections titled with **"Nature key points"** that would mind your attention how to do the thing in Nature way.

## Let‘s begin

| chapter                                 | digest                                                    | key points                                                   |
| --------------------------------------- | --------------------------------------------------------- | ------------------------------------------------------------ |
| [prepare](doc/prepare.md)               | prepare for the demo                                      | how to run Nature                                            |
| [generate order](doc/order-generate.md) | user commit an order into to Nature                       | `Meta`, master `meta`, define target-state, `Converter`  and how to commit business object to Nature |
| [pay for the bill](doc/pay-the-bill.md) | user can pay many times for the big bill.                 | upstream select, state conflict control                      |
| [stock-out](doc/stock-out.md)           | the warehouse system is slow to process the order's goods | input state instance, callback                               |


The following unfinished yet.

| chapter                     | digest                                                  | key points                      |
| --------------------------- | ------------------------------------------------------- | ------------------------------- |
| [delivery](doc/delivery.md) | collaborate with the third-party                        | parameterization input          |
| signed                      | user received the goods                                 |                                 |
| e-book                      | extend category with need not delivery but can download | context, `meta`                 |
| logistic bill               | one order split into many logistic bill                 | user appointed id,  grey deploy |

[Q&A](doc/q&a.md)



