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

Blocks between formatter start and end markers are sorted automatically and the
order is enforced. Keep entries sorted as you edit them. This applies to
`flake.nix` inputs and substituters as well as bundle and host config.

## Core and Bundles

- Always-on configuration belongs under `core/`. Infrastructure lives in
  `core/infra/`, shared options and helpers in `core/utils/`, and always-on
  styling in `core/system/`.
- Optional features belong under `bundles/<category>/<name>/default.nix`.
  Categories are `programs`, `services`, `system`, and `desktops`.
- Each bundle path generates a default-off option. For example,
  `bundles/programs/broot/default.nix` creates
  `gaia.programs.broot.enable`.
- Do not call `bundleLib.mkEnableModule` from bundle files. The importer derives
  and gates the option from the path.
- Only `default.nix` is imported as a bundle entry point. Keep helper Nix files
  and relative assets, such as patches, next to it.
- Enable bundles per host in `hosts/<host>/gaia.nix`, keeping sorted blocks
  ordered. `gaia.desktops.mango.enable = true` enables Mango.
- Greeters can offer multiple enabled desktop sessions. Autologin requires
  exactly one enabled desktop.
- Use a future `modules/` directory for reusable custom NixOS or Home Manager
  modules if that becomes useful. Do not put always-on policy or optional
  feature selection there.
- `gaia.state.system` sets the system state version. `gaia.state.home` defaults
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
  `core/infra/user.nix` declares the user account with `mutableUsers = false`
  and a hashed password.
- `hosts/<host>/hardware.nix` is machine specific. Do not copy it between hosts.
- The `iso` host enables a minimal program set and adds disko to the image.
- Host-specific services live under `hosts/<host>/`, not in bundles. The Keres
  host is the main example.
