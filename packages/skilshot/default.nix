{ pkgs, lib, ... }:
pkgs.writeShellScriptBin "skilshot" ''
  selection=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | ${lib.getExe pkgs.slurp} -o)

  ${lib.getExe pkgs.grim} -t ppm -g "$selection" - | ${lib.getExe pkgs.satty} -f - \
    --initial-tool=brush \
    --copy-command=wl-copy \
    --actions-on-escape="save-to-clipboard,exit" \
    --brush-smooth-history-size=5 \
    --disable-notifications
''
