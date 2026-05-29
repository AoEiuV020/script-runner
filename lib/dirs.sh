#!/usr/bin/env bash

runner_prepare_dirs() {
  mkdir -p "$APP_BIN_DIR" "$APP_DATA_DIR" "$RUNNER_WORK_DIR" "$RUNNER_DOWNLOAD_DIR" "$RUNNER_RUN_DIR"
}

runner_prepare_clean_download_dir() {
  rm -rf "$RUNNER_DOWNLOAD_DIR"
  mkdir -p "$RUNNER_DOWNLOAD_DIR"
}
