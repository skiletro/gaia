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
  };
})
