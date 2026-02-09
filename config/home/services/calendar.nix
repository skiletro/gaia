{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.erebus.services.calendar.enable =
    lib.mkEnableOption "calendar syncing with khal and vdirsyncer";

  config = lib.mkIf config.erebus.services.calendar.enable {
    sops.secrets = {
      "proton-calendar-url" = { };
      "proton-calendar-work-url" = { };
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
          personal = mkCalReadOnly "proton-calendar-url";
          work = mkCalReadOnly "proton-calendar-work-url";
        };
    };

    programs = {
      khal.enable = true;
      vdirsyncer.enable = true;
    };

    services.vdirsyncer.enable = lib.mkIf pkgs.stdenvNoCC.hostPlatform.isLinux true;
  };
}
