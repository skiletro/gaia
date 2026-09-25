# Adding a Bundle

## Create the Bundle Directory

Create `bundles/<category>/<name>/default.nix`. Use one of the feature
categories: `programs`, `services`, `system`, or `desktops`.

For example:

```text
bundles/programs/broot/default.nix
```

The path generates `gaia.programs.broot.enable`, defaulting to `false`. The
import wrapper creates and gates the option. Bundle files contain configuration
only; do not call `bundleLib.mkEnableModule` or declare an option path yourself.
Another example is `bundles/programs/spotify/default.nix`.

Only `default.nix` files are bundle entry points. Keep helper modules and
relative assets, such as package patches, beside that file. Import helper files
from `default.nix` when needed.

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

Always-on option definitions and shared configuration belong under `core/`,
not in a bundle. Core modules do not need enable flags. A future `modules/`
directory may hold reusable custom NixOS or Home Manager modules imported by
core or bundles.

## Enable on a Host

Add the generated flag to `hosts/<host>/gaia.nix`:

```nix
gaia.programs.broot.enable = true;
```

Desktop environments use the same rule. A host with Mango sets
`gaia.desktops.mango.enable = true`. A greeter can offer multiple enabled
desktop sessions. Autologin requires exactly one enabled desktop because it
starts that session directly.
