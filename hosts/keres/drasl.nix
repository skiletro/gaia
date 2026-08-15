{
  nixos = {config, ...}: let
    subdomain = "drasl";
    domain = "warm.vodka";
    port = 3002;
  in {
    sops.secrets."pocketid-drasl-secret" = {
      mode = "444";
    };

    services.drasl = {
      enable = true;
      settings = {
        Domain = "${subdomain}.${domain}";
        BaseURL = "https://${subdomain}.${domain}";
        InstanceName = "Martini";
        ApplicationOwner = "warm.vodka";
        ListenAddress = "0.0.0.0:${toString port}";
        DefaultAdmins = ["jamie"];
        AllowPasswordLogin = false;
        RegistrationOIDC = [
          {
            Name = "Methanol";
            Issuer = "https://sso.warm.vodka";
            ClientID = "9e7a2c41-a937-47c1-bb6b-c100f21e4be9";
            ClientSecretFile = config.sops.secrets.pocketid-drasl-secret.path;
            PKCE = true;
            AllowChoosingPlayerName = true;
          }
        ];
      };
    };

    services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
      reverse_proxy :${toString port}
    '';
  };
}
