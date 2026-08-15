# Package Examples

Packages are `callPackage`d from `parts/packages.nix`. Every derivation gets a
`sources` argument from the nvfetcher-generated `packages/_sources/generated.nix`,
so `inherit (sources.<name>) pname version src;` is how a package pulls its
source. Sources are declared in `packages/nvfetcher.toml` and regenerated with
`just update-sources`.

## base16-schemes

A plain `stdenv.mkDerivation` with an `installPhase`:

```nix
{
  lib,
  stdenv,
  sources,
  ...
}:
stdenv.mkDerivation {
  inherit (sources.base16-schemes) pname version src;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/themes/
    install base16/*.yaml $out/share/themes/

    runHook postInstall
  '';

  meta = {
    description = "All the color schemes for use in base16 packages";
    homepage = "https://github.com/tinted-theming/schemes";
    license = lib.licenses.mit;
  };
}
```

## liga-sf-mono-nerd-font

A `stdenvNoCC.mkDerivation` that skips all build phases and only copies files:

```nix
{
  stdenvNoCC,
  sources,
  ...
}:
stdenvNoCC.mkDerivation {
  inherit (sources.liga-sf-mono-nerd-font) pname version src;

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/share/fonts/opentype
    cp -R $src/*.otf $out/share/fonts/opentype
  '';
}
```

## owo-sh

A `stdenv.mkDerivation` that builds from a Makefile with `makeFlags` and a
`patchPhase`:

```nix
{
  pkgs,
  stdenv,
  sources,
  lib,
  ...
}:
stdenv.mkDerivation {
  inherit (sources.owo-sh) pname version src;

  makeFlags = [
    "PREFIX=${placeholder "out"}"
    "DESTDIR="
  ];

  # Ensure the bin directory exists
  preBuild = ''
    mkdir -p $out/bin
  '';

  # Install using the Makefile's install target
  installPhase = ''
    make install PREFIX=$out DESTDIR=""
  '';

  patchPhase = ''
    substituteInPlace bin/owo \
      --replace "file -bIL" "file -biL"
  '';

  nativeBuildInputs = [ pkgs.curl ];

  meta = {
    description = "Shell uploader/shortener script for whats-th.is";
    homepage = "https://owo.codes/whats-this/owo.sh/";
    license = lib.licenses.gpl3;
  };
}
```

## hyprland-preview-share-picker

A Rust package built with `rustPlatform.buildRustPackage` and a fixed
`cargoLock`:

```nix
{
  lib,
  glib,
  gtk4,
  gtk4-layer-shell,
  pkg-config,
  rustPlatform,
  sources,
  ...
}:
rustPlatform.buildRustPackage (_finalAttrs: {
  inherit (sources.hyprland-preview-share-picker)
    pname
    version
    src
    ;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    glib
    gtk4
    gtk4-layer-shell
  ];

  cargoLock = sources.hyprland-preview-share-picker.cargoLock."Cargo.lock";

  strictDeps = true;

  meta = {
    homepage = "https://github.com/WhySoBad/hyprland-preview-share-picker";
    license = lib.licenses.mit;
    mainProgram = "hyprland-preview-share-picker";
  };
})
```

## skilshot

A simple wrapper script with `pkgs.writeShellScriptBin`:

```nix
{ pkgs, lib, ... }:
pkgs.writeShellScriptBin "skilshot" ''
  selection=$(swaymsg -t get_tree | jq -r '.. | select(.pid? and .visible?) | .rect | "\(.x),\(.y) \(.width)x\(.height)"' | ${lib.getExe pkgs.slurp} -o)

  ${lib.getExe pkgs.grim} -t ppm -g "$selection" - | ${lib.getExe pkgs.satty} -f - \
    --initial-tool=brush \
    --copy-command=wl-copy \
    --actions-on-escape="save-to-clipboard,exit" \
    --brush-smooth-history-size=5 \
    --disable-notifications
''
```

All five packages are retired and their `nvfetcher.toml` sections were removed,
so these are reference only.
