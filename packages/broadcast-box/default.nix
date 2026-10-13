{
  lib,
  buildGoModule,
  buildNpmPackage,
  fetchNpmDeps,
  nodejs,
  makeWrapper,
  sources,
  ...
}: let
  inherit (sources.broadcast-box) pname version src;
  npmDeps = fetchNpmDeps {
    name = "${pname}-web-${version}-npm-deps";
    src = "${src}/web";
    hash = "sha256-THUwDCbOXc9kUVYcqtooLY76vjX72kiz78YOlAGAuuY=";
    # v2.0.2's lockfile omits registry URLs and integrity for many packages.
    postPatch = ''
      ${lib.getExe nodejs} ${./resolve-lock.mjs}
    '';
  };
  frontend = buildNpmPackage {
    pname = "${pname}-web";
    inherit version;
    src = "${src}/web";
    inherit npmDeps;
    postPatch = ''
      cp ${npmDeps}/package-lock.json package-lock.json
    '';
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
    vendorHash = "sha256-3/ZuNHU1MJD5ew7abWU81EF/G2fJ6eQLslSEnv7m+Xg=";
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
