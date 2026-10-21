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

Battery timeouts apply when power policy and Noctalia are enabled and the
graphical session is active. Returning to AC or stopping the policy service
restores Noctalia's ordinary idle settings. Set `gaia.device.power.enable = false`
to disable the policy. Hosts without Noctalia do not apply it, even when their
role is `laptop`. See [`core/utils/power.nix`](../core/utils/power.nix) for the options.

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
bundle's UWSM session as the fallback. Autologin bypasses the chooser; the
[autologin bundle](../bundles/system/autologin/default.nix) selects the sole
enabled `gaia.desktops.<name>` session and rejects zero or multiple enabled desktops.

## Window and Shell Corners

[`core/system/styling.nix`](../core/system/styling.nix) extends Stylix locally
with `stylix.borderRadius`, a non-negative integer in logical pixels. Its default
is `0` (square corners). Set it in a host's bundle configuration:

```nix
nixos.stylix.borderRadius = 0;
```

Home Manager inherits the system value; `home-manager.stylix.borderRadius`
can override it for the user. GTK window decorations, Mango window clipping,
and Vicinae's launcher use the radius directly. GTK buttons and other in-app
controls retain their own styling.

Noctalia's bar and capsule radii use `stylix.borderRadius` directly. Other
Noctalia shell surfaces and controls scale proportionally: `0` is square,
`12` gives their normal rounding, and `24` or higher gives twice their normal
rounding. This option does not change the Niri or Hyprland bundles.

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

Requirements do not enable dependencies. Bundlix checks them after bundle
configuration has merged, for both the host and each user's configuration. If an
enabled bundle's requirement is disabled or missing, bundle evaluation fails
and names the required flags. A disabled bundle does not enforce its
requirements. Set required bundle flags explicitly in the same configuration
scope as the requiring bundle.

## Inputs and Packages

- Flake input home modules: `inputs.nixcord.homeModules.nixcord`
- Flake input packages: `inputs'.wakatime-ls.packages.default`
- Packages built in this flake: `self'.packages.proton-cachyos_x86_64_v3`
- New flake inputs go in `flake.nix`; keep the sorted list intact

See [Adding and updating packages](package-examples.md) for source management
and [Formatting](conventions.md#formatting) for formatter usage.
