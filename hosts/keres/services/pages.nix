# Service: pages
# Dependencies: Forgejo (Actions, API), Caddy
# Data location:
#   Published site trees: /var/lib/pages
#   Actions runner state: /var/lib/forgejo-runner/keres
{
  nixos = {
    config,
    lib,
    pkgs,
    keresDomain,
    ...
  }: let
    subdomain = "pages";
    siteRoot = "/var/lib/pages";
    forgejoUrl = "http://127.0.0.1:${toString config.services.forgejo.settings.server.HTTP_PORT}";
    templateDir = pkgs.writeTextDir "_pages-workflow.yml" (builtins.readFile ./pages-workflow.yml);

    # Offline registration: `forgejo forgejo-cli actions register --name keres --secret <token>`.
    # The uuid is public; the 40-character secret is the runner token and lives in sops.
    runnerUuid = "3e4b5d69-c338-4282-a986-ee86fcc7ef00";

    pagesDeploy = pkgs.writeShellApplication {
      name = "pages-deploy";
      runtimeInputs = with pkgs; [coreutils curl jq rsync];
      text = ''
        site=${siteRoot}
        forgejo=${forgejoUrl}
        src=''${1:?usage: pages-deploy <directory>}
        repo=''${GITHUB_REPOSITORY:?pages-deploy must run from a Forgejo Actions job}
        owner=''${repo%%/*}
        name=''${repo#*/}
        if [[ ! "$repo" =~ ^[A-Za-z0-9._-]+/[A-Za-z0-9._-]+$ ]] || [[ "$owner" == "." || "$owner" == ".." || "$name" == "." || "$name" == ".." ]]; then
          echo "invalid repository name: $repo" >&2
          exit 1
        fi
        if ! curl -fsS "$forgejo/api/v1/repos/$owner/$name" | jq -e '.private == false' >/dev/null; then
          echo "refusing to publish $repo: repository is private or missing" >&2
          exit 1
        fi
        workspace=$(realpath "$GITHUB_WORKSPACE")
        src=$(realpath "$src")
        if [[ "$src" != "$workspace"/* ]]; then
          echo "refusing to publish $src: not inside $workspace" >&2
          exit 1
        fi
        if [[ -z "$(ls -A "$src")" ]]; then
          echo "refusing to publish an empty directory" >&2
          exit 1
        fi
        install -d -m 0755 "$site/$owner"
        rsync -a --delete --safe-links --exclude=/.git \
          --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r \
          "$src/" "$site/$owner/$name/"
        echo "published https://${subdomain}.${keresDomain}/$owner/$name/"
      '';
    };

    pagesPrune = pkgs.writeShellApplication {
      name = "pages-prune";
      runtimeInputs = with pkgs; [coreutils curl jq];
      text = ''
        site=${siteRoot}
        forgejo=${forgejoUrl}
        declare -A keep=()
        page=1
        while :; do
          json=$(curl -fsS "$forgejo/api/v1/repos/search?limit=50&page=$page")
          count=$(jq '.data | length' <<<"$json")
          if (( count == 0 )); then
            break
          fi
          while IFS= read -r full; do
            keep["$full"]=1
          done < <(jq -r '.data[] | select(.private == false) | .full_name' <<<"$json")
          if (( count < 50 )); then
            break
          fi
          page=$((page + 1))
        done
        for dir in "$site"/*/*; do
          if [[ ! -d "$dir" ]]; then
            continue
          fi
          rel=''${dir#"$site"/}
          if [[ -z ''${keep[$rel]:-} ]]; then
            echo "pruning $rel"
            rm -rf -- "$dir"
          fi
        done
      '';
    };
  in {
    users.groups.gitea-runner = {};
    users.users.gitea-runner = {
      isSystemUser = true;
      group = "gitea-runner";
    };

    environment.systemPackages = [pagesDeploy];

    systemd.tmpfiles.rules = [
      "d ${siteRoot} 0755 gitea-runner gitea-runner -"
    ];

    # Stable uid: the module default DynamicUser changes uid on restart, which
    # would make previously published files unwritable by the next deploy.
    systemd.services."forgejo-runner-keres" = {
      after = ["forgejo.service"];
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "gitea-runner";
        Group = "gitea-runner";
      };
    };

    systemd.services.pages-prune = {
      description = "Prune Forgejo Pages output for repositories that are no longer public";
      after = ["forgejo.service" "network-online.target"];
      wants = ["network-online.target"];
      startAt = "daily";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = lib.getExe pagesPrune;
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
        pagesDeploy
      ];
    };

    services.caddy.virtualHosts."${subdomain}.${keresDomain}".extraConfig = ''
      handle /_pages-workflow.yml {
        root * ${templateDir}
        file_server
      }

      handle {
        root * ${siteRoot}
        encode zstd gzip
        try_files {path} {path}/ {path}.html
        file_server
      }
    '';
  };
}
