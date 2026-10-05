{
  stdenvNoCC,
  sources,
  ...
}:
stdenvNoCC.mkDerivation {
  inherit (sources.modern-minimal-ui-sounds) pname version src;

  phases = ["installPhase"];

  installPhase = ''
    mkdir -p $out/share/sounds
    cp -R $src "$out/share/sounds/Modern Minimal UI"
  '';
}
