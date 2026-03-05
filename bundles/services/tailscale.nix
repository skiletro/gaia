{

  nixos =
    { config, ... }:
    {
      sops.secrets."tailscale-auth-key" = { };

      services.tailscale = {
        enable = true;
        authKeyFile = config.sops.secrets."tailscale-auth-key".path;
      };
    };

  darwin = {
    services.tailscale.enable = true;
  };

}
