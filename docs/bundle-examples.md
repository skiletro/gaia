# Bundle Examples

These examples link to active configuration so they remain grounded in
settings used by this flake.

## Simple bundle

[`bundles/programs/starship/default.nix`](../bundles/programs/starship/default.nix)
shows a Home Manager program bundle. Its path provides the
`gaia.programs.starship.enable` flag; the host selects it in
`hosts/<host>/gaia.nix`.

## System and user configuration

[`bundles/services/tailscale/default.nix`](../bundles/services/tailscale/default.nix)
configures the system service and a user-level tray service in one bundle. It
also demonstrates reading a sops-nix secret path. The host must separately
enable `gaia.services.tailscale.enable`.

## Desktop bundle

[`bundles/desktops/mango/default.nix`](../bundles/desktops/mango/default.nix)
shows a desktop bundle with helper files and relative assets beside its
`default.nix`.

For the creation steps and module shape, see [Adding a Bundle](adding-a-bundle.md).
