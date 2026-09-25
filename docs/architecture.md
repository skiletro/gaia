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

`parts/hosts.nix` imports `inputs.bundle.flakeModules.default` (bundle-of-nix)
and declares the hosts. Each host imports all modules under `core/`, the
`default.nix` bundle entries under `bundles/`, and all modules under its host
directory:

```nix
imports = let
  wrapBundle = import ../lib/optional-bundle.nix {
    inherit lib;
    root = ../bundles;
  };
in [
  (inputs.import-tree ../core)
  ((inputs.import-tree.filter (file: lib.hasSuffix "/default.nix" file)).map wrapBundle ../bundles)
  (inputs.import-tree ../hosts/${host})
];
```

The bundle wrapper derives each enable option from its path. Helper files next
to a bundle, such as patches, are not imported as modules. Host files remain
automatically imported by import-tree.

Declared hosts: `eris`, `keres`, `moirai`, `hemera`, `iso`.

## Core and Bundles

`core/` contains configuration that every host imports. Infrastructure is under
`core/infra/`, shared helpers and options are under `core/utils/`, and always-on
styling is under `core/system/`. Core defines options such as `gaia.state` and
`gaia.autoStart`; hosts can set these without enabling another module.

`bundles/` contains opt-in features grouped under `programs`, `services`,
`system`, and `desktops`. Every bundle lives at
`bundles/<category>/<name>/default.nix`. Its path generates a default-off option:
`bundles/programs/broot/default.nix` provides
`gaia.programs.broot.enable`. Bundle files contain configuration only; they do
not declare their own enable option. Put relative assets, such as patches, next
to `default.nix`. See [adding-a-bundle.md](adding-a-bundle.md) and
[bundle-reference.md](bundle-reference.md).

A future `modules/` directory can hold reusable custom NixOS and Home Manager
modules. Core configuration and feature bundles can import those modules as
needed.

## Host Config

`hosts/<host>/gaia.nix` enables the bundles that host should have, for example
`gaia.programs.git.enable = true;`. `hosts/<host>/hardware.nix` is machine
specific. Hosts that run extra services keep them here too, see `hosts/keres/`
for examples. The `iso` host also has `hosts/iso/installer.nix`, which builds a
disko installer image.

## Packages

Every directory under `packages/` is a callable package. Sources are declared in
`packages/nvfetcher.toml` and generated into `packages/_sources/` by nvfetcher.
Packages that only need local files, like `eos-helpers`, use `src = ./.` and
need no nvfetcher entry. See [package-examples.md](package-examples.md).

## Secrets

sops-nix reads `.secrets.yaml`, encrypted for the age keys in `.sops.yaml`.
Bundles reference secrets through `config.sops.secrets.<name>`. Edit the file
with `just secret`.
