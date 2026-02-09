{ lib, ... }:
{
  perSystem =
    {
      pkgs,
      self',
      ...
    }:
    let
      pkgDir = ../../pkgs;
    in
    {
      packages = lib.pipe (builtins.readDir pkgDir) [
        (lib.filterAttrs (name: value: value == "directory" && name != "_sources"))
        (lib.mapAttrs (
          name: _: pkgs.callPackage "${pkgDir}/${name}" ({ inherit (self') sources; } // self'.packages)
        ))
      ];

      sources = import "${pkgDir}/_sources/generated.nix" {
        inherit (pkgs)
          fetchgit
          fetchurl
          fetchFromGitHub
          dockerTools
          ;
      };
    };
}
