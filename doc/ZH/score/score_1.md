# 成绩单统计维度拆分

在本示例里，我们采用批量的方式将学生的成绩输入到 Nature.。

统计一般是多维度的，所以我们第一步就是将数据按照维度拆分，各自统计各自的。在 Nature 里要完成这个工作不需要一行代码，我们只需要按照要求输入数据就可以了。

## 定义`Meta`

在开始之前，我们需要先定义一些`Meta`，首先我们需要一个`成绩单`来存储学生的成绩。

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/table', 'store original score data', 1, '', '', '');
```

有了`成绩单`后我们需要有两个维度的统计：学员和学科。我们可以定义两个关系来解决这个问题，但从性能上来讲不是最优的，一是表格数据的多次传递，二是一次扫描就可以得到两个结果而不需要两次扫描。所以我们这里引入了一个新的`Meta`类型:Multi。

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('M', 'score/dimensions', '', 1, '', '', '{"multi_meta":["B:score/trainee/original:1:","B:score/subject/original:1"]}');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/trainee/original', 'persion original score', 1, '', '', '{"master":"B:score/table:1"}');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/subject/original', 'subject original score', 1, '', '', '{"master":"B:score/table:1"}');
```

### Nature 要点

Multi-Meta 的类型用 **M** 来表示。此种类型的`Meta`还需要设置 “multi_meta”配置项，以声明执行器可以生成的`Meta`。这些`Meta` 必须是定义过的。

## 定义`Relation`

接下来我们需要定义一个关系，用于关联这4个目标。

```mysql
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:score/table:1', 'M:score/dimensions:1', '{"executor":[{"protocol":"BuiltIn","url":"dimensionSplit","settings":"{\"wanted_dimension\":[[\"B:score/trainee/original:1\",[0,1]],[\"B:score/subject/original:1\",[0,2]]]}"}]}');
```

### Nature 要点

这里我们看到了一个 BuiltIn 执行器， Builtin 一般是比较通用的。如对数据进行分类拆分：`dimensionSplit`。该执行器只能应用到目标为`Multi-Meta`的`Relation`中。

- `dimensionSplit`的数据要求：首先数据必须是一个数组，其次，数组中的每一项都是一个 `Input` 数据对象,如下，key 用于存储所有的维度信息，value 用于存放要统计的数据。

```rust
struct Input<'a> {
    /// include all dimension, separator is defined in Setting
    key: String,
    /// each split dimension will copy this value.
    #[serde(borrow)]
    value: &'a RawValue,
}  
```

- `dimensionSplit`配置信息：用于说明该执行器如何工作，需要配置在`Relartion`中。

```rust
pub struct Setting {
    /// - dimension_separator: default is "/"
    #[serde(skip_serializing_if = "is_default")]
    #[serde(default = "default_separator")]
    pub dimension_separator: String,
    /// - wanted_dimension: array of array to store dimension index. for example: [["meta-a",[1,2]],["meta-b",[1,3]]].
    pub wanted_dimension: Vec<(String, Vec<u8>)>,
}
```

`dimension_separator`：用于说明维度间的分隔符，缺省使用“/”。

`wanted_dimension`：用于说明如何提取维度及如何存储。这是一个数组，每个数组的项都是一个提取的请求，每个请求由两部分组成：第一个是要输出的`Meta`信息，必须定义过；第二个是要提取的维度索引，是一个有顺序的数组。

`dimensionSplit`执行器将提取出的维度放入`Instance.para`属性，将剩余的维度覆盖掉原来的`key`已节省空间。

## 输入数据并等待结果

