{
  stdenvNoCC,
  nushell,
  nvfetcher,
  git,
  nh,
  makeWrapper,
  lib,
  ...
}:
let
  home = if stdenvNoCC.hostPlatform.isDarwin then "/Users/jamie" else "/home/jamie";
  flakeLocation = "${home}/Projects/gaia";
in
stdenvNoCC.mkDerivation (attrs: {
  pname = "eos-cli";
  version = "0.2.1";

  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    nushell
    nvfetcher
    git
    nh
  ];

  NH_FLAKE = flakeLocation;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -m755 $src/eos.nu $out/bin/eos

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/eos \
      --prefix PATH : ${lib.makeBinPath attrs.buildInputs} \
      --set NH_FLAKE "${flakeLocation}" \
      --chdir "${flakeLocation}" \
      --inherit-argv0
  '';

  meta.mainProgram = "eos";
})
