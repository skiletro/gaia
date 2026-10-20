{
  nixos = {
    config,
    lib,
    pkgs,
    ...
  }: let
    subdomain = "git";
    domain = "warm.vodka";

    knot = config.services.tangled.knot;
    hostname = "${subdomain}.${domain}";
    user = "tangled-cgit";
    stateDir = "/var/lib/tangled-cgit";
    socket = config.services.fcgiwrap.instances.tangled-cgit.socket.address;
    themeAssets = pkgs.writeTextDir "theme.css" (builtins.readFile ./theme.css);
    readmePython = pkgs.python3.withPackages (ps: [ps.markdown ps.docutils ps.nh3]);
    readmeFilter = pkgs.writeShellScript "tangled-cgit-readme" ''
      exec ${readmePython}/bin/python3 ${./readme.py} "$@"
    '';
    headInclude = pkgs.writeText "tangled-cgit-head.html" ''
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <meta name="color-scheme" content="light dark">
    '';
    cgitConfig = pkgs.writeText "tangled-cgitrc" ''
      root-title=warm.vodka repositories
      root-desc=Git repositories hosted on ${knot.server.hostname}
      virtual-root=/
      css=/cgit.css
      css=/theme.css
      head-include=${headInclude}
      cache-size=0
      enable-http-clone=0
      enable-index-links=1
      enable-follow-links=1
      enable-blame=1
      about-filter=${readmeFilter}
      mimetype.png=image/png
      mimetype.jpg=image/jpeg
      mimetype.jpeg=image/jpeg
      mimetype.gif=image/gif
      mimetype.webp=image/webp
      mimetype.avif=image/avif
      mimetype.svg=image/svg+xml
      ${lib.concatMapStringsSep "\n" (name: "readme=:${name}") knot.repo.readme}
      include=${stateDir}/repositories.cgitrc
    '';
    sandbox = {
      SupplementaryGroups = [config.users.users.${knot.gitUser}.group];
      # Mount only the repositories back into an otherwise empty Knot state
      # directory. This also bypasses its private home-directory permissions.
      TemporaryFileSystem = ["${knot.stateDir}:ro"];
      BindReadOnlyPaths = [knot.repo.scanPath];
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      NoNewPrivileges = true;
      CapabilityBoundingSet = "";
      ProtectControlGroups = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      RestrictSUIDSGID = true;
      UMask = "0027";
    };
  in {
    users.users.${user} = {
      isSystemUser = true;
      group = user;
    };
    users.groups.${user} = {};

    systemd.services.tangled-cgit-index = {
      description = "Discover Knot repositories and resolve Tangled metadata for cgit";
      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"];
      requires = ["knot.service"];
      after = ["network-online.target" "knot.service"];
      serviceConfig =
        sandbox
        // {
          Type = "oneshot";
          User = user;
          Group = user;
          StateDirectory = "tangled-cgit";
          StateDirectoryMode = "0750";
          TimeoutStartSec = "5min";
          RestrictAddressFamilies = ["AF_UNIX" "AF_INET" "AF_INET6"];
          ExecStart = lib.escapeShellArgs [
            "${pkgs.python3}/bin/python3"
            "${./index.py}"
            "--repo-root"
            (toString knot.repo.scanPath)
            "--state-dir"
            stateDir
            "--knot-url"
            "http://127.0.0.1:${lib.last (lib.splitString ":" knot.server.listenAddr)}"
            "--knot-host"
            knot.server.hostname
            "--plc-url"
            knot.server.plcUrl
          ];
        };
    };

    systemd.timers.tangled-cgit-index = {
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "1min";
        OnUnitInactiveSec = "1min";
        AccuracySec = "5s";
      };
    };

    services.fcgiwrap.instances.tangled-cgit = {
      process = {
        inherit user;
        group = user;
      };
      socket = {
        inherit (config.services.caddy) user group;
        mode = "0600";
      };
    };

    systemd.services.fcgiwrap-tangled-cgit = {
      requires = ["tangled-cgit-index.service"];
      after = ["tangled-cgit-index.service"];
      environment = {
        GIT_CONFIG_NOSYSTEM = "1";
        GIT_CONFIG_GLOBAL = toString (pkgs.writeText "tangled-cgit-gitconfig" ''
          [safe]
            directory = ${knot.repo.scanPath}/*
        '');
      };
      serviceConfig =
        sandbox
        // {
          PrivateNetwork = true;
          RestrictAddressFamilies = ["AF_UNIX"];
        };
    };

    services.caddy.virtualHosts.${hostname}.extraConfig = ''
      # About-page SVGs are repository content, not executable site assets.
      @readmeSvg path_regexp readme_svg (?i)/about/.*[.]svg$
      header @readmeSvg Content-Security-Policy "sandbox; default-src 'none'; style-src 'unsafe-inline'"
      handle /theme.css {
        root * ${themeAssets}
        file_server
      }
      @assets path /cgit.css /cgit.js /cgit.png /favicon.ico /robots.txt
      handle @assets {
        root * ${pkgs.cgit}/cgit
        file_server
      }
      handle {
        reverse_proxy unix/${socket} {
          transport fastcgi {
            env SCRIPT_FILENAME ${pkgs.cgit}/cgit/cgit.cgi
            env SCRIPT_NAME ""
            env PATH_INFO {http.request.uri.path}
            env CGIT_CONFIG ${cgitConfig}
          }
        }
      }
    '';
  };
}
