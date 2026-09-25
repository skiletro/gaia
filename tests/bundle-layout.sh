#!/usr/bin/env bash
set -euo pipefail
category=${1:?expected category}
if find "bundles/$category" -mindepth 1 -maxdepth 1 -name '*.nix' -print -quit | grep -q .; then
  echo "flat bundle under bundles/$category" >&2
  exit 1
fi
for dir in bundles/"$category"/*/; do
  test -f "${dir}default.nix" || { echo "missing ${dir}default.nix" >&2; exit 1; }
done
if rg -q 'mkEnableModule' "bundles/$category" --glob '*.nix'; then
  echo "manual enable module remains under bundles/$category" >&2
  exit 1
fi
