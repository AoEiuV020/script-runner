# CLIProxyAPI 示例

这个目录是 `script-runner` 的一个完整 Compose 示例，演示如何用应用侧脚本检查、下载并运行 CLIProxyAPI。示例不保存程序二进制，程序安装结果保存在 Docker named volume。

## 目录结构

```text
compose.yaml
config/
  config.example.yaml
  config.yaml
.env.example
.gitignore
.cli-proxy-api/
  .gitkeep
runner/
  config.env
  scripts/
    check.sh
    download.sh
```

- `compose.yaml`：使用 `aoeiuv020/script-runner:latest`。
- `config/config.example.yaml`：CLIProxyAPI 官方默认完整配置示例，用于复制生成本地真实配置。
- `config/config.yaml`：本地真实业务配置，不提交。
- `.env.example`：环境变量模板；真实 `.env` 不提交。
- `.cli-proxy-api/.gitkeep`：保留 CLIProxyAPI 默认家目录位置；真实账号或授权文件不提交。
- `runner/config.env`：Runner 必填配置。
- `runner/scripts/check.sh`：查询 GitHub latest release，输出目标版本。
- `runner/scripts/download.sh`：下载指定版本、校验、解压，并产出候选可执行文件。

## 环境变量

首次使用时复制模板：

```bash
cp .env.example .env
```

`.env` 可配置：

```bash
GITHUB_TOKEN=
```

`GITHUB_TOKEN` 可留空。公开仓库 release 不需要私有 repo 权限；token 只用于认证身份、提高 GitHub 公开 API rate limit。

- fine-grained token：需要能读取 public repository metadata。
- classic token：可不勾选 `repo` scope。

真实 `.env` 被 `.gitignore` 忽略，不应提交。Compose 将 `.env` 配置为可选文件；未创建 `.env` 时也可以加载配置，但未认证 GitHub API 可能触发较低 rate limit。

## 业务配置

`config/config.example.yaml` 保存官方默认完整配置示例，只作为模板提交到公开仓库。

真实业务配置可能包含 API key、代理账号、TLS 路径或其他隐私信息，应复制为本地文件后使用：

```bash
mkdir -p config
cp config/config.example.yaml config/config.yaml
```

`config/config.yaml` 被 `.gitignore` 忽略，不应提交。Compose 默认将本地 `config/` 目录挂载到容器内 `/etc/app`，Runner 仍读取 `/etc/app/config.yaml`。这样宿主机替换 `config/config.yaml` 后，容器会按目录路径访问新的文件引用。

## Runner 配置

`runner/config.env` 只包含必须字段：

```bash
APP_EXECUTABLE_NAME=CLIProxyAPI
APP_ARGS="--config /etc/app/config.yaml"
CHECK_SCRIPT=scripts/check.sh
DOWNLOAD_SCRIPT=scripts/download.sh
```

含义：

- `APP_EXECUTABLE_NAME`：Runner 安装和执行 `/opt/runner/bin/CLIProxyAPI`。
- `APP_ARGS`：key 必须存在；本示例用它传入配置文件路径。
- `CHECK_SCRIPT`：输出远端目标版本。
- `DOWNLOAD_SCRIPT`：根据 `RUNNER_TARGET_VERSION` 下载目标版本。

不要增加 `APP_NAME`。显示名、临时文件名、版本文件名都可以从 `APP_EXECUTABLE_NAME` 推导。

## Docker volume

程序本体、版本状态和 CLIProxyAPI 静态资源不保存在示例目录：

```text
<project>_cliproxyapi-bin -> /opt/runner/bin
<project>_cliproxyapi-static -> /etc/app/static
```

`config/static` 由命名 volume 覆盖，避免大文件写入同步目录。CLIProxyAPI 示例当前没有需要写入 `/var/lib/app` 的业务数据；账号授权文件已经挂载到 `.cli-proxy-api/`，日志默认输出到 stdout。所以不保留 `app-data` 或日志 volume。

`<project>` 默认取当前目录名，也可以通过 `docker compose -p` 或 `COMPOSE_PROJECT_NAME` 指定。`docker compose down` 默认不会删除这个 volume。不要使用 `docker compose down -v`，除非明确要删除已安装程序和版本状态。

## 版本检查

`runner/scripts/check.sh` 调用 GitHub latest release API，并输出 `.tag_name` 作为目标版本。

Runner 读取该输出后会和本地版本文件比较：

```text
/opt/runner/bin/CLIProxyAPI.version
```

如果本地版本等于目标版本，且 `/opt/runner/bin/CLIProxyAPI` 存在并可执行，`runner update` 会直接退出。此时不会下载、不会停进程、不会替换、不会重启。

## 下载与安装

`runner/scripts/download.sh` 只负责下载候选文件，不负责安装。

脚本读取：

```bash
RUNNER_TARGET_VERSION
```

然后根据版本号选择 release asset、校验 checksum、解压 archive，并最终写出：

```text
/var/lib/runner/download/app
```

Runner 负责后续安装：

```text
/var/lib/runner/download/app
  -> /opt/runner/bin/.CLIProxyAPI.new
  -> /opt/runner/bin/CLIProxyAPI
```

安装成功后 Runner 写入：

```text
/opt/runner/bin/CLIProxyAPI.version
```

## 常用命令

拉取通用镜像：

```bash
docker pull aoeiuv020/script-runner:latest
```

启动应用：

```bash
docker compose up -d
```

检查更新：

```bash
docker compose exec cliproxyapi runner update
```

临时执行应用命令：

```bash
docker compose exec cliproxyapi runner exec -- --help
```

停止容器但保留 volume：

```bash
docker compose down
```

## 端口

默认映射：

```text
8317:8317
```

## 维护原则

- 应用侧只保留 `check.sh` 和 `download.sh`。
- 不在应用侧添加 `update.sh`、`install.sh`、`restart.sh`。
- 下载脚本必须最终产出 `/var/lib/runner/download/app`。
- 下载失败不能改动 `/opt/runner/bin/CLIProxyAPI`。
- token 只能放 `.env`，不要写入脚本或文档。
