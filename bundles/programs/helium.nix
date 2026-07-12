{
  bundleLib,
  lib,
  inputs,
  ...
}:
bundleLib.mkEnableModule [ "gaia" "programs" "helium" ] {

  nixos = { config, ... }: {
    imports = [ inputs.helium.nixosModules.default ];

    programs.helium = {
      enable = true;
      flags = [ "--ozone-platform-hint=auto" ];
      policies =
        let
          extensions = {
            # keep-sorted start
            augmented-steam = "dnhpnfgdlenaccegplpojghhmaamnnfp";
            kagi-search = "cdglnehniifkbagbbombnjghhcihifij";
            kagi-translate = "alblebhaoakdgapamjdifdfnaicpnklm";
            proton-pass = "ghmbeldphafepmbegfdlkpapadhbakde";
            protondb-for-steam = "ngonfifpkpeefnhelnfdkficaiihklid";
            refined-github = "hlepfoohegkhhmjieoechaddaejaokhf";
            sponsorblock = "mnjggcdmjocbbbhaepdhchncahnbgone";
            ublock-helium = "blockjmkbacgjkknlgpkjjiijinjdanf";
            # keep-sorted end
          };
        in
        {
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
          SpellcheckLanguage = [ "en-GB" ];

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
