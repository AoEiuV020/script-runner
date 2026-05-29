#!/usr/bin/env bash
set -euo pipefail

repo="router-for-me/CLIProxyAPI"
auth_args=()
if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  auth_args=(-H "Authorization: Bearer $GITHUB_TOKEN")
fi

curl -fsSL \
  -H 'Accept: application/vnd.github+json' \
  -H 'User-Agent: script-runner' \
  "${auth_args[@]}" \
  "https://api.github.com/repos/$repo/releases/latest" \
  | jq -r '.tag_name'
