# Prepare


## Download code & compile

Before we start, we need nature can be run on you local machine. Nature is written in rust,  so it need a compile environment. download the following code to a directory and compile Nature.

- https://github.com/llxxbb/Nature
- https://github.com/llxxbb/Nature-Common
- https://github.com/llxxbb/Nature-DB
- https://github.com/llxxbb/Nature-Retry
- https://github.com/llxxbb/Nature-Integrate-test-converter

When the compiling finished, there will be tow execute files generated in Nature's target directory, you can run it directly according to your needs. for window that would be:

- nature.exe : The Nature main program.
- retry.exe : reload failed task for Nature. 

## .env

This is your config file for `nature` and `retry` to run. You can get it from the root of it's the project. and copy it to the directory where the compiled files lived in. Maybe you  need modify the following items:

```toml
DATABASE_URL=nature.sqlite

NATURE_SERVER_ADDRESS=http://localhost:8080/redo_task

SERVER_PORT=8080
```
## Create database for nature.sqlite

The script is under the path : Nature-DB/migrations/2019-04-27_init/up.sql. 

If you have diesel_cli installed, you can run the following cmd in you shell window.

```shell
diesel migration run
```

When nature.sqlite created. copy it to the path where nature.exe lived in.

### mysql

By default, we use sqlite to store data for Nature ,  if you want to use mysql,  please edit the Nature's cargo.toml file, use mysql to replace sqlite in the following line and recompile Nature,  then change the `DATABASE_URL` property to mysql in `.env` file.

```toml
nature_db = {path = "../Nature-DB", features = ["sqlite"], version = "0.0.2"}
```

