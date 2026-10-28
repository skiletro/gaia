{
  home-manager = {
    pkgs,
    config,
    ...
  }: let
    css =
      pkgs.runCommand "signal-stylix.css" {
        nativeBuildInputs = [pkgs.mustache-go];
        passAsFile = ["jsonData"];
        jsonData = builtins.toJSON {
          inherit (config.lib.stylix.colors) base00 base01 base02 base03 base04 base08;
        };
      } ''
        mustache "$jsonDataPath" ${./theme.css.mustache} > "$out"
      '';
  in {
    home.packages = [
      (pkgs.signal-desktop.overrideAttrs (oldAttrs: {
        patches =
          oldAttrs.patches
          ++ [
            ./more-fps.patch
          ];

        preBuild =
          (oldAttrs.preBuild or "")
          + ''
            cp ${css} stylesheets/stylix.css
            LINE=$(grep -n '^@use\|^@forward' stylesheets/manifest.scss | tail -1 | cut -d: -f1)
            sed -i "''${LINE}a @import \"stylix.css\";" stylesheets/manifest.scss

            sed -i "s/Inter/'${config.stylix.fonts.sansSerif.name}'/g" ts/axo/_tailwind-theme/fonts.css
            sed -i "s/SF Mono/${config.stylix.fonts.monospace.name}/g" ts/axo/_tailwind-theme/fonts.css
          '';
      }))
    ];
  };
}
