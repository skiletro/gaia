# Adding a Bundle

## Create the File

Create `bundles/<category>/<name>.nix`, using the category that fits the
feature: `programs`, `services`, `system`, `desktops`, `infra`, `utils`.

Start from this template:

```nix
{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "<category>" "<name>"] {
  nixos = {
  };
  home-manager = {
  };
}
```

`mkEnableModule` takes the path where the `enable` option is created. This
exposes `gaia.<category>.<name>.enable`. Nothing in the bundle is applied until
that option is enabled.

## Fill in the Blocks

- `nixos` for system config. Add `pkgs` to the function args when you need it:

  ```nix
  nixos = {pkgs, ...}: {
    services.foo.enable = true;
    environment.systemPackages = [pkgs.foo];
  };
  ```

- `home-manager` for user config, same pattern:

  ```nix
  home-manager = {pkgs, config, ...}: {
    home.packages = [pkgs.foo];
  };
  ```

Both blocks can be used in the same bundle. The minimal case is a single line:

```nix
{bundleLib, ...}:
bundleLib.mkEnableModule ["gaia" "programs" "opencode"] {
  home-manager.programs.opencode.enable = true;
}
```

## Enable on a Host

Add the flag to `hosts/<host>/gaia.nix`, keeping the block sorted:

```nix
gaia.programs.<name>.enable = true;
```
