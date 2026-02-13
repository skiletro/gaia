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
