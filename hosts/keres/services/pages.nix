# Service: pages
# Dependencies: Forgejo (Actions, API), Caddy
# Data location:
#   git-pages storage: /var/lib/git-pages
#   Actions runner state: /var/lib/forgejo-runner/keres
{
  nixos = {
    config,
    inputs',
    lib,
    pkgs,
    keresDomain,
    ...
  }: let
    subdomain = "p";
    stateDir = "/var/lib/git-pages";
    dataDir = "${stateDir}/data";
    forgejoUrl = "http://127.0.0.1:${toString config.services.forgejo.settings.server.HTTP_PORT}";
    gitPages = inputs'.git-pages.packages.default;

    # Offline registration: `forgejo forgejo-cli actions register --name keres --secret <token>`.
    # The uuid is public; the 40-character secret is the runner token and lives in sops.
    runnerUuid = "3e4b5d69-c338-4282-a986-ee86fcc7ef00";

    gitPagesConfig = pkgs.writeText "git-pages.toml" ''
      [server]
      pages = "tcp/127.0.0.1:3100"
      proxy = "tcp/127.0.0.1:3101"
      metrics = "tcp/127.0.0.1:3102"
      https = "-"

      [storage]
      type = "fs"
      [storage.fs]
      root = "${dataDir}"

      # user.p.<domain>/<repo>/ maps to git.<domain>/user/<repo>, branch pages.
      # The index site user.p.<domain>/ maps to git.<domain>/user/pages, branch main.
      [[wildcard]]
      domain = "${subdomain}.${keresDomain}"
      clone-url = "https://git.${keresDomain}/<user>/<project>.git"
      index-repo = "pages"
      index-repo-branch = "main"
      authorization = "forgejo"

      [limits]
      allowed-repository-url-prefixes = ["https://git.${keresDomain}/"]
      max-site-size = "1G"
      update-timeout = "5m"
    '';

    # git-pages stores content independently of the repository, so it does not notice
    # when a repository becomes private or is deleted. Codeberg Pages leaves those
    # sites online; GitHub and GitLab tie site access to repository visibility. Keep
    # the stricter behavior so a visibility change cannot silently leave content public.
    pagesPrune = pkgs.writeShellApplication {
      name = "git-pages-prune";
      runtimeInputs = with pkgs; [coreutils curl findutils jq] ++ [gitPages];
      text = ''
        site=${dataDir}/site
        forgejo=${forgejoUrl}
        config=${gitPagesConfig}

        if [[ ! -d "$site" ]] || [[ -z "$(find "$site" -mindepth 2 -maxdepth 2 -type f -print -quit)" ]]; then
          exit 0
        fi

        if ! repositories=$(curl -fsS --max-time 10 "$forgejo/api/v1/repos/search?limit=1"); then
          echo "refusing to prune: repository search failed" >&2
          exit 1
        fi
        # A search that returns no repositories at all is far more likely to be a
        # broken endpoint or configuration than a truly empty instance; wiping
        # every site on that signal is not worth the convenience.
        if [[ "$(jq '.data | length' <<<"$repositories")" == 0 ]]; then
          echo "refusing to prune: repository search returned nothing" >&2
          exit 1
        fi

        tmp=$(mktemp -d)
        trap 'rm -rf "$tmp"' EXIT
        pruned=0

        while IFS= read -r -d "" manifest; do
          rel=''${manifest#"$site"/}
          domain=''${rel%%/*}
          project=''${rel#*/}

          if [[ ! "$domain" =~ ^([a-z0-9]([a-z0-9-]*[a-z0-9])?)\.${subdomain}\.${keresDomain}$ ]]; then
            continue
          fi
          owner=''${BASH_REMATCH[1]}
          # .index is the only project name that starts with a dot; .tmp* files are
          # git-pages staging artifacts, not sites.
          if [[ "$project" != ".index" && ( "$project" == .* || ! "$project" =~ ^[A-Za-z0-9._-]+$ ) ]]; then
            continue
          fi
          if [[ "$project" == ".index" ]]; then
            name=pages
          else
            name=$project
          fi

          status=$(curl -sS -o "$tmp/repo.json" -w '%{http_code}' "$forgejo/api/v1/repos/$owner/$name") || status=000
          case "$status" in
            200)
              if jq -e '.private == false' "$tmp/repo.json" >/dev/null; then
                continue
              fi
              ;;
            404 | 403) ;;
            *)
              echo "skipping $domain/$project: repository lookup returned HTTP $status" >&2
              continue
              ;;
          esac

          echo "pruning $domain/$project"
          if ! git-pages -config "$config" -delete-site "$domain/$project" -reason "repository is no longer public"; then
            echo "failed to prune $domain/$project" >&2
            continue
          fi
          pruned=$((pruned + 1))
        done < <(find "$site" -mindepth 2 -maxdepth 2 -type f -print0)

        echo "pruned $pruned site(s)"
      '';
    };
  in {
    users.groups = {
      gitea-runner = {};
      git-pages = {};
    };
    users.users = {
      gitea-runner = {
        isSystemUser = true;
        group = "gitea-runner";
      };
      git-pages = {
        isSystemUser = true;
        group = "git-pages";
      };
    };

    systemd.services.git-pages = {
      description = "git-pages static site server";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];
      serviceConfig = {
        User = "git-pages";
        Group = "git-pages";
        WorkingDirectory = stateDir;
        StateDirectory = "git-pages";
        StateDirectoryMode = "0750";
        ExecStart = "${lib.getExe gitPages} -config ${gitPagesConfig}";
        Restart = "on-failure";
        RestartSec = 5;
        PrivateTmp = true;
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        ReadWritePaths = [stateDir];
      };
    };

    systemd.services.git-pages-prune = {
      description = "Prune git-pages sites whose Forgejo repository is no longer public";
      after = ["git-pages.service" "forgejo.service" "network-online.target"];
      wants = ["network-online.target"];
      startAt = "daily";
      serviceConfig = {
        Type = "oneshot";
        User = "git-pages";
        Group = "git-pages";
        StateDirectory = "git-pages";
        StateDirectoryMode = "0750";
        ExecStart = lib.getExe pagesPrune;
      };
    };

    # Stable uid: the module default DynamicUser changes uid on restart, which
    # would make the runner's persistent state unwritable by the next start.
    systemd.services."forgejo-runner-keres" = {
      after = ["forgejo.service"];
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "gitea-runner";
        Group = "gitea-runner";
      };
    };

    sops.secrets."forgejo-runner-token" = {
      restartUnits = ["forgejo-runner-keres.service"];
    };

    services.forgejo-runner.instances.keres = {
      enable = true;
      settings = {
        runner.labels = ["native:host"];
        server.connections.default = {
          url = forgejoUrl;
          uuid = runnerUuid;
        };
      };
      secrets.server.connections.default.token_url = config.sops.secrets."forgejo-runner-token".path;
      # Defining hostPackages discards the module default, so the default
      # toolchain that actions need is restated here alongside our additions.
      hostPackages = [
        pkgs.bash
        pkgs.coreutils
        pkgs.curl
        pkgs.gawk
        pkgs.gnused
        pkgs.nodejs
        pkgs.wget
        config.nix.package
        pkgs.gnutar
        pkgs.git-pages-cli
        pkgs.jq
      ];
    };

    # On-demand TLS lets Caddy issue a certificate for a user subdomain only after
    # git-pages reports that it serves that domain. The first deploy uses the apex
    # certificate via `git-pages-cli --server`, so there is no chicken-and-egg.
    services.caddy.globalConfig = ''
      on_demand_tls {
        permission http http://127.0.0.1:3101
      }
    '';

    services.caddy.virtualHosts."*.${subdomain}.${keresDomain}".extraConfig = ''
      tls {
        on_demand
      }

      encode zstd gzip
      reverse_proxy 127.0.0.1:3100
    '';

    services.caddy.virtualHosts."${subdomain}.${keresDomain}".extraConfig = ''
      handle / {
        respond `Sites are served at https://<user>.${subdomain}.${keresDomain}/<repo>.` 200
      }

      handle {
        respond "Not Found" 404
      }
    '';
  };
}
