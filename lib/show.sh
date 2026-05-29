#!/usr/bin/env bash

runner_show_config() {
  cat "$runner_config"
}

runner_show_help() {
  cat <<'EOF'
runner commands:
  runner run             supervise app, install it first if missing
  runner update          check latest, download only when needed, replace, restart if running
  runner exec -- ARGS    ensure app is installed, then exec app with custom ARGS
  runner show            print /etc/runner/config.env
  runner help            print this help

config file:
  /etc/runner/config.env is a bash-compatible key=value file.
  Required keys: APP_EXECUTABLE_NAME, APP_ARGS, CHECK_SCRIPT, DOWNLOAD_SCRIPT.
  APP_ARGS key is required; its value may be an empty string.
  CHECK_SCRIPT prints target version to stdout.
  DOWNLOAD_SCRIPT writes final executable to /var/lib/runner/download/app.
EOF
}
