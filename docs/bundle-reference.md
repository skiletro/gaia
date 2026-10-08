# Bundle Reference

## Path-Derived Enable Options

Each bundle lives at `bundles/<category>/<name>/default.nix`. The path creates
`gaia.<category>.<name>.enable`, with a default of `false`. For example,
`bundles/programs/broot/default.nix` provides `gaia.programs.broot.enable`.
Bundle files contain configuration only. The import wrapper declares the option
and applies the bundle when enabled.

Modules without top-level arguments may be plain attrsets. Use a module function
when the bundle needs arguments such as `lib`, `inputs`, `inputs'`, or `self'`.
Inside `nixos` and `home-manager` blocks, usual platform arguments such as
`pkgs` and `config` are available.

## Core Options

`core/` is imported for every host. It contains shared modules and option
definitions that do not have enable flags:

- `gaia.autoStart = ["app --flag"]` adds user autostart entries, defined in
  `core/utils/autostart.nix`.
- `gaia.state.system = "25.11"` sets the system state version. The home state
  version in `gaia.state.home` defaults to it, defined in `core/utils/state.nix`.
- `gaia.device.type` declares the host role: `desktop` (default), `laptop`,
  `server`, `vm`, or `installer`, defined in `core/utils/device.nix`.
- `gaia.device.power` configures shared battery policy, defined in
  `core/utils/power.nix`.
- `gaia.device.monitors` declares host-owned display profiles, defined in
  `core/utils/monitors.nix`.

## Device Policy

Declare the role in `hosts/<host>/gaia.nix`. It selects policy defaults, not
hardware modules, power daemons, or lid-switch behavior:

```nix
gaia.device = {
  type = "laptop";
  power = {
    enable = true; # defaults to true for laptops, false for other roles
    disableBlurOnBattery = true;
    idle.battery = {
      lockTimeout = 300;
      screenOffTimeout = 360;
      suspendTimeout = 900;
    };
  };
};
```

Each timeout is a positive integer in seconds; `null` disables that battery
behavior. The values above are the defaults. On AC, Noctalia uses its ordinary
bundle settings (lock after 600 seconds, screen off after 660 seconds, no
automatic suspend). Native Noctalia settings remain the AC-policy override.

When power policy and Noctalia or Mango are enabled, one
`gaia-power-policy` user service follows the graphical session. It reads UPower's
`OnBattery` property once per event and applies both consumers from that state:
shorter Noctalia idle timeouts and disabled Mango window/layer blur on battery.
Repeated states do not rewrite unchanged files or reload Mango. AC and service
stop remove the Noctalia override and restore Mango blur. Set
`disableBlurOnBattery = false` to leave Mango blur alone, or `enable = false`
to disable the shared policy entirely. Headless hosts do not start the service,
even when their role is `laptop`.

`core/utils/power.nix` defines options, generated policy files, and the service.
`core/utils/power.sh` contains the watcher and state transitions as ordinary Bash.

## Host Monitors

Put hardware-only display profiles in `hosts/<host>/monitors.nix`. Mango
translates them into monitor rules; an empty set leaves output auto-discovery:

```nix
gaia.device.monitors.panel = {
  identity = "eDP-1";
  mode = {
    width = 2560;
    height = 1600;
    refresh = 60; # Hz; fractional rates also supported
  };
  scale = 1.5;
  position = { x = 0; y = 0; }; # logical pixels
  vrr = true;
};
```

`identity` is either a connector name or an exact
`{ make = "AOC"; model = "AG346UCD"; serial = "..."; }` description.
Mode fields are required and positive. `scale`, `position`, and `vrr` default
to `null`, omitting the corresponding rule rather than forcing a value.
Profile labels are rendered in lexical order.

Profiles contain no compositor-specific fields. Mango's renderer lives in
`bundles/desktops/mango/monitors.nix`, not in the shared device schema.
Generated rules use `mkDefault`; ordinary host Home Manager settings can replace
`wayland.windowManager.mango.settings.monitorrule` for native configuration.
Niri and Hyprland do not consume these profiles.

Active examples: [Eris external displays](../hosts/eris/monitors.nix) and
[Moirai's panel](../hosts/moirai/monitors.nix). Display rules are no longer global:
a docked laptop needs its external displays declared on that host too.

## Desktop Sessions

Desktop environments are ordinary optional bundles. Enable one with a path such
as `gaia.desktops.mango.enable = true;`. Enabled desktop flags determine which
sessions are available.

Enabled desktop bundles provide UWSM sessions for tuigreet. A greeter can offer
multiple enabled sessions; with exactly one enabled desktop, it uses that
bundle's UWSM session as the fallback. Autologin bypasses the chooser and
requires exactly one enabled desktop.

The Tailscale service bundle starts `tailscale systray` as a user service tied
to `graphical-session.target`, so it follows the graphical session lifecycle
instead of a compositor-specific autostart.

## Bundle Requirements

Declare bundle dependencies with top-level `requires` metadata:

```nix
{
  requires = [ "wakatime" ];
  home-manager.programs.helix.enable = true;
}
```

A bare name resolves within the bundle's category, so Helix requires
`gaia.programs.wakatime.enable`. Qualify cross-category dependencies with their
category, such as `"services.noctalia"` or `"programs.vicinae"`.

Requirements do not enable dependencies. If an enabled bundle's requirement is
disabled or missing, NixOS evaluation fails and names the required flags. A
disabled bundle does not enforce its requirements. Set required bundle flags
explicitly in each host configuration.

## Inputs and Packages

- Flake input home modules: `inputs.nixcord.homeModules.nixcord`
- Flake input packages: `inputs'.wakatime-ls.packages.default`
- Packages built in this flake: `self'.packages.proton-cachyos_x86_64_v3`
- New flake inputs go in `flake.nix`; keep the sorted list intact

## Package Sources

For packages that need a source, add a directory under `packages/<name>/` with a
matching section in `packages/nvfetcher.toml`:

```toml
[proton-cachyos_x86_64_v3]
fetch.url = "https://github.com/CachyOS/proton-cachyos/releases/download/$ver/proton-$ver-x86_64_v3.tar.xz"
src.github = "CachyOS/proton-cachyos"
```

Then regenerate sources and reference the package as `self'.packages.<name>`:

```sh
just update-sources
```

## Formatting

`treefmt` runs alejandra, deadnix, keep-sorted, nixf-diagnose, statix and
toml-sort. keep-sorted enforces the ordering of sorted blocks, so keep those
lists sorted by hand too.

```sh
nix fmt
```
