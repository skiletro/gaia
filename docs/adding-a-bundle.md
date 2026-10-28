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
and optional `requires` metadata. Do not call `bundleLib.mkEnableModule` or
declare an option path yourself. Another example is
`bundles/programs/spotify/default.nix`.

Bundlix automatically merges every direct, regular `.nix` file in a bundle
directory behind the same enable option. `default.nix` is the conventional
starting point, not a special entry point; do not explicitly import sibling
modules. Split larger bundles by concern, as in
[`Mango`](../bundles/desktops/mango/),
[`Noctalia`](../bundles/services/noctalia/), and
[`Helix`](../bundles/programs/helix/).

Nested directories, symlinks, and non-Nix assets are not automatically imported.
Keep value-returning Nix helpers in a nested directory and import them explicitly;
keep relative assets, such as package patches, beside the modules that use them.

For long interpolated text, keep the template in a separate non-Nix asset.
The [Signal bundle](../bundles/programs/signal/default.nix) renders
[`theme.css.mustache`](../bundles/programs/signal/theme.css.mustache) with
`pkgs.mustache-go` in a `pkgs.runCommand` derivation. It passes Stylix colours
through `builtins.toJSON` and `passAsFile`, then uses the rendered store file in
the package's build hook.

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
  nixos = {pkgs, ...}: {
    services.foo.enable = true;
    environment.systemPackages = [pkgs.foo];
  };

  home-manager = {pkgs, ...}: {
    home.packages = [pkgs.foo];
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

Desktop environments use the same rule. A host with Mango sets
`gaia.desktops.mango.enable = true`. A greeter can offer multiple enabled
desktop sessions. Autologin requires exactly one enabled desktop because it
starts that session directly.

## Examples

- [Starship](../bundles/programs/starship/default.nix): a Home Manager program bundle.
- [Tailscale](../bundles/services/tailscale/default.nix): system and user services,
  including a sops-nix secret.
- [Mango](../bundles/desktops/mango/default.nix): a desktop bundle with helper files
  and relative assets.
