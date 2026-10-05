# Adding and Updating Packages

Packages are built from each directory under `packages/`. The flake wires them
through `parts/packages.nix` and makes them available as
`self'.packages.<name>` inside modules or `nix build .#<name>` from the
repository.

## Add a package with an upstream source

1. Add a section to `packages/nvfetcher.toml`. The section name is the Nix
   package name:

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

The current derivation is [`packages/apple-emoji/default.nix`](../packages/apple-emoji/default.nix);
use it as the source of truth if the example and implementation differ.

## Alternative derivation shapes

Not every derivation needs the same build phases. The active
[`proton-cachyos_x86_64_v3`](../packages/proton-cachyos_x86_64_v3/default.nix)
package unpacks a fetched archive and adjusts its compatibility tool metadata.

## Update package sources

Edit the relevant entry in `packages/nvfetcher.toml`, then run
`just update-sources` and review the generated changes under
`packages/_sources/`. Package derivations refer to those sources by name.
