{
  lib,
  config,
  ...
}:
{
  options.erebus.programs.direnv.enable = lib.mkEnableOption "Direnv";

  config = lib.mkIf config.erebus.programs.direnv.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true; # faster implementation
      silent = true; # hides term spam w/ a bunch of variables
    };
  };
}
