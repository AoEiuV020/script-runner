#!/usr/bin/env bash

runner_build_app_args() {
  if [[ "$#" -gt 0 ]]; then
    printf '%s\0' "$@"
    return
  fi

  if [[ -z "$APP_ARGS" ]]; then
    return
  fi

  # APP_ARGS intentionally uses shell words because config.env is trusted shell syntax.
  # shellcheck disable=SC2086
  printf '%s\0' $APP_ARGS
}
