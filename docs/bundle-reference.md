# Bundle Reference

## Bundle Arguments

Available at the top of a bundle module:

- `bundleLib` - provides `mkEnableModule`
- `lib` - nixpkgs lib
- `inputs` / `inputs'` - flake inputs, unsystemised and per-system
- `self'` - this flake's outputs for the current system
- `config` - the full config, used for `lib.mkIf` conditions (e.g. the desktops
  compare `config.gaia.desktop`)

Inside a `nixos` or `home-manager` block the usual platform arguments are
available, in particular `pkgs` and `config`.

## mkEnableModule

```
bundleLib.mkEnableModule path moduleConfig
```

Creates the `<path>.enable` option and applies `moduleConfig` only when that
option is set.

## Platform Blocks

- `nixos = <module>` system-level config
- `home-manager = <module>` user-level config

## gaia Options

- `gaia.autoStart = ["app --flag"]` - autostart entries, see
  `bundles/utils/autostart.nix`
- `gaia.state.system = "25.11"` - state version per host, see
  `bundles/utils/state.nix`
- `gaia.desktop = "niri"` - desktop selector, see `bundles/desktops/options.nix`
- Bundles can enable each other, e.g. `gaia.programs.wakatime.enable = true;`

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
