{ config, ... }:
let
  inherit (config.erebus.selfhost) domain;
  subdomain = "kk";
  port = 3001;
in
{
  services.karakeep = {
    enable = true;
    meilisearch.enable = false; # what is the POINT of stateVersion if it doesn't WORK
    extraEnvironment = {
      NEXTAUTH_URL = "https://${subdomain}.${domain}";
      PORT = toString port;
      DISABLE_SIGNUPS = "true";
      DISABLE_NEW_RELEASE_CHECK = "true";
    };
  };

  erebus.selfhost.services = {
    ${subdomain} = port;
  };
}
