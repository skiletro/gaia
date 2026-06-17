{ self, ... }:
{
  nixos = {
    programs.nh = {
      enable = true;
      flake = "${self}";
      clean = {
        enable = true;
        extraArgs = "--keep-since 4d --keep 3";
      };
    };
  };
}
