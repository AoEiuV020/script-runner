# AGENTS.md — script-runner

## 项目定位

这是通用 Docker Runner 镜像项目，只提供生命周期管理，不包含任何业务程序本体。

业务程序通过应用侧脚本下载到 Docker named volume，镜像不随业务程序版本变化。

## 设计原则

- 镜像内尽可能封装通用能力，外部应用保持简单。
- Runner 内部按职责拆文件，禁止把所有逻辑塞回一个大脚本。
- 配置只包含必须 key，不放可推导字段。
- 程序二进制不进入镜像。
- 应用 release 规则不进入镜像。
- 运行时更新由 Runner 负责：检查版本、下载候选文件、停旧进程、替换、重启。

## 文件职责

```text
runner                         # 命令分发
lib/config.sh                  # 读取和校验 /etc/runner/config.env
lib/dirs.sh                    # 目录准备
lib/args.sh                    # APP_ARGS 解析
lib/check.sh                   # 调用应用侧 CHECK_SCRIPT
lib/download.sh                # 调用应用侧 DOWNLOAD_SCRIPT 并校验候选文件
lib/install.sh                 # 安装候选文件到正式路径
lib/process.sh                 # PID 文件、停止进程
lib/run.sh                     # supervisor 和 exec
lib/update.sh                  # 更新编排
lib/version.sh                 # 本地版本状态读写
lib/show.sh                    # help/show 输出
lib/commands.sh                # 子命令绑定
```

新增能力必须优先放到对应职责文件；没有合适职责时新增 `lib/*.sh`，不要扩大 `runner` 主入口。

## 配置契约

Runner 固定读取：

```text
/etc/runner/config.env
```

必填 key：

```bash
APP_EXECUTABLE_NAME=example
APP_ARGS=""
CHECK_SCRIPT=scripts/check.sh
DOWNLOAD_SCRIPT=scripts/download.sh
```

规则：

- `APP_EXECUTABLE_NAME` 必须非空。
- `APP_ARGS` key 必须存在，但 value 可以为空字符串。
- `CHECK_SCRIPT` 必须非空，向 stdout 输出目标版本。
- `DOWNLOAD_SCRIPT` 必须非空，最终生成 `/var/lib/runner/download/app`。
- 不添加 `APP_NAME` 这类可推导字段。
- 不恢复 `UPDATE_SCRIPT` 模式；update 生命周期属于 Runner。

## 固定路径

```text
/opt/runner/bin/$APP_EXECUTABLE_NAME          # 正式可执行文件
/opt/runner/bin/$APP_EXECUTABLE_NAME.version  # 本地版本状态
/var/lib/runner/download/app                  # 下载候选文件
/var/lib/runner/work                          # 临时工作目录
/var/lib/app                                  # 应用数据目录
/run/runner/app.pid                           # 子进程 PID
/run/runner/updating                          # 更新中标记
/run/runner/restart                           # supervisor 重启标记
```

## 更新约束

- 必须先 check 版本，再决定是否下载。
- 已是最新版时，不下载、不停进程、不替换、不重启。
- 下载候选文件必须发生在停旧进程之前。
- 下载失败、校验失败、解压失败不能影响正在运行的旧程序。
- 安装时先复制到目标目录内临时文件，再同目录 `mv` 替换。
- 只有 Runner 写版本文件，应用侧脚本不写版本状态。

## 示例目录

`examples/` 只保存可公开示例。示例可以包含应用侧配置、脚本和文档，但不能提交真实环境变量、token、账号授权文件、下载产物或运行状态。

示例内用 `.env.example` 表达需要填写的环境变量；真实 `.env` 必须被示例目录自己的 `.gitignore` 忽略。

主项目 README/AGENTS 只简单提及示例，不重复示例的具体技术细节；示例细节写在示例目录自己的 README/AGENTS。

## 禁止事项

- 禁止把业务程序 COPY 进镜像。
- 禁止把 GitHub release asset 规则写进镜像。
- 禁止在镜像内硬编码具体业务应用。
- 禁止把 token、密钥、账号信息写进 README、AGENTS 或脚本。
