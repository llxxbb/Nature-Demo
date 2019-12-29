## 签收

这是订单处理流程的最后一步：签收。但是物流公司并不主动将签收信号反馈给我们，我们需要用户登录到我们的系统上来，然后点击签收按钮，但是他们中的很多人根本不这么做。那么我们怎么完成这些订单呢?一个可行的方法是，我们等待两个星期，如果这期间没有投诉，我们就自动签收它。

为了我们的时间着想，示例中我们将两星期压缩到1s，这样你就能够很快的看到结果。



## 定义`meta`

```sqlite
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'sale/orderSign', 'order finished', 1, '', '', '{}');
```

## 定义converter

```sqlite
-- orderState:dispatching --> orderSign
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/orderState:1', 'B:sale/orderSign:1', '{"delay":1,"selector":{"source_state_include":["dispatching"]}, "executor":[{"protocol":"localRust","url":"nature_demo_converter.dll:auto_sign"}]}');

-- orderSign --> orderState:signed
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:sale/orderSign:1', 'B:sale/orderState:1', '{"target_states":{"add":["signed"]}}');
```

### Nature 要点

`delay`：这个属性告诉Nature 不要让执行器立即执行任务，而是要等待指定的时间后再执行。

被推迟的任务只能通过`Nature-Retry`项目才能重新执行，所以本示例你需要将它启动起来。