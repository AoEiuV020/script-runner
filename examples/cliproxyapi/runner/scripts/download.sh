#!/usr/bin/env bash
set -euo pipefail

repo="router-for-me/CLIProxyAPI"
version="$RUNNER_TARGET_VERSION"
version_number="${version#v}"

case "$(uname -m)" in
  x86_64|amd64)
    asset_arch="amd64"
    ;;
  aarch64|arm64)
    asset_arch="aarch64"
    ;;
  *)
    echo "unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

asset="CLIProxyAPI_${version_number}_linux_${asset_arch}.tar.gz"
base_url="https://github.com/$repo/releases/download/$version"
work="$(mktemp -d "$RUNNER_WORK_DIR/cliproxyapi.XXXXXX")"
archive="$work/$asset"

curl -fL --retry 3 --connect-timeout 20 -o "$archive" "$base_url/$asset"

if curl -fsSL -o "$work/checksums.txt" "$base_url/checksums.txt"; then
  if grep " $asset$" "$work/checksums.txt" > "$work/checksum.line"; then
    sed "s#  $asset#  $archive#" "$work/checksum.line" | sha256sum -c -
  fi
fi

tar -xzf "$archive" -C "$work"
found="$(find "$work" -type f -name 'cli-proxy-api' -perm -111 | head -n 1)"
if [[ -z "$found" ]]; then
  found="$(find "$work" -type f -name 'cli-proxy-api' | head -n 1)"
fi
if [[ -z "$found" ]]; then
  echo "cli-proxy-api binary not found in archive" >&2
  find "$work" -maxdepth 3 -type f >&2
  exit 1
fi

cp "$found" /var/lib/runner/download/app
chmod +x /var/lib/runner/download/app
