{
  stdenvNoCC,
  fetchgit,
  ...
}:
# I have a license for this, I just don't know the best way to actually package
# it so I can use it in my Nix flake :)
stdenvNoCC.mkDerivation {
  pname = "pragmata-pro";
  version = "0";

  src = fetchgit {
    url = "https://github.com/bend-n/pragmata";
    name = "pragmata-pro-src";
    rev = "4e8037bf92e6113aaf4c7db1a26c9df8011d5b6e";
    sha256 = "sha256-LXjf384Bfjpm4n2nHZLv4wciyjE+HzigI+gkQ2ecf7Y=";
  };

  installPhase = ''
    mkdir -p $out/share/fonts/ttf
    cp -R $src/*.ttf $out/share/fonts/ttf
  '';
}
