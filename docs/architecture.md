# Repository Structure

gaia is a flake-parts based Nix configuration. `flake.nix` delegates to
`flake-parts`, importing every module in `parts/` with import-tree:

```nix
outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./parts);
```

## Layout

|path|purpose|
|---|---|
|`parts/`|flake-parts modules that wire everything together|
|`lib/`|helpers for generated bundle options and desktop selection|
|`core/`|always-imported system, infrastructure, and utility configuration|
|`bundles/`|opt-in feature modules, grouped by category and name|
|`hosts/`|per-host configuration|
|`packages/`|custom packages and their sources|
|`docs/`|this documentation|
|`.secrets.yaml`|sops-nix encrypted secrets|
|`.justfile`|just recipes for common tasks|

## Parts

- `systems.nix` - the architectures this flake supports (`x86_64-linux`, `aarch64-linux`)
- `hosts.nix` - imports the bundle flake module and declares the hosts
- `packages.nix` - builds every directory under `packages/` with `callPackage`, providing the nvfetcher `sources`
- `sources.nix` - the `sources` option consumed by `packages.nix`
- `shell.nix` - the devShell
- `format.nix` - treefmt configuration

## Hosts

`parts/hosts.nix` imports `inputs.bundlix.flakeModules.default` from
[bundlix](https://github.com/warm-vodka/bundlix) and declares the hosts.
Bundlix discovers optional bundle entries and generates their enable options
with these settings:

```nix
bundle.autoImport = {
  enable = true;
  root = ../bundles;
  prefix = ["gaia"];
};
```

Each host imports the shared modules under `core/` and its host directory
through import-tree. Bundlix handles the optional features under `bundles/`.

Declared hosts: `eris`, `keres`, `moirai`, `hemera`, `iso`.

## Core and Bundles

`core/` contains configuration that every host imports. Infrastructure is under
`core/infra/`, shared helpers and options are under `core/utils/`, and always-on
styling is under `core/system/`. Core defines options such as `gaia.state`,
`gaia.autoStart`, and `gaia.device`; hosts can set these without enabling another
module. Device options describe the host role and monitors; see
[Device policy and host monitors](bundle-reference.md#device-policy).

`bundles/` contains opt-in features grouped under `programs`, `services`,
`system`, and `desktops`. Each feature has its own directory: for example,
`bundles/programs/broot/` is enabled with `gaia.programs.broot.enable`.
Small bundles use a single `default.nix`; larger ones split their configuration
across several files. See [Adding a bundle](adding-a-bundle.md) for the workflow
and [Bundle reference](bundle-reference.md) for options and dependencies.

## Host Config

`hosts/<host>/gaia.nix` enables the bundles that host should have, for example
`gaia.programs.git.enable = true;`. `hosts/<host>/hardware.nix` is machine
specific. Hosts that run extra services keep them here too, see `hosts/keres/`
for examples. `hosts/<host>/monitors.nix` declares device monitor profiles rather
than embedding hardware identities in desktop bundles. The `iso` host also has
`hosts/iso/installer.nix`, which builds a disko installer image.

## Packages

Every directory under `packages/` is a callable package. Sources are declared in
`packages/nvfetcher.toml` and generated into `packages/_sources/` by nvfetcher.
See [package-examples.md](package-examples.md).

## Secrets

sops-nix reads `.secrets.yaml`, encrypted for the age keys in `.sops.yaml`.
Bundles reference secrets through `config.sops.secrets.<name>`. Edit the file
with `just secret`.
