{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.snac2;
in
{
  options.services.snac2 = {
    enable = lib.mkEnableOption "Enable snac2";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.snac2;
      description = "Snac2 package to use";
    };
    dir = lib.mkOption {
      type = lib.types.str;
      default = "/home/snac2";
      description = "Path to the snac2 data directory";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.snac2 = {
      isSystemUser = true;
      group = "snac2";
    };

    users.groups.snac2 = { };

    environment.systemPackages = [ cfg.package ];

    systemd.services."snac2" = {
      wantedBy = [ "network-online.target" ];
      serviceConfig = {
        Restart = "on-failure";
        ExecStart = "${lib.getExe cfg.package} httpd ${cfg.dir}";
        User = "snac2";
      };
    };
  };
}
