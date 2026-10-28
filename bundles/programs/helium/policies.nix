{lib, ...}: {
  nixos = {config, ...}: {
    programs.helium.policies = let
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
        steamdb = "kdbmhfkmnlmbkgbabkdealhhbfhlmmon";
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
}
