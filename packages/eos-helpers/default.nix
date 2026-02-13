{
  lib,
  stdenvNoCC,
  nushell,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "eos-helpers";
  version = "0.2";

  src = ./.;
  buildInputs = [ nushell ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    for f in *.nu; do
      install -m755 "$f" "$out/bin/''${f%.nu}"
    done

    runHook postInstall
  '';

  meta = {
    description = "Useful scripts for use in a Nix system";
    license = lib.licenses.mit;
    inherit (nushell.meta) platforms;
  };
}
