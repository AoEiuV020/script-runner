#!/usr/bin/env bash

runner_download_candidate() {
  local version="$1"

  runner_prepare_clean_download_dir
  export RUNNER_TARGET_VERSION="$version"

  cd "$RUNNER_DIR"
  bash "$DOWNLOAD_SCRIPT_PATH"

  if [[ ! -f "$RUNNER_DOWNLOAD_FILE" ]]; then
    echo "download script must create executable file: $RUNNER_DOWNLOAD_FILE" >&2
    exit 1
  fi

  chmod +x "$RUNNER_DOWNLOAD_FILE"
  if [[ ! -x "$RUNNER_DOWNLOAD_FILE" ]]; then
    echo "downloaded file is not executable: $RUNNER_DOWNLOAD_FILE" >&2
    exit 1
  fi
}
