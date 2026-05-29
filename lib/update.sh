#!/usr/bin/env bash

runner_update_installed_binary() {
  local current latest had_running_app=0

  runner_prepare_dirs
  current="$(runner_current_version || true)"
  latest="$(runner_check_latest_version)"

  if [[ -x "$APP_EXECUTABLE" && "$current" == "$latest" ]]; then
    echo "$APP_EXECUTABLE_NAME already latest: $latest"
    return
  fi

  runner_download_candidate "$latest"

  if runner_app_is_running "$(runner_app_pid || true)"; then
    had_running_app=1
    touch "$RUNNER_UPDATING_FILE"
    runner_stop_app
  fi

  if [[ "$had_running_app" == "1" ]]; then
    trap 'touch "$RUNNER_RESTART_FILE"; rm -f "$RUNNER_UPDATING_FILE"' EXIT
  fi

  runner_install_candidate "$latest"

  if [[ "$had_running_app" == "1" ]]; then
    touch "$RUNNER_RESTART_FILE"
    rm -f "$RUNNER_UPDATING_FILE"
    trap - EXIT
  fi
}
