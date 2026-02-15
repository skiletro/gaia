{ lib, ... }:
{
  home-manager =
    { pkgs, config, ... }:
    {
      sops.secrets = {
        "calendar-personal" = { };
        "calendar-work" = { };
      };

      accounts.calendar = {
        basePath = ".calendars";

        accounts =
          let
            mkCalReadOnly = name: {
              khal = {
                enable = true;
                readOnly = true;
              };
              remote.type = "http";
              vdirsyncer = {
                enable = true;
                urlCommand = [
                  (pkgs.writeShellScript "fetch-${lib.removeSuffix "-url" name}" "cat ${
                    config.sops.secrets.${name}.path
                  }").outPath
                ];
              };
            };
          in
          {
            personal = mkCalReadOnly "calendar-personal";
            work = mkCalReadOnly "calendar-work";
          };
      };

      programs = {
        khal.enable = true;
        vdirsyncer.enable = true;
      };

      services.vdirsyncer.enable = lib.mkIf pkgs.stdenvNoCC.hostPlatform.isLinux true;
    };
}
