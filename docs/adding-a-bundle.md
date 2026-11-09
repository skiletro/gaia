# Adding a Bundle

## Create the Bundle Directory

Create `bundles/<category>/<name>/default.nix`. Categories are directories under
`bundles/`; existing categories are `programs`, `services`, `system`, and `desktops`.

For example:

```text
bundles/programs/broot/default.nix
```

The path generates `gaia.programs.broot.enable`, defaulting to `false`. Bundlix
creates and gates the option through the `bundle.autoImport` settings in
[`parts/hosts.nix`](../parts/hosts.nix). Bundle files contain feature configuration
and optional `requires` metadata; the enable option is generated for you.

For larger bundles, split related settings into sibling files such as
`binds.nix` or `theme.nix`. These files are loaded together automatically; no
explicit imports are needed. Keep patches and other assets alongside them.
See [bundle discovery](bundle-reference.md#path-derived-enable-options) for
which files are loaded.

## Write the Configuration

A bundle with no top-level module arguments can be a plain attrset:

```nix
{
  home-manager.programs.broot.enable = true;
}
```

Use `nixos` for system configuration and `home-manager` for user configuration.
Both may appear in one bundle:

```nix
{
  nixos = {
    services.tailscale.enable = true;
  };

  home-manager = {pkgs, ...}: {
    home.packages = [pkgs.tailscale];
  };
}
```

If the bundle needs top-level module arguments, use a module function, for
example `{lib, inputs', ...}: { ... }`. Platform blocks also receive their
usual module arguments, including `pkgs` and `config`.

If the bundle depends on another bundle, declare `requires` metadata and enable
the dependency separately on each host. See
[bundle-reference.md](bundle-reference.md#bundle-requirements).

Always-on option definitions and shared configuration belong under `core/`,
not in a bundle. Core modules do not need enable flags.

## Enable on a Host

Add the generated flag to `hosts/<host>/gaia.nix`:

```nix
gaia.programs.broot.enable = true;
```

Desktop environments use the same enable flag, such as
`gaia.desktops.mango.enable = true`. A new desktop bundle must also register its
login session; see [Mango's UWSM configuration](../bundles/desktops/mango/default.nix).
For compatibility with [autologin](../bundles/system/autologin/default.nix), use
the session name `<bundle-name>-uwsm.desktop`. Autologin requires exactly one
enabled desktop; the greeter can offer multiple registered sessions. See
[desktop sessions](bundle-reference.md#desktop-sessions) for host setup.

## Examples

- [Starship](../bundles/programs/starship/default.nix): a Home Manager program bundle.
- [Tailscale](../bundles/services/tailscale/default.nix): system and user services,
  including a sops-nix secret.
- [Mango](../bundles/desktops/mango/default.nix): a desktop bundle with helper files
  and relative assets.
