# 项目准备

## 环境说明

Nature 是用 rust 语言编写的， 你需要自行准备编译环境。这里以 windows 环境进行说明。

Nature 缺省使用 sqlite 数据库，如果想使用 mysql 数据库， 请编辑 Nature/cargo.toml文件并将 nature_db的依赖修改成下面的样子，并修改Nature/.env中数据库连接信息。

```toml
nature_db = {path = "../Nature-DB", features = ["mysql"], version = "0.0.2"}
```

## 下载代码

下载下面项目的代码到同一个目录下

- https://github.com/llxxbb/Nature
- https://github.com/llxxbb/Nature-Common
- https://github.com/llxxbb/Nature-DB
- https://github.com/llxxbb/Nature-Retry
- https://github.com/llxxbb/Nature-Integrate-test-converter
- https://github.com/llxxbb/Nature-Demo
- https://github.com/llxxbb/Nature-Demo-Converter
- https://github.com/llxxbb/Nature-Demo-Common
- https://github.com/llxxbb/Nature-Demo-Converter-Restful

## 编译项目

然后进入 Nature 子目录并运行下面的命令。 

```shell
cargo build
```

当编译完成后，在 Nature/target目录下有三个可执行文件：

- nature.exe : Nature 的主程序.
- retry.exe : 为 Nature 重新加载因环境问题失败的任务，使其能够重新运行。
- restful_converter.exe：服务于示例项目的基于restful的转换器实现


## 修改配置文件

Nature/.env 文件是项目的配置文件，将其拷贝到Nature/target目录下，并修改相应的值，下面为缺省的值。

```toml
DATABASE_URL=nature.sqlite

NATURE_SERVER_ADDRESS=http://localhost:8080/redo_task

SERVER_PORT=8080
```
## 创建数据库

数据库的创建脚本位于Nature-DB/migrations/2019-04-27_init/up.sql。如果你安装了diesel_cli，你可以在终端上运行下面的命令：

```shell
diesel migration run
```

当 nature.sqlite 创建完成后，将其复制到Nature/target目录下

## 启动

进入Nature/target目录，运行编译生成的三个可执行文件。