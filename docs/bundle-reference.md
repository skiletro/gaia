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

## Desktop Sessions

Desktop environments are ordinary optional bundles. Enable one with a path such
as `gaia.desktops.mango.enable = true;`. Enabled desktop flags determine which
sessions are available.

Enabled desktop bundles provide UWSM sessions for tuigreet. A greeter can offer
multiple enabled sessions; with exactly one enabled desktop, it uses that
bundle's UWSM session as the fallback. Autologin bypasses the chooser and
requires exactly one enabled desktop.

Bundles can enable other bundles by setting their generated flags, for example
`gaia.programs.wakatime.enable = true;`.

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
