#!/usr/bin/env bash

runner_start_app_once() {
  mapfile -d '' app_args < <(runner_build_app_args)
  cd "$APP_DATA_DIR"
  "$APP_EXECUTABLE" "${app_args[@]}" &
  echo "$!" > "$RUNNER_PID_FILE"
}

runner_supervise() {
  local pid status

  runner_prepare_dirs
  if [[ ! -x "$APP_EXECUTABLE" ]]; then
    runner_update_installed_binary
  fi

  trap 'runner_stop_app; exit 143' TERM INT

  while true; do
    rm -f "$RUNNER_RESTART_FILE"
    runner_start_app_once
    pid="$(runner_app_pid)"
    wait "$pid"
    status="$?"
    rm -f "$RUNNER_PID_FILE"

    while [[ -f "$RUNNER_UPDATING_FILE" ]]; do
      sleep 0.1
    done

    if [[ -f "$RUNNER_RESTART_FILE" ]]; then
      continue
    fi

    exit "$status"
  done
}

runner_exec_app() {
  runner_prepare_dirs
  if [[ ! -x "$APP_EXECUTABLE" ]]; then
    runner_update_installed_binary
  fi

  if [[ "$#" -gt 0 && "$1" == "--" ]]; then
    shift
  fi

  mapfile -d '' app_args < <(runner_build_app_args "$@")
  cd "$APP_DATA_DIR"
  exec "$APP_EXECUTABLE" "${app_args[@]}"
}
