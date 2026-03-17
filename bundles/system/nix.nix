{ self, ... }:
let
  flakeConfig = (import "${self}/flake.nix").nixConfig;

  megabytes = num: num * 1000 * 1000;

  settings = pkgs: {
    nixpkgs = {
      overlays = [
        (_final: prev: {
          inherit (prev.lixPackageSets.stable)
            nixpkgs-review
            nix-eval-jobs
            nix-fast-build
            colmena
            ;
        })
      ];
      config = {
        allowUnfree = true;
      };
    };

    nix = {
      enable = true;
      package = pkgs.lixPackageSets.stable.lix;
      channel.enable = false;
      settings = {
        extra-substituters = flakeConfig.extra-trusted-substituters;
        inherit (flakeConfig) extra-trusted-substituters extra-trusted-public-keys;
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        trusted-users = [
          "jamie"
          "root"
          "@wheel"
        ];
        warn-dirty = false;
        http-connections = 50;
        log-lines = 50;
        builders-use-substitutes = true;
        accept-flake-config = true;
        connect-timeout = 5; # seconds
        min-free = megabytes 128;
        max-free = megabytes 1000;
        auto-optimise-store = true;
      };
    };
  };
in
{
  nixos =
    { pkgs, ... }:
    {
      inherit (settings pkgs) nix nixpkgs;
    };

  darwin =
    { pkgs, ... }:
    {
      inherit (settings pkgs) nix nixpkgs;
    };

  home-manager.nixpkgs.config.allowUnfree = true;
}
