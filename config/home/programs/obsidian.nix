{ lib, config, ... }:
{
  options.erebus.programs.obsidian.enable = lib.mkEnableOption "Obsidian";

  config = lib.mkIf config.erebus.programs.obsidian.enable {
    programs.obsidian = {
      enable = true;
      vaults = {
        personal = {
          enable = true;
          target = "Vault"; # /home/jamie/Vault
        };
      };
    };
  };
}
