#!/usr/bin/env bash

runner_app_pid() {
  if [[ -f "$RUNNER_PID_FILE" ]]; then
    cat "$RUNNER_PID_FILE"
  fi
}

runner_app_is_running() {
  local pid="${1:-}"
  [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}

runner_stop_app() {
  local pid
  pid="$(runner_app_pid || true)"
  if ! runner_app_is_running "$pid"; then
    rm -f "$RUNNER_PID_FILE"
    return
  fi

  kill -TERM "$pid" 2>/dev/null || true

  for _ in $(seq 1 50); do
    if ! runner_app_is_running "$pid"; then
      rm -f "$RUNNER_PID_FILE"
      return
    fi
    sleep 0.1
  done

  kill -KILL "$pid" 2>/dev/null || true
  rm -f "$RUNNER_PID_FILE"
}
