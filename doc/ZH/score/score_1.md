# 统计班内每个人的总分

假设我们已有了一张每个人各科成绩的一张表格，现在对其进行分析统计。首先我们需要一个`成绩单`以存储这张表格。

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('B', 'score/table', 'include part or all students\'s part or all subjects\` score', 1, '', '', '');
```

有了`成绩单`后我们需要有两个维度的统计：学员和学科。我们可以定义两个关系来解决这个问题，但从性能上来讲不是最优的，一是表格数据的多次传递，二是一次扫描就可以得到两个结果而不需要两次扫描。所以我们这里引入了一个新的`Meta`类型:Multi。

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('M', 'score', 'persion and subject dimension', 1, '', '', '{"multi_meta":{"keys":["persion","subject"]}}');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('M', 'score/persion', 'persion score', 1, '', '', '{"multi_meta":{"keys":["persion","subject"]}}');

INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('M', 'score/subject', 'dimension score', 1, '', '', '{"multi_meta":{"keys":["persion","subject"]}}');
```

