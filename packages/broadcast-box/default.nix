{
  lib,
  buildGoModule,
  buildNpmPackage,
  makeWrapper,
  sources,
  ...
}: let
  inherit (sources.broadcast-box) pname version src;
  frontend = buildNpmPackage {
    pname = "${pname}-web";
    inherit version;
    src = "${src}/web";
    npmDepsHash = "sha256-wIEsiJI9SVwMEIAOW5Mubg8yyPXlwTEKNQGmSvey4MY=";
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r build $out/
      runHook postInstall
    '';
  };
in
  buildGoModule {
    inherit pname version src;
    vendorHash = "sha256-YHFPZuZlgPrYo072pBU47vfGKwjr62YPCT5S3gAjhuI=";
    proxyVendor = true;
    subPackages = ["."];

    nativeBuildInputs = [makeWrapper];
    postInstall = ''
      mkdir -p $out/share/broadcast-box
      cp -r ${frontend}/build/. $out/share/broadcast-box/
    '';
    postFixup = ''
      wrapProgram $out/bin/broadcast-box \
        --set-default FRONTEND_PATH $out/share/broadcast-box
    '';

    passthru = {inherit frontend;};
    meta = {
      description = "WebRTC broadcast server";
      homepage = "https://github.com/Glimesh/broadcast-box";
      license = lib.licenses.mit;
      platforms = lib.platforms.unix;
      mainProgram = pname;
    };
  }
