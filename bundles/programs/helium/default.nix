{
  lib,
  inputs,
  ...
}: {
  nixos = {
    config,
    pkgs,
    ...
  }: {
    imports = [inputs.helium.nixosModules.default];

    nixpkgs.overlays = [inputs.helium.overlays.default];

    programs.helium = {
      enable = true;
      package = pkgs.helium-wv;
      flags = [
        "--ozone-platform-hint=auto"
        "--enable-features=WaylandUnscaledTouchpadScrolling"
      ];
      policies = let
        extensions = {
          # keep-sorted start
          augmented-steam = "dnhpnfgdlenaccegplpojghhmaamnnfp";
          imgur-unblocker = "gnfldmcodokkpcejgdlffnjakifemick";
          kagi-search = "cdglnehniifkbagbbombnjghhcihifij";
          kagi-translate = "alblebhaoakdgapamjdifdfnaicpnklm";
          proton-pass = "ghmbeldphafepmbegfdlkpapadhbakde";
          protondb-for-steam = "ngonfifpkpeefnhelnfdkficaiihklid";
          refined-github = "hlepfoohegkhhmjieoechaddaejaokhf";
          sponsorblock = "mnjggcdmjocbbbhaepdhchncahnbgone";
          ublock-helium = "blockjmkbacgjkknlgpkjjiijinjdanf";
          # keep-sorted end
        };
      in {
        ExtensionSettings = with extensions; {
          "*" = {
            installation_mode = "blocked";
            blocked_install_message = "Please install using Nix.";
          };
          "${ublock-helium}".toolbar_pin = "force_pinned";
          "${proton-pass}".toolbar_pin = "force_pinned";
        };
        ExtensionInstallForcelist = builtins.attrValues extensions;

        BrowserThemeColor = lib.mkForce config.lib.stylix.colors.withHashtag.base00;

        BrowserSignin = 0;
        SyncDisabled = true;

        SpellcheckEnabled = true;
        SpellcheckLanguage = ["en-GB"];

        DefaultSearchProviderEnabled = true;
        DefaultSearchProviderName = "Kagi";
        DefaultSearchProviderSearchURL = "https://kagi.com/search?q={searchTerms}";
        DefaultSearchProviderSuggestURL = "https://kagisuggest.com/api/autosuggest?q={searchTerms}";
      };
    };
  };

  home-manager = {
    xdg.mimeApps.defaultApplications = lib.genAttrs [
      "text/html"
      "application/x-mswinurl"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      "x-scheme-handler/about"
      "x-scheme-handler/unknown"
    ] (_: "helium.desktop");
  };
}
