#!/usr/bin/env bash

runner_install_candidate() {
  local version="$1"
  local tmp_bin="$APP_BIN_DIR/.$APP_EXECUTABLE_NAME.new"

  cp "$RUNNER_DOWNLOAD_FILE" "$tmp_bin"
  chmod +x "$tmp_bin"
  mv "$tmp_bin" "$APP_EXECUTABLE"
  runner_write_version "$version"

  echo "installed $APP_EXECUTABLE_NAME $version -> $APP_EXECUTABLE"
}
