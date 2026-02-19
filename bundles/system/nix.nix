let
  nixpkgs.config = {
    allowUnfree = true;
  };

  nix = {
    enable = true;
    channel.enable = false;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "jamie"
        "root"
        "@wheel"
      ]; # Fixes some "cannot connect to socket" issues
      warn-dirty = false;
      http-connections = 50;
      log-lines = 50;
      builders-use-substitutes = true;
      accept-flake-config = true;
    };
  };
in
{
  nixos = { inherit nix nixpkgs; };

  darwin = { inherit nix nixpkgs; };

  home-manager = { inherit nixpkgs; };
}
