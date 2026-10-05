{lib, ...}: {
  nixos = {config, ...}: {
    sops.secrets."tailscale-auth-key" = {};

    services.tailscale = {
      enable = true;
      authKeyFile = config.sops.secrets."tailscale-auth-key".path;
    };
  };

  home-manager = {pkgs, ...}: {
    systemd.user.services.tailscale-systray = {
      Unit = {
        Description = "Tailscale system tray";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Service.ExecStart = "${lib.getExe pkgs.tailscale} systray";
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
