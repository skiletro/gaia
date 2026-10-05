# Gaia Documentation

This documentation is for people using and maintaining this NixOS
configuration. Start with the task you need to do:

## Common tasks

- **Set up a machine or understand how the flake fits together:** [Repository
  structure](architecture.md)
- **Enable or add a feature:** [Adding a bundle](adding-a-bundle.md), then
  [Bundle reference](bundle-reference.md). See [active bundle examples](bundle-examples.md).
- **Add or update a package:** [Package examples](package-examples.md)
- **Build, deploy, update inputs, or edit secrets:** [Development](development.md)
- **Understand formatting and configuration rules:** [Conventions](conventions.md)

## How the configuration is organized

`core/` is shared configuration imported by every host. Optional features live
in `bundles/`; `hosts/<host>/gaia.nix` selects which bundles are enabled on a
machine. Host-specific hardware and services live under `hosts/<host>/`.
Packages live under `packages/`.

See [Repository structure](architecture.md) for the full layout and links to
the relevant implementation.

## Reading examples

Examples are drawn from files that still exist in this repository. Prefer the
linked source files when you need exact current settings; this documentation
explains the patterns and workflows around them.
