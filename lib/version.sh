#!/usr/bin/env bash

runner_current_version() {
  if [[ -f "$APP_VERSION_FILE" ]]; then
    cat "$APP_VERSION_FILE"
  fi
}

runner_write_version() {
  local version="$1"
  printf '%s\n' "$version" > "$APP_VERSION_FILE"
}
