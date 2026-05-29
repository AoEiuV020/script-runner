#!/usr/bin/env bash

runner_check_latest_version() {
  local latest

  rm -f "$RUNNER_CHECK_OUTPUT"
  cd "$RUNNER_DIR"
  bash "$CHECK_SCRIPT_PATH" > "$RUNNER_CHECK_OUTPUT"

  latest="$(tr -d '\r\n' < "$RUNNER_CHECK_OUTPUT")"
  if [[ -z "$latest" ]]; then
    echo "check script produced empty version: $CHECK_SCRIPT_PATH" >&2
    exit 1
  fi

  printf '%s\n' "$latest"
}
