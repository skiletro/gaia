# Repository Structure

gaia is a flake-parts based Nix configuration. `flake.nix` delegates to
`flake-parts`, importing every module in `parts/` with import-tree:

```nix
outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./parts);
```

## Layout

| path | purpose |
|---|---|
| `parts/` | flake-parts modules that wire everything together |
| `bundles/` | feature modules, one per file or directory, grouped by category |
| `hosts/` | per-host configuration |
| `packages/` | custom packages and their sources |
| `docs/` | this documentation |
| `.secrets.yaml` | sops-nix encrypted secrets |
| `.justfile` | just recipes for common tasks |

## Parts

- `systems.nix` - the architectures this flake supports (`x86_64-linux`, `aarch64-linux`)
- `hosts.nix` - imports the bundle flake module and declares the hosts
- `packages.nix` - builds every directory under `packages/` with `callPackage`, providing the nvfetcher `sources`
- `sources.nix` - the `sources` option consumed by `packages.nix`
- `shell.nix` - the devShell
- `format.nix` - treefmt configuration

## Hosts

`parts/hosts.nix` imports `inputs.bundle.flakeModules.default` (bundle-of-nix)
and declares the hosts. For each host it imports `../bundles` and
`../hosts/${host}` with import-tree:

```nix
imports = [
  (inputs.import-tree ../bundles)
  (inputs.import-tree ../hosts/${host})
];
```

import-tree means every `.nix` file in those directories is imported as a module
automatically. Adding a file is enough, there is no registration step.

Declared hosts: `eris`, `keres`, `moirai`, `hemera`, `iso`.

## Bundles

`bundles/` holds feature modules grouped by category: `programs`, `services`,
`system`, `desktops`, `infra`, `utils`. Each bundle is a
`bundleLib.mkEnableModule` module exposing an `enable` option. A bundle is a
single file (`<name>.nix`) or a directory (`<name>/default.nix`) when it needs
additional files next to it, such as package patches applied with a relative
path like `./fix-thing.patch`. See
[adding-a-bundle.md](adding-a-bundle.md) and
[bundle-reference.md](bundle-reference.md).

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
