#!/usr/bin/env bash

runner_dir="/etc/runner"
runner_config="$runner_dir/config.env"

load_runner_config() {
  if [[ ! -f "$runner_config" ]]; then
    echo "config not found: $runner_config" >&2
    exit 1
  fi

  set -a
  # shellcheck source=/dev/null
  source "$runner_config"
  set +a

  : "${APP_EXECUTABLE_NAME:?missing APP_EXECUTABLE_NAME in /etc/runner/config.env}"
  if [[ ! ${APP_ARGS+x} ]]; then
    echo "missing APP_ARGS in /etc/runner/config.env" >&2
    exit 1
  fi
  : "${CHECK_SCRIPT:?missing CHECK_SCRIPT in /etc/runner/config.env}"
  : "${DOWNLOAD_SCRIPT:?missing DOWNLOAD_SCRIPT in /etc/runner/config.env}"
}

resolve_runner_path() {
  local path="$1"
  if [[ "$path" = /* ]]; then
    printf '%s\n' "$path"
  else
    printf '%s\n' "$runner_dir/$path"
  fi
}

load_runner_config

APP_BIN_DIR="/opt/runner/bin"
APP_DATA_DIR="/var/lib/app"
RUNNER_WORK_DIR="/var/lib/runner/work"
RUNNER_DOWNLOAD_DIR="/var/lib/runner/download"
RUNNER_DOWNLOAD_FILE="$RUNNER_DOWNLOAD_DIR/app"
RUNNER_RUN_DIR="/run/runner"
RUNNER_PID_FILE="$RUNNER_RUN_DIR/app.pid"
RUNNER_UPDATING_FILE="$RUNNER_RUN_DIR/updating"
RUNNER_RESTART_FILE="$RUNNER_RUN_DIR/restart"
RUNNER_CHECK_OUTPUT="$RUNNER_WORK_DIR/latest-version"
APP_EXECUTABLE="$APP_BIN_DIR/$APP_EXECUTABLE_NAME"
APP_VERSION_FILE="$APP_BIN_DIR/$APP_EXECUTABLE_NAME.version"
CHECK_SCRIPT_PATH="$(resolve_runner_path "$CHECK_SCRIPT")"
DOWNLOAD_SCRIPT_PATH="$(resolve_runner_path "$DOWNLOAD_SCRIPT")"

export RUNNER_DIR="$runner_dir"
export RUNNER_CONFIG="$runner_config"
export APP_BIN_DIR APP_DATA_DIR APP_EXECUTABLE APP_EXECUTABLE_NAME APP_ARGS APP_VERSION_FILE
export RUNNER_WORK_DIR RUNNER_DOWNLOAD_DIR RUNNER_DOWNLOAD_FILE RUNNER_RUN_DIR
export RUNNER_PID_FILE RUNNER_UPDATING_FILE RUNNER_RESTART_FILE RUNNER_CHECK_OUTPUT
