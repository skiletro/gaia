# Conventions

## Formatting

[treefmt](../parts/format.nix) runs the following tools, and `nix flake check`
runs its formatting check:

- `alejandra` - nix formatting
- `deadnix` - dead code
- `just` - recipe formatting
- `keep-sorted` - sorted blocks
- `nixf-diagnose` - nix diagnostics
- `statix` - nix lints
- `toml-sort` - toml sorting
- `nufmt` - Nushell formatting

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

- `packages/_sources/` contains nvfetcher output, including source metadata and
  generated lockfiles. Regenerate it with `just update-sources` rather than
  editing it by hand.
- `flake.lock` is managed by Nix; update it with `just update-inputs`.

## Inputs

Use `inputs` for flake inputs and their modules, `inputs'` for system-specific
input outputs, and `self'` for this flake's system-specific outputs, such as
`self'.packages`. `inputs'` and `self'` are available in per-system contexts,
including the NixOS and Home Manager modules wired by bundlix.

## Host maintenance

- `hosts/<host>/hardware.nix` is machine specific. Do not copy it between hosts.
- The account name is set in both [host wiring](../parts/hosts.nix) and
  [user configuration](../core/infra/user.nix); update both when renaming it.
  Users are immutable: interactive password changes are not a durable
  replacement for updating the declared password hash. Keep SSH access working
  when changing authorized keys; see [Remote deployment](development.md#remote-deployment).
- Keep services specific to one machine under `hosts/<host>/`; use bundles for
  reusable features. Keres provides examples of host-specific services.
- See [Installer image](development.md#installer-image) for building the
  installer and installation risks.
