{
  stdenvNoCC,
  fetchgit,
  ...
}:
# I have a license for this, I just don't know the best way to actually package
# it so I can use it in my Nix flake :)
stdenvNoCC.mkDerivation {
  pname = "pragmata-pro-nf";
  version = "0";

  src = fetchgit {
    url = "https://github.com/nabato/ligaturized-pragmata-pro-mono-nerd-font-propo";
    name = "pragmata-pro-nf-src";
    rev = "048ebfbfc486c8161dba2c9e30522e679aebb6c3";
    sha256 = "sha256-2xpnl2O0eauJOgdsfbhdhea8LXt1CHk5YEe6gIbf3kA=";
  };

  installPhase = ''
    mkdir -p $out/share/fonts/ttf
    cp -R $src/*.ttf $out/share/fonts/ttf
  '';
}
