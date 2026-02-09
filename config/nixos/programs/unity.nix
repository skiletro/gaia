{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.erebus.programs.unity.enable = lib.mkEnableOption "Unity and Unity Tools";

  config = lib.mkIf config.erebus.programs.unity.enable {
    environment.systemPackages = with pkgs; [
      unityhub
      (symlinkJoin {
        name = "alcom";
        paths = [ alcom ];
        nativeBuildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/ALCOM \
            --run ${lib.getExe pkgs.unityhub.fhsEnv}
        '';
      })
    ];
  };
}
