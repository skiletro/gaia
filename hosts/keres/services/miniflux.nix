# Service: miniflux
# Dependencies: shared PostgreSQL; Caddy reverse proxy; Pocket ID OIDC; sops-nix secret provisioning
# Data location:
#   Shared PostgreSQL cluster (database miniflux / role miniflux): /var/lib/postgresql/16
{
  nixos = {
    config,
    pkgs,
    keresDomain,
    ...
  }: let
    subdomain = "miniflux";
    port = 3010;
    # In Settings → Custom CSS, paste this as the first line:
    # @import url("/gaiaTheme.css");
    # Also add https://miniflux.warm.vodka to "External font hosts" and save:
    # Miniflux uses that allowlist for imported CSS too (required by its CSP).
    # Served at https://miniflux.warm.vodka/gaiaTheme.css; follows Stylix on rebuild.
    theme = pkgs.writeTextDir "gaiaTheme.css" (
      with config.lib.stylix.colors.withHashtag;
      # css
        ''
          /* Override every built-in theme, including the system colour scheme. */
          html:root {
            color-scheme: dark;
            --body-color: ${base05};
            --body-background: ${base00};
            --hr-border-color: ${base03};
            --title-color: ${base05};
            --link-color: ${base0D};
            --link-focus-color: ${base0C};
            --link-hover-color: ${base0C};
            --link-visited-color: ${base0E};

            --header-list-border-color: ${base03};
            --header-link-color: ${base05};
            --header-link-focus-color: ${base0C};
            --header-link-hover-color: ${base0C};
            --header-active-link-color: ${base0D};
            --page-header-title-color: ${base05};
            --page-header-title-border-color: ${base03};
            --logo-color: ${base05};
            --logo-hover-color-span: ${base0D};

            --table-border-color: ${base03};
            --table-th-background: ${base01};
            --table-th-color: ${base05};
            --table-tr-hover-background-color: ${base02};
            --table-tr-hover-color: ${base05};
            --button-primary-border-color: ${base0D};
            --button-primary-background: ${base0D};
            --button-primary-color: ${base00};
            --button-primary-focus-border-color: ${base0C};
            --button-primary-focus-background: ${base0C};
            --input-border: 1px solid ${base03};
            --input-background: ${base01};
            --input-color: ${base05};
            --input-placeholder-color: ${base04};
            --input-focus-color: ${base05};
            --input-focus-border-color: ${base0D};
            --input-focus-box-shadow: 0 0 0 1px ${base0D};

            --alert-color: ${base05};
            --alert-background-color: ${base02};
            --alert-border-color: ${base03};
            --alert-success-color: ${base0B};
            --alert-success-background-color: ${base01};
            --alert-success-border-color: ${base0B};
            --alert-error-color: ${base08};
            --alert-error-background-color: ${base01};
            --alert-error-border-color: ${base08};
            --alert-info-color: ${base0D};
            --alert-info-background-color: ${base01};
            --alert-info-border-color: ${base0D};
            --panel-background: ${base01};
            --panel-border-color: ${base03};
            --panel-color: ${base05};

            --pagination-link-color: ${base0D};
            --pagination-border-color: ${base03};
            --category-color: ${base05};
            --category-background-color: ${base02};
            --category-border-color: ${base03};
            --category-link-color: ${base04};
            --category-link-hover-color: ${base0C};
            --item-border-color: ${base03};
            --item-status-read-title-link-color: ${base04};
            --item-status-read-title-focus-color: ${base0C};
            --item-meta-focus-color: ${base05};
            --item-meta-li-color: ${base04};
            --current-item-border-color: ${base0D};
            --current-item-box-shadow: 0 0 0 1px ${base0D};

            --entry-header-border-color: ${base03};
            --entry-header-title-link-color: ${base05};
            --entry-content-color: ${base05};
            --entry-content-code-color: ${base05};
            --entry-content-code-background: ${base01};
            --entry-content-code-border-color: ${base03};
            --entry-content-quote-color: ${base04};
            --entry-content-abbr-border-color: ${base04};
            --entry-content-aside-border-color: ${base03};
            --entry-enclosure-border-color: ${base03};
            --parsing-error-color: ${base08};
            --feed-parsing-error-background-color: ${base01};
            --feed-parsing-error-border-style: solid;
            --feed-parsing-error-border-color: ${base08};
            --feed-has-unread-background-color: ${base01};
            --feed-has-unread-border-style: solid;
            --feed-has-unread-border-color: ${base0D};
            --category-has-unread-background-color: ${base01};
            --category-has-unread-border-style: solid;
            --category-has-unread-border-color: ${base0D};
            --keyboard-shortcuts-li-color: ${base05};
            --counter-color: ${base04};
          }

          /* These upstream colours are hard-coded rather than theme variables. */
          a:focus { outline-color: ${base0D}; }
          .logo a span { color: ${base0D}; }
          .logo a:hover,
          .header li :is(a, .logout-button):hover,
          .page-header h1 a:is(:hover, :focus),
          .entry header h1 a:is(:hover, :focus),
          .item-meta :is(a, button):is(:focus, :hover) {
            color: ${base0C};
          }

          .item-meta a,
          .item-meta-icons li :is(a, button),
          .entry-date,
          .entry-website a,
          .entry-meta,
          .form-help,
          .entry-content :is(figcaption, dt, dd),
          .btn-close-modal {
            color: ${base04};
          }
          .btn-close-modal:hover { color: ${base05}; }
          fieldset,
          .form-section,
          .bookmarklet,
          .entry-content :is(dd, blockquote, figure img) {
            border-color: ${base03};
          }

          .confirm,
          .confirm button,
          #btn-add-to-home-screen:hover {
            color: ${base08};
          }
          .button-danger {
            color: ${base00};
            background: ${base08};
            border-color: ${base08};
          }
          .button-danger:is(:hover, :focus) {
            color: ${base00};
            background: ${base09};
          }
          .button:disabled {
            color: ${base04};
            background: ${base02};
            border-color: ${base03};
          }
          #prompt-home-screen,
          #toast-msg {
            background: ${base02};
          }
          #btn-add-to-home-screen,
          #toast-wrapper {
            color: ${base05};
          }
        ''
    );
  in {
    sops.secrets."miniflux-env".restartUnits = ["miniflux.service"];

    services.miniflux = {
      enable = true;
      config = {
        PORT = toString port;
        BASE_URL = "https://${subdomain}.${keresDomain}";
        HTTPS = 1;
        POLLING_FREQUENCY = 120;
        HTTP_CLIENT_USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36";
        CREATE_ADMIN = 0;
        DISABLE_LOCAL_AUTH = 1;
        OAUTH2_PROVIDER = "oidc";
        OAUTH2_OIDC_PROVIDER_NAME = "Methanol";
        OAUTH2_CLIENT_ID = "266a4351-916b-49b5-aa29-f841f127b662";
        OAUTH2_REDIRECT_URL = "https://${subdomain}.${keresDomain}/oauth2/oidc/callback";
        OAUTH2_OIDC_DISCOVERY_ENDPOINT = "https://sso.${keresDomain}";
        OAUTH2_USER_CREATION = 1;
      };
    };

    systemd.services.miniflux.serviceConfig.EnvironmentFile =
      config.sops.secrets."miniflux-env".path;

    services.caddy.virtualHosts."${subdomain}.${keresDomain}".extraConfig = ''
      handle /gaiaTheme.css {
        root * ${theme}
        header Cache-Control "no-cache"
        file_server
      }

      handle {
        reverse_proxy 127.0.0.1:${toString port}
      }
    '';
  };
}
