{ pkgs, pkgs', ... }:
{
  erebus.profiles.base.enable = true;

  environment.systemPackages = [
    pkgs.git
    pkgs'.eos-cli
  ];

  system.stateVersion = "25.05";
}
