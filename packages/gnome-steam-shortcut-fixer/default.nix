{
  stdenvNoCC,
  fetchFromGitHub,
  jq,
  curlMinimal,
  ...
}:
let
  pname = "gnome-steam-shortcut-fixer";
  version = "ec5003140917f18ceccdff771ed8c4aa41b60c43";
in
stdenvNoCC.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "beedywool";
    repo = "Gnome-Steam-Shortcut-Fixer";
    rev = version;
    sha256 = "sha256-BPe4Q8oi97AYjnEcB+V7iiwJuAhBQSqwWIPWsXQyA7g=";
  };

  nativeBuildInputs = [
    jq
    curlMinimal
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp gnome-steam-shortcut-fixer.sh $out/bin/${pname}
  '';

  meta = {
    description = "Simple utility to fix Steam shortcuts so the icon of the games RUNNING WITH PROTON is displayed correctly on GNOME instead of the default 'no icon' program";
    platforms = [ "x86_64-linux" ];
    mainProgram = pname;
  };

}
