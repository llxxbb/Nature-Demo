# Statistics

After paid we want to make statistics for the products, and analysis them by multi-dimensions, but we are lazy to writing the code. Luckily Nature can do that for you.

## Define `meta`

```sqlite
INSERT INTO meta
(full_key, description, version, states, fields, config)
VALUES('/P/statistics/productConsume/task', 'total sold every hour', 1, '', '', '{}');

INSERT INTO meta
(full_key, description, version, states, fields, config)
VALUES('/B/statistics/productConsume/total/minute', 'total sold every minute', 1, '', '', '{}');

INSERT INTO meta
(full_key, description, version, states, fields, config)
VALUES('/B/statistics/productConsume/sex/minute', 'total sold every minute', 1, '', '', '{}');

INSERT INTO meta
(full_key, description, version, states, fields, config)
VALUES('/B/statistics/productConsume/ageRange/minute', 'total sold every minute', 1, '', '', '{}');

INSERT INTO meta
(full_key, description, version, states, fields, config)
VALUES('/B/statistics/productConsume/total/hour', 'total sold every minute', 1, '', '', '{}');

INSERT INTO meta
(full_key, description, version, states, fields, config)
VALUES('/B/statistics/productConsume/sex/hour', 'total sold every minute', 1, '', '', '{}');

INSERT INTO meta
(full_key, description, version, states, fields, config)
VALUES('/B/statistics/productConsume/ageRange/hour', 'total sold every minute', 1, '', '', '{}');
```

### how to make statistics

If we we increase the counter for every order use `state-instance`, there would be many conflicts for high parallel process, and another question is that we would generated great volume of `state-instace`, so it's a terrible thing. 

There is a way to do it is that we count it every minute. to do that we should generate one none state task-instance for every minute. 

### Nature key points



## Define converter

```sqlite
-- orderState:paid --> consumeInput
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('/B/sale/orderState:1', '/M/statistics/productConsume/task:1', '{"selector":{"source_state_include":["paid"]},"executor":[{"protocol":"localRust","url":"nature_demo_converter.dll:statistics_task"}]}');

-- orderState:paid --> consumeInput
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('/B/statistics/product/consumeInput:1', '/M/statistics/productConsume/task/minute:1', '{"delay":70, "executor":[{"protocol":"localRust","url":"nature_demo_converter.dll:consume_input"}]}');


```

`task/minute`: we need to generate a task instance to drive the statistics makeing.

"/M" `metaType` 

why delay 70 seconds? 

## unready

### Questions

There is a question, how to identify each inputted data for `consume/input`? used Nature generated instance id? no, it's hard to query it out, so we use parameterize instance technology in this converter.

update the stateful-counter is a big bottleneck problem for busy system,  so we use Nature's `delay` technology and stateless `meta` to hold every past minute data. You can form you hour data, day data and any wide range data through this mechanism, but in this demo we stopped at minute data, It's enough for you to understand how to use Nature for statistics effectively.

### Nature key points

Another question is how to give multi-dimensions info to the following converter?,  sealed it to the `Instance.content` property? This is not a good idea, because `content`'s structure must be resolved by code! that is not we wanted. `context` will face on this problem. here we just used them in converter settings, no coding! (of course you can use `context` in your code explicitly).



```sqlite
-- orderSign --> orderState:signed
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('/B/statistics/consume/input:1', '/B/statistics/consume/product/total/minute:1', '{"target_states":{"add":["signed"]}}');
```

