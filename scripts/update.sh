#!/usr/bin/env bash
# Re-resolves the latest dawn.gg Linux tarball version + content hash
# and rewrites sources.json. Run from the repo root, or via `nix run .#update`.
set -euo pipefail

API_URL="https://dawn.gg/api/launcher/download?platform=linux-amd64&format=tarball"
SOURCES_JSON="sources.json"

echo "Resolving redirect target (HEAD-only, no download yet)..." >&2
redirect_url=$(curl -sI -L -o /dev/null -w '%{url_effective}' "$API_URL")

version=$(grep -oP 'dawn-launcher-\K[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' <<<"$redirect_url" || true)
if [ -z "$version" ]; then
  echo "Couldn't extract a version from the redirect target:" >&2
  echo "  $redirect_url" >&2
  echo "The upstream filename pattern may have changed -- update the grep pattern above." >&2
  exit 1
fi
echo "Latest version: $version" >&2

echo "Downloading + hashing the tarball (this fetches the full file)..." >&2
tarball_name="dawn-launcher-${version}-linux-amd64.tar.gz"
if nix store prefetch-file --help >/dev/null 2>&1; then
  hash=$(nix store prefetch-file --json --hash-type sha256 --name "$tarball_name" "$API_URL" | jq -r '.hash')
else
  base32_hash=$(nix-prefetch-url --name "$tarball_name" "$API_URL")
  hash=$(nix hash to-sri --type sha256 "$base32_hash")
fi

jq -n --arg version "$version" --arg hash "$hash" \
  '{version: $version, hash: $hash}' > "$SOURCES_JSON"

echo "Wrote $SOURCES_JSON:" >&2
cat "$SOURCES_JSON"
