# AGENTS.md — examples/cliproxyapi

## 项目定位

这是 `script-runner` 仓库内的 CLIProxyAPI 示例，展示应用侧如何提供 Runner 配置、版本检查脚本和下载脚本。

本示例不包含 Dockerfile，不构建业务镜像，不保存下载后的程序二进制。

## 可以提交的内容

```text
compose.yaml
config.example.yaml
.env.example
.gitignore
.cli-proxy-api/.gitkeep
runner/config.env
runner/scripts/check.sh
runner/scripts/download.sh
README.md
AGENTS.md
```

## 不应提交的内容

- 真实 `.env`。
- 真实 `config.yaml` 或 `config.*.yaml`。
- GitHub token。
- CLIProxyAPI 账号、授权、会话或运行状态文件。
- CLIProxyAPI 二进制本体。
- 下载缓存。
- 解压临时目录。
- 日志和业务运行数据。

程序本体和版本状态应保存在 Docker named volume：

```text
cliproxyapi-bin -> /opt/runner/bin
```

CLIProxyAPI 示例当前没有需要持久化到 `/var/lib/app` 的业务数据；账号授权文件挂载到 `.cli-proxy-api/`，日志默认输出到 stdout。不要无依据新增 `app-data` 或日志 volume。

## 环境变量规则

真实环境变量写入 `.env`，但 `.env` 必须被 `.gitignore` 忽略。

公开仓库 release API 不需要私有 repo 权限。`GITHUB_TOKEN` 只是用于提高 GitHub API rate limit。

文档和脚本中只能出现占位或空值：

```bash
GITHUB_TOKEN=
```

禁止把真实 token 写入：

- README；
- AGENTS；
- shell 脚本；
- 调试输出；
- git commit。

展示 token 时只能使用 `[REDACTED]`。

## 业务配置规则

公开示例只提交 `config.example.yaml`，内容使用 CLIProxyAPI 官方默认完整配置。

真实业务配置写入 `config.yaml` 或 `config.*.yaml`，但这些文件必须被 `.gitignore` 忽略。

Compose 必须挂载本地真实 `config.yaml`，不要把 `config.example.yaml` 直接挂进容器运行。

不要在提交内容中写入真实 API key、代理账号、TLS 私钥路径或其他隐私配置。

## Runner 配置

`runner/config.env` 只放必须字段：

```bash
APP_EXECUTABLE_NAME=CLIProxyAPI
APP_ARGS="--config /etc/app/config.yaml"
CHECK_SCRIPT=scripts/check.sh
DOWNLOAD_SCRIPT=scripts/download.sh
```

规则：

- 不添加 `APP_NAME`。
- 不添加 `UPDATE_SCRIPT`。
- 不把 update/install/restart 生命周期放到应用侧。
- `APP_ARGS` key 必须存在，value 可以为空字符串。

## 应用侧脚本职责

只保留：

```text
runner/scripts/check.sh
runner/scripts/download.sh
```

`check.sh`：

- 查询 CLIProxyAPI latest release。
- 输出目标版本，例如 `v7.1.29`。
- 可选使用 `.env` 中的 `GITHUB_TOKEN` 提高 GitHub API rate limit。

`download.sh`：

- 读取 `RUNNER_TARGET_VERSION`。
- 下载对应版本的 CLIProxyAPI release asset。
- 校验 checksum。
- 解压并找到目标可执行文件。
- 最终写出 `/var/lib/runner/download/app`。

应用侧脚本不负责：

- 停止进程。
- 安装到 `/opt/runner/bin`。
- 写版本文件。
- 重启应用。

## Compose 规则

- 示例端口使用 CLIProxyAPI 默认端口映射 `8317:8317`。
- 不写本地机器端口冲突、个人环境路径或临时端口说明。
- 示例依赖镜像默认 `CMD ["run"]`；不要在 compose 里重复写 `command: ["run"]`。
- 不固定日志 volume，除非先确认 CLIProxyAPI 实际日志路径。

## 验证

修改 compose 后验证：

```bash
docker compose config
```

修改下载逻辑后验证：

```bash
docker compose run --rm --no-deps --entrypoint runner app update
```
