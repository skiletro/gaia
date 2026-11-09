# Adding and Updating Packages

Add `packages/<name>/default.nix` to expose a flake package named `<name>`.
Package directories are discovered automatically; no registration is needed.
Use `self'.packages.<name>` inside per-system module contexts or
`nix build .#<name>` from the repository. New files must be known to Git before
a Git-backed flake can include them.

## Add a package with an upstream source

The existing `apple-emoji` package illustrates this workflow; use your own
package name and upstream when adding another package.

1. Add a section to `packages/nvfetcher.toml`. Its name is the key used to
   access the generated source metadata:

   ```toml
   [apple-emoji]
   fetch.url = "https://github.com/samuelngs/apple-emoji-linux/releases/download/$ver/AppleColorEmoji-Linux.ttf"
   src.github = "samuelngs/apple-emoji-linux"
   ```

2. Run `just update-sources`. This generates files in `packages/_sources/`;
   do not edit those generated files by hand.
3. Add `packages/<name>/default.nix`. The `sources` argument is supplied by
   `parts/packages.nix`, so the derivation can inherit its source metadata:

   ```nix
   {
     stdenvNoCC,
     sources,
     ...
   }:
   stdenvNoCC.mkDerivation {
     inherit (sources.apple-emoji) pname version src;

     phases = ["installPhase"];

     installPhase = ''
       mkdir -p $out/share/fonts/truetype
       cp -R $src $out/share/fonts/truetype/AppleColorEmoji.ttf
     '';
   }
   ```

4. Build the package with `nix build .#apple-emoji`.

See [apple-emoji](../packages/apple-emoji/default.nix) for the complete derivation.

## Installing a sound theme

Install sound theme packages through `home.packages`; their
`$out/share/sounds/<theme>` contents are then available through the user's
profile data directory. Select the theme in the relevant desktop setting, such
as GTK's `gtk-sound-theme-name`. See
[`modern-minimal-ui-sounds`](../packages/modern-minimal-ui-sounds/default.nix)
and its activation in [`styling.nix`](../core/system/styling.nix).

## Update package sources

Edit the relevant entry in `packages/nvfetcher.toml`, then run
`just update-sources` and review the generated changes under
`packages/_sources/`, including any generated lockfiles. Package derivations
refer to those sources by name. Running the recipe refreshes all entries, not
just the one you edited; review unrelated updates before committing.

Sources can also be consumed directly as `self'.sources.<name>` in per-system
module contexts, as with container images. An nvfetcher entry alone does not
create a flake package. Conversely, a package that needs no nvfetcher-managed
source only needs its derivation under `packages/<name>/`.
