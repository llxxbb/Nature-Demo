# 全员成绩单->个人成绩

在本示例里，我们采用批量的方式将学生的成绩输入到 Nature.。然后通过 Nature 将其拆分成每个人每个学科的成绩，这样做的好处是：

- 为满足每个学员只能看自己的成绩的需求提供独立数据。
- 这是原子的规范的数据。

在 Nature 里要完成这个工作不需要一行代码，我们只需要按照要求输入数据就可以了。

## 定义`Meta`

在开始之前，我们需要先定义一些`Meta`，首先我们需要一个`成绩单`来存储学生的成绩。

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/table', 'store original score data', 1, '', '', '');
```

然后定义每个学员成绩的`Meta`

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/trainee/subject', 'person original score', 1, '', '', '{"master":"B:score/table:1"}');
```

## 定义`Relation`

接下来我们需要定义一个关系，用于关联这2个目标。

```mysql
INSERT INTO relation
(from_meta, to_meta, settings)
VALUES('B:score/table:1', 'B:score/trainee/subject:1', '{"executor":{"protocol":"builtIn","url":"dimensionSplit","settings":"{\\"wanted_dimension\\":[[\\"\\",[0,1,2]]]}"}, "filter_after":[{"protocol":"localRust","url":"nature_demo_executor:person_score_filter"},{"protocol":"http","url":"http://127.0.0.1:8082/add_score"}]}');
```

` nature_demo_executor:person_score_filter` 和 `http://127.0.0.1:8082/add_score`的作用后面讲。

## 运行 DEMO

### 数据输入

数据的部分数据示例如下,这个表说明了哪个班的哪个人的哪个科目的成绩：

```rust
let mut content: Vec<KV> = vec![];
content.push(KV::new("class5/name2/subject1", 92));
content.push(KV::new("class5/name3/subject1", 87));
content.push(KV::new("class5/name4/subject1", 12));
content.push(KV::new("class5/name5/subject1", 34));
```

我们需要对输入的输入进行拆分，使每个人的每个科目有独立的记录。这个工作可以借助于`builtin-executor: dimensionSplit`来完成。

### Nature 要点 dimensionSplit

`builtIn-executor` : 一般是比较通用的。如对数据进行分类拆分等，用于减轻使用者的工作量。

- `dimensionSplit`的数据要求：首先数据必须是一个数组，其次，数组中的每一项都会被加工成一个 `Output` 数据对象,如下，key 用于存储所有的维度信息，value 用于存放要统计的数据。

```rust
struct Output<'a> {
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

`wanted_dimension`：用于说明如何提取维度及如何存储。这是一个数组，每个数组的项都是一个提取的请求，每个请求由两部分组成：第一个是要输出的`Meta`信息，只对`Multi-Meta`有效且必须定义过；第二个是要提取的维度索引，是一个有顺序的数组。

`dimensionSplit`执行器将提取出的维度放入`Instance.para`属性，将剩余的维度覆盖掉原来的`key`已节省空间。

### Nature 要点

filter_after 可以用于对数据进行清理，如本例中第一个过滤器用于删除除成绩外的其他内容，第二个过滤器则是为所有人的 subject2 成绩加 4分（我们假设这个题目出错了，给所有人加分）。

## 输入数据并等待结果

具体的输入请参考 score.rs