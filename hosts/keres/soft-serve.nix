{ lib, ... }:
let
  subdomain = "git";
  domain = "warm.vodka";
  httpPort = 23232;
  sshPort = 2200;
in
{
  nixos = {
    users.users.soft-serve = {
      isSystemUser = true;
      group = "soft-serve";
      home = "/srv/git";
    };
    users.groups.soft-serve = { };

    systemd.tmpfiles.rules = [
      "d /srv/git 0750 soft-serve soft-serve - -"
    ];

    services.soft-serve = {
      enable = true;
      settings = {
        name = "Vodka Float";
        log_format = "text";
        http = {
          listen_addr = "127.0.0.1:${toString httpPort}";
          public_url = "https://${subdomain}.${domain}";
          cors.allowed_origins = [ "https://${subdomain}.${domain}" ];
        };
        git.listen_addr = "127.0.0.1:9418";
        ssh = {
          listen_addr = ":${toString sshPort}";
          public_url = "ssh://${subdomain}.${domain}";
        };
        initial_admin_keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINnFEMa0S9zuA5cVg+Ktazz9gEevkDCNYIDX0WAMxcAC eos"
        ];
      };
    };

    systemd.services.soft-serve = {
      serviceConfig.PrivateMounts = lib.mkForce false;
      serviceConfig.PrivateUsers = lib.mkForce false;
      serviceConfig.DynamicUser = lib.mkForce false;
      serviceConfig.User = lib.mkForce "soft-serve";
      serviceConfig.Group = lib.mkForce "soft-serve";
      serviceConfig.StateDirectory = lib.mkForce "";
      serviceConfig.WorkingDirectory = lib.mkForce "/srv/git";
      serviceConfig.ExecPaths = lib.mkForce "/srv/git";
      environment.SOFT_SERVE_DATA_PATH = lib.mkForce "/srv/git";
      serviceConfig.CapabilityBoundingSet = lib.mkForce [ "CAP_NET_BIND_SERVICE" ];
      serviceConfig.AmbientCapabilities = lib.mkForce [ "CAP_NET_BIND_SERVICE" ];
    };

    services.caddy.virtualHosts."${subdomain}.${domain}".extraConfig = ''
      handle / {
        header Content-Type text/html
        respond `${
        # html
        ''
        <!DOCTYPE html>
        <html lang="en" class="antialiased">
          <head>
            <meta charset="UTF-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
            <title>vodka float</title>
            <style>
            * { margin: 0; padding: 0 }
            body {
              height: 100dvh; width: 100dvw;
              overflow: hidden;
              display: flex; justify-content: center; align-items: center;
              font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
              -webkit-font-smoothing: antialiased;
              -moz-osx-font-smoothing: grayscale;
              color: #e4e4e7; background: #0a0a0a;
            }
            div { text-align: center }
            h1 { font-size: 1.75rem; font-weight: 700; margin-bottom: 0.75rem; text-wrap: balance; color: #fafafa }
            p { font-size: 1rem; margin-bottom: 1.5rem; color: #a1a1aa }
            code {
              display: inline-block;
              font-family: "JetBrains Mono", "Fira Code", "Cascadia Code", "SF Mono", monospace;
              font-size: 1rem;
              padding: 0.5rem 1rem;
              border-radius: 8px;
              background: #141414;
              color: #e4e4e7;
              cursor: copy;
              transition: background 150ms ease-out;
            }
            code:hover { background: #1a1a1a }
            .cmd::before {
              content: "$ ";
              font-weight: 600;
              color: #52525b;
              font-family: inherit;
            }
            </style>
          </head>
          <body>
            <div>
              <h1>vodka float</h1>
              <p>access the git forge over SSH</p>
              <code class="cmd" onclick="navigator.clipboard?.writeText(this.textContent)">ssh -p ${toString sshPort} ${subdomain}.${domain}</code>
            </div>
          </body>
        </html>
        ''}` 200
      }

      handle {
        reverse_proxy 127.0.0.1:${toString httpPort}
      }
    '';

    networking.firewall.allowedTCPPorts = [ sshPort ];
  };
}
