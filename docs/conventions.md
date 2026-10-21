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

See [Adding a bundle](adding-a-bundle.md) for module placement, bundle creation,
and host enablement. The [Bundle reference](bundle-reference.md) covers
dependencies, desktop selection, and shared device options.

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
