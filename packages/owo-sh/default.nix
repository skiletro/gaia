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
