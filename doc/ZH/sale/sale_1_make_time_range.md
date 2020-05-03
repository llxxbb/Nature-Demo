# 订单->标记数据时间范围

### Nature 要点：`time_range`

我们创建了很多的时间区间数据，这些数据在后面统计时用于锁定数据范围。

时间区间数据的创建工作可以用`builtin-executor:time_range`来完成，不需要写代码。`time_range`需要一个长整数类型的时间信息，缺省是从`Instance.create_time`中获取。但分钟和小时是从`Instance.para`中获取的，这是因为它们使用了`on_para`属性，以及一个缺省的`para_part=0`设置，说明是从上游的`Instance.para`中的第0个位置获取时间信息。而这个位置正好是`time_range`输出的时间区间数据的开始时间。

### Nature 要点：`cache_saved`

时间区间数据是用层进方式创建的，相较于同时创建，用这种方式会大幅度提升性能，尤其是大并发请情境下。

再加上`cache_saved`会进一步提升性能。因为它避免了很多不必要的相同数据的写操作。



## 定义 `Meta`

```mysql

```



我们将使用这个定时器触发多个统计任务