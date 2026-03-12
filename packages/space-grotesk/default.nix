{ stdenvNoCC, fetchzip, ... }:
stdenvNoCC.mkDerivation {
  pname = "space-grotesk";
  version = "2.0.0";

  src = fetchzip {
    url = "https://github.com/floriankarsten/space-grotesk/releases/download/2.0.0/SpaceGrotesk-2.0.0.zip";
    stripRoot = false;
    sha256 = "sha256-niwd5E3rJdGmoyIFdNcK5M9A9P2rCbpsyZCl7CDv7I8=";
  };

  installPhase = ''
    mkdir -p $out/share/fonts/ttf
    mkdir -p $out/share/fonts/otf
    cp -R $src/SpaceGrotesk-2.0.0/ttf/*.ttf $out/share/fonts/ttf
    cp -R $src/SpaceGrotesk-2.0.0/ttf/static/*.ttf $out/share/fonts/ttf
    cp -R $src/SpaceGrotesk-2.0.0/otf/* $out/share/fonts/otf
  '';
}
