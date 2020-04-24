# 出库

当订单支付完成后，我们就需要履行合同了。第一步就是出库。我们假设库房管理系统已经存在且比较老旧，运行缓慢，不能直接和Nature进行通信。为了使它能够和Nature能够进行通讯，库房的开发工程师封装了一个中间层并将它部署到库房里。因为库房是一个独立的系统，所以我们就不需要库房相关的`Meta`定义了。

我们在这里假设库房管理系统与Nature的通讯往往要超时，所以我们在本示例里采用一种新的机制来面对这个问题：回调。

## 一些限制说明

在真实的情况中，一个订单可能包含不同的商品，而这些商品也可能分布在不同的库房中。一般情况下每个库房的商品都需要单独跟踪。本示例为了简单起见，假定所有的商品都在同一个库房里。

## 定义`Relation`

只要将订单下传到库房管理系统，我们就认为订单正在打包了。

```mysql
-- orderState:paid --> orderState:package
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/orderState:1', 'B:sale/orderState:1', '{"selector":{"state_all":["paid"]},"executor":{"protocol":"http","url":"http://localhost:8082/send_to_warehouse"},"target":{"states":{"add":["package"]}}}');
```

### Nature 要点

`Protocol::http`: Nature 可以通过Http协议与外部的`executor`进行通讯。

## 处理流程示意图

```mermaid
graph LR
	order:paid-->send[出库申请]
	send-->wh[出库处理]
	wh-->order:outbound	
```

## 实现`executor`

下面这个`executor`的实现主要是将订单信息下传到库房：

```rust
fn send_to_warehouse(para: Json<ConverterParameter>) -> HttpResponse {
    thread::spawn(move || send_to_warehouse_thread(para.0));
    // 让Nature等待60s,如果60s内没有响应，Nature将会重试。
    HttpResponse::Ok().json(ConverterReturned::Delay(60))
}

fn send_to_warehouse_thread(para: ConverterParameter) {
    // TODO 将订单下传给库房管理系统。
    // 等待 50ms， 以模拟上面的下传操作时间。
    thread::sleep(Duration::new(0, 50000));
    // 返回库房的处理结果
    let rtn = DelayedInstances {
        task_id: para.task_id,
        result: ConverterReturned::Instances(vec![para.from]),
    };
    let rtn = CLIENT.post(&*NATURE_CALLBACK_ADDRESS).json(&rtn).send();
    let text: String = rtn.unwrap().text().unwrap();
    if text.contains("Err") {
        error!("{}", text);
    } else {
        debug!("warehouse business processed!")
    }
}
```

上面的代码并没有写出业务逻辑来，真正的业务逻辑需要在新起的线程里异步处理。这里只是给出了如何和Nature进行异步通信的方法。

### Nature 要点

`callback`：`executor`可以异步执行一个需要长时间运行的任务，在这种情况下，`executor`需要立即返回`ConverterReturned::Delay(seconds)` 给Nature，此返回值的意思是，挂起当前的处理并等待通知，如在等待指定的时间内还没有反馈，则进行重试,

当`executor`处理完后需要将正式的结果通过`DelayedInstances` 来告知Nature 而不是`ConverterReturned`。并且`DelayedInstances.task_id` 的值一定是`para.task_id`的值，Nature 可以通过这个 task_id 来唤起挂起的任务。

## 将出库信息反馈给Nature

接收了出库申请后，库房管理人员或机器人要依据订单地内容进行拣货和打包和出库。此时中间层应该通知Nature 改变订单地状态，以驱动后面的流程。示例代码如下：

```rust
	let mut instance = Instance::new("/sale/orderState").unwrap();
    instance.id = one_order.id;
    instance.state_version = one_order.state_version + 1;
    instance.states.insert("outbound".to_string());
    let rtn = send_instance(&instance);
```

### Nature 要点

一定要设置`instance.id `为要出库的订单ID，否则Nature 会分配一个新的ID，这将导致订单在系统中无法出库。

`state_version` 必须要在原有的基础上加一，否则会引起冲突，无法处理.

## 与传统开发方式的区别

Nature 能够强有力的对逻辑实现进行肢解，大幅度降低彼此之间的耦合，这样就为基于分布式的异构系统间的业务往来提供了良好的协作平台，即便是老旧的系统仍然可以发挥应有的价值。