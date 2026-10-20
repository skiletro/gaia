{
  nixos = {
    config,
    lib,
    pkgs,
    ...
  }: let
    knot = config.services.tangled.knot;
    hostname = "git-repos.warm.vodka";
    user = "tangled-cgit";
    stateDir = "/var/lib/tangled-cgit";
    socket = config.services.fcgiwrap.instances.tangled-cgit.socket.address;
    cgitConfig = pkgs.writeText "tangled-cgitrc" ''
      root-title=warm.vodka repositories
      root-desc=Git repositories hosted on ${knot.server.hostname}
      virtual-root=/
      cache-size=0
      enable-http-clone=0
      enable-index-links=1
      enable-follow-links=1
      enable-blame=1
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
            "${./tangled-cgit-index.py}"
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
