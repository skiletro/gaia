# Paths and generated policy files are supplied by the Nix prelude.

install_override() {
  local source="$1" destination="$2"
  mkdir -p "${destination%/*}"
  install -m 600 "$source" "$destination.tmp"
  mv -f "$destination.tmp" "$destination"
}

apply_state() {
  local on_battery="$1"

  if [ "$on_battery" = true ]; then
    if ! cmp -s "$noctalia_battery" "$noctalia_override"; then
      install_override "$noctalia_battery" "$noctalia_override"
    fi
  else
    rm -f "$noctalia_override"
  fi
}

apply_policy() {
  local state
  state="$(busctl --system get-property \
    org.freedesktop.UPower /org/freedesktop/UPower \
    org.freedesktop.UPower OnBattery)"
  case "$state" in
    'b true') apply_state true ;;
    'b false') apply_state false ;;
    *) printf 'Unexpected UPower OnBattery value: %s\n' "$state" >&2; return 1 ;;
  esac
}

case "${1:-}" in
  --once)
    apply_policy
    exit 0
    ;;
  --restore)
    apply_state false
    rm -f "$noctalia_override.tmp"
    exit 0
    ;;
esac

# Subscribe before the initial query. Each event gets one authoritative battery
# state rather than inferring it from the event.
upower --monitor | {
  apply_policy
  while IFS= read -r _; do
    apply_policy
  done
}
# Even a clean monitor exit means the policy is no longer being enforced.
exit 1
