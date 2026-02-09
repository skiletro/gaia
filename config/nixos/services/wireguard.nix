{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.erebus.services.wireguard.enable = lib.mkEnableOption "WireGuard";

  config = lib.mkIf config.erebus.services.wireguard.enable {
    environment.systemPackages = [ pkgs.wireguard-tools ];

    networking = {
      # Adapt rpfilter to ignore WireGuard traffic - allows WireGuard to work!
      firewall =
        let
          port = "51820"; # WireGuard endpoint port
        in
        {
          # if packets are still dropped, they will show up in dmesg
          logReversePathDrops = true;
          # wireguard trips rpfilter up
          extraCommands = ''
            ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport ${port} -j RETURN
            ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport ${port} -j RETURN
          '';
          extraStopCommands = ''
            ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport ${port} -j RETURN || true
            ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport ${port} -j RETURN || true
          '';
        };
    };
  };
}
