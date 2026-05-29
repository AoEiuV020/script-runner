# script-runner

通用 Runner 镜像只封装可执行文件的生命周期，不包含业务程序本体。应用侧通过挂载配置和脚本提供版本检查、下载等业务差异，程序安装结果保存在 Docker volume 中。

## 镜像内结构

```text
/usr/local/bin/runner              # 命令分发
/usr/local/lib/runner/config.sh    # 读取并校验 /etc/runner/config.env
/usr/local/lib/runner/dirs.sh      # 目录准备
/usr/local/lib/runner/args.sh      # APP_ARGS 解析
/usr/local/lib/runner/check.sh     # 调用检查脚本
/usr/local/lib/runner/download.sh  # 调用下载脚本并校验候选文件
/usr/local/lib/runner/install.sh   # 原子安装到 /opt/runner/bin
/usr/local/lib/runner/process.sh   # 进程停止和 PID 文件
/usr/local/lib/runner/run.sh       # supervisor 和 exec
/usr/local/lib/runner/update.sh    # 更新编排
/usr/local/lib/runner/version.sh   # 本地版本状态
/usr/local/lib/runner/show.sh      # help/show
/usr/local/lib/runner/commands.sh  # 子命令绑定
```

## 应用侧配置契约

应用侧挂载 `/etc/runner`，并提供：

```bash
APP_EXECUTABLE_NAME=example
APP_ARGS=""
CHECK_SCRIPT=scripts/check.sh
DOWNLOAD_SCRIPT=scripts/download.sh
```

规则：

- `APP_EXECUTABLE_NAME` 必须存在且非空。
- `APP_ARGS` 这个 key 必须存在，value 可以是空字符串。
- `CHECK_SCRIPT` 必须存在且非空，脚本向 stdout 输出目标版本。
- `DOWNLOAD_SCRIPT` 必须存在且非空，脚本读取 `RUNNER_TARGET_VERSION`，最终写出 `/var/lib/runner/download/app`。
- 外部脚本不负责停止进程、安装、替换、重启、写版本。

## 固定路径

```text
正式可执行文件：/opt/runner/bin/$APP_EXECUTABLE_NAME
版本状态文件：  /opt/runner/bin/$APP_EXECUTABLE_NAME.version
应用数据目录：  /var/lib/app
工作目录：      /var/lib/runner/work
下载目录：      /var/lib/runner/download
候选文件：      /var/lib/runner/download/app
PID 文件：      /run/runner/app.pid
更新标记：      /run/runner/updating
重启标记：      /run/runner/restart
```

## 更新流程

```text
check latest
如果 current == latest 且目标程序存在：退出，不下载、不停进程、不重启
清空 /var/lib/runner/download
调用 DOWNLOAD_SCRIPT 下载候选文件
校验 /var/lib/runner/download/app 存在且可执行
如程序正在运行：停止旧进程
复制候选文件到 /opt/runner/bin/.$APP_EXECUTABLE_NAME.new
同目录 mv 原子替换 /opt/runner/bin/$APP_EXECUTABLE_NAME
写入 /opt/runner/bin/$APP_EXECUTABLE_NAME.version
如原程序正在运行：supervisor 自动重启
```

下载发生在停进程之前。网络失败、版本检查失败、checksum 失败或解压失败不会影响正在运行的旧程序。

## 子命令

```bash
runner run
runner update
runner exec -- ARGS
runner show
runner help
```

- `runner run`：作为 supervisor 启动应用；应用缺失时先更新安装。
- `runner update`：检查版本，必要时下载、替换并重启正在运行的应用。
- `runner exec -- ARGS`：确保应用存在，然后直接执行应用命令。
- `runner show`：打印 `/etc/runner/config.env`。
- `runner help`：打印帮助。

## 示例

`examples/cliproxyapi/` 提供了一个完整 Compose 示例，展示应用侧如何提供 Runner 配置、版本检查脚本和下载脚本。示例的具体配置、环境变量和运行方式见示例目录内 README。

## 构建

```bash
docker build -t local/script-runner:latest .
```

## 维护原则

- 不把业务程序复制进镜像。
- 不把应用 release 规则写进镜像。
- 不增加 `APP_NAME` 这类可由 `APP_EXECUTABLE_NAME` 推导的配置。
- 不把 Runner 内部逻辑集中回单个大脚本；新增能力按职责拆到 `lib/*.sh`。
- 不在应用侧重新实现 update/install/restart 生命周期。
