# Bundle Reference

## Path-Derived Enable Options

Each directory at `bundles/<category>/<name>/` defines one optional bundle,
enabled with `gaia.<category>.<name>.enable` (default: `false`). For example,
`bundles/programs/broot/` provides `gaia.programs.broot.enable`.

Bundlix loads all regular `.nix` files directly inside the bundle directory
together. `default.nix` is a convention, not a required entry point, and sibling
modules need no explicit imports. Nested directories, symlinks, and non-Nix
assets are not loaded automatically.

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
- `gaia.device.monitors` declares host-owned display profiles, defined in
  `core/utils/monitors.nix`.

## Host Role

Set `gaia.device.type` in `hosts/<host>/gaia.nix` to label a machine as a
`desktop`, `laptop`, `server`, `vm`, or `installer`. The label does not enable
hardware modules or power management.

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

Mango renders these profiles through
[`bundles/desktops/mango/monitors.nix`](../bundles/desktops/mango/monitors.nix).
Profiles must be declared on each host that uses the displays.

Examples: [Eris](../hosts/eris/monitors.nix) and
[Moirai](../hosts/moirai/monitors.nix).

## Desktop Sessions

Desktop environments are ordinary optional bundles. Enable one with a path such
as `gaia.desktops.mango.enable = true;`. Enabled desktop flags determine which
sessions are available.

The [greeter bundle](../bundles/system/greeter/default.nix) uses tuigreet to
list installed sessions. The [autologin bundle](../bundles/system/autologin/default.nix)
bypasses that chooser and requires exactly one enabled desktop.

## Window and Shell Corners

[`core/system/styling.nix`](../core/system/styling.nix) extends Stylix locally
with `stylix.borderRadius`, a non-negative integer in logical pixels. Its default
is `0` (square corners). Set it in a host's bundle configuration:

```nix
nixos.stylix.borderRadius = 0;
```

Home Manager inherits the system value; `home-manager.stylix.borderRadius`
can override it for the user. GTK window decorations, Mango, Vicinae, and
Noctalia use this value. Individual applications may retain their own styling.

Rebuild and switch the host to apply changes; see [Build and deploy](development.md#build-and-deploy).
Restart GTK applications so they load the updated stylesheet.

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
category, such as `"services.noctalia"` or `"programs.vicinae"`. Valid categories
are inferred from directories directly under `bundles/`.

Requirements do not enable dependencies. Enable required flags in the same host
or user configuration as the requiring bundle. Missing requirements cause
evaluation to fail.

## Inputs and Packages

- Flake input home modules: `inputs.nixcord.homeModules.nixcord`
- Flake input packages: `inputs'.wakatime-ls.packages.default`
- Packages built in this flake: `self'.packages.proton-cachyos_x86_64_v3`
- New flake inputs go in `flake.nix`; keep the sorted list intact

See [Adding and updating packages](package-examples.md) for source management
and [Formatting](conventions.md#formatting) for formatter usage.
