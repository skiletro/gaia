# Conventions

## Formatting

treefmt enforces the following, and `nix flake check` runs it as a check:

- `alejandra` - nix formatting
- `deadnix` - dead code
- `keep-sorted` - sorted blocks
- `nixf-diagnose` - nix diagnostics
- `statix` - nix lints
- `toml-sort` - toml sorting

Run `nix fmt` locally before committing.

## keep-sorted

Blocks that sit between the formatter's start and end markers are sorted
automatically and the order is enforced. Keep the entries sorted as you edit
them; the formatter does not fix them for you in every case. This applies to
`flake.nix` inputs and substituters as well as bundle and host config.

## Bundles

- One feature per file at `bundles/<category>/<name>.nix`.
- Categories: `programs`, `services`, `system`, `desktops`, `infra`, `utils`.
- The option path is `["gaia" "<category>" "<name>"]`, which creates
  `gaia.<category>.<name>.enable`.
- Enable bundles per host in `hosts/<host>/gaia.nix`, keeping entries sorted.
- `gaia.desktop = "niri"` selects the desktop. Desktops are conditional on this
  option, so enable exactly one.
- `gaia.state.system` sets the system state version; `gaia.state.home` defaults
  to it when unset.

## Generated Files

- `packages/_sources/generated.nix` and `generated.json` are nvfetcher output.
  Never edit by hand, regenerate with `just update-sources`.
- `flake.lock` is managed by nix.

## Inputs

- Inputs in `flake.nix` are sorted, and most follow `nixpkgs` with
  `inputs.nixpkgs.follows = "nixpkgs"`.
- Use `inputs` for modules, `inputs'` for per-system packages, and `self'` for
  packages built by this flake.

## Gotchas

- `parts/hosts.nix` hardcodes the user (`jamie`) and the home-manager username.
  `bundles/infra/user.nix` declares the user account with `mutableUsers = false`
  and a hashed password.
- `hosts/<host>/hardware.nix` is machine specific. Do not copy it between hosts.
- The `iso` host only enables a minimal program set and adds disko to the image.
- Host-specific services live under `hosts/<host>/`, not in `bundles/`. The
  keres host is the main example.
