{
  lib,
  stdenvNoCC,
  sources,
  ...
}:
stdenvNoCC.mkDerivation rec {
  inherit (sources.proton-cachyos_x86_64_v3) pname version src;

  buildCommand = ''
    mkdir -p $out
    tar -C $out --strip=1 -x -f ${src}
    sed -i -r 's|"proton-.*"|"Proton-CachyOS x86-64-v3"|' $out/compatibilitytool.vdf
  '';

  meta = {
    description = "Compatibility tool for Steam Play based on Wine and additional components";
    license = lib.licenses.bsd3;
    platforms = [ "x86_64-linux" ];
  };
}
