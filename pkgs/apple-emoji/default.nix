{
  stdenvNoCC,
  sources,
  ...
}:
stdenvNoCC.mkDerivation {
  inherit (sources.apple-emoji) pname version src;

  phases = [ "installPhase" ];

  installPhase = ''
    mkdir -p $out/share/fonts/truetype
    cp -R $src $out/share/fonts/truetype/AppleColorEmoji.ttf
  '';
}
