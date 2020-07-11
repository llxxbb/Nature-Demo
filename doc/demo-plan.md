# plan for demo

## 销量统计

如果单位时间内的数据量太大，建议将统计指标细分，以减少涉及的数量。

## 组织架构管理

服务于流程审批

## 审批流程

### 要求：

多个部门复用

尽量避免编程

安全提交审核（可通过发放token来解决，Nature 需要验证）

### 情景：

模式：

- 层级模式：
  - 依据员工组织结构自动选择领导
  - M(eta)R(elation): 业务申请->领导审批
  - 组织结构：可放于para中，便于查找上级领导。
  - 业务类型：可放于context中，便于出发其他流程。
- 专家模式，依据票数通过，可加权



必须两人同意才通过

两个人中的任何一人同意就可通过

## Multi-Meta

有了`成绩单`后我们需要有两个维度的统计：学员和学科。我们可以定义两个关系来解决这个问题，但从性能上来讲不是最优的，一是表格数据的多次传递，二是一次扫描就可以得到两个结果而不需要两次扫描。所以我们这里引入了一个新的`Meta`类型:Multi。

```mysql
INSERT INTO meta
(meta_type, meta_key, description, version, states, fields, config)
VALUES('M', 'score/dimensions', '', 1, '', '', '{"master":"B:score/table:1","multi_meta":["B:score/trainee/subject:1"]}');
```

### Nature 要点

Multi-Meta 的类型用 **M** 来表示。此种类型的`Meta`还需要设置 “multi_meta”配置项，以声明执行器可以生成的`Meta`。这些`Meta` 必须是定义过的。




