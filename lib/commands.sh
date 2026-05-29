#!/usr/bin/env bash
# shellcheck source=/usr/local/lib/runner/dirs.sh
source /usr/local/lib/runner/dirs.sh
# shellcheck source=/usr/local/lib/runner/args.sh
source /usr/local/lib/runner/args.sh
# shellcheck source=/usr/local/lib/runner/version.sh
source /usr/local/lib/runner/version.sh
# shellcheck source=/usr/local/lib/runner/process.sh
source /usr/local/lib/runner/process.sh
# shellcheck source=/usr/local/lib/runner/check.sh
source /usr/local/lib/runner/check.sh
# shellcheck source=/usr/local/lib/runner/download.sh
source /usr/local/lib/runner/download.sh
# shellcheck source=/usr/local/lib/runner/install.sh
source /usr/local/lib/runner/install.sh
# shellcheck source=/usr/local/lib/runner/update.sh
source /usr/local/lib/runner/update.sh
# shellcheck source=/usr/local/lib/runner/run.sh
source /usr/local/lib/runner/run.sh
# shellcheck source=/usr/local/lib/runner/show.sh
source /usr/local/lib/runner/show.sh

runner_cmd_run() {
  runner_supervise
}

runner_cmd_update() {
  runner_update_installed_binary
}

runner_cmd_exec() {
  runner_exec_app "$@"
}

runner_cmd_show() {
  runner_show_config
}

runner_cmd_help() {
  runner_show_help
}
