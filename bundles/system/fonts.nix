{ bundleLib, self', ... }:
bundleLib.mkEnableModule [ "gaia" "system" "fonts" ] {

  nixos = {
    fonts = {
      fontDir.enable = true;
      fontconfig = {
        enable = true;
        subpixel = {
          rgba = "none";
          lcdfilter = "none";
        };
        antialias = true;
        hinting = {
          enable = true;
          style = "full";
        };
        localConf =
          # xml
          ''
            <fontconfig>
              <match target="font">
                <edit name="rgba" mode="assign"><const>none</const></edit>
                <edit name="lcdfilter" mode="assign"><const>lcdnone</const></edit>
                <edit name="antialias" mode="assign"><bool>true</bool></edit>
                <edit name="hinting" mode="assign"><bool>true</bool></edit>
                <edit name="hintstyle" mode="assign"><const>hintfull</const></edit>
              </match>
             </fontconfig>
          '';
      };
    };

    environment.variables = {
      "FREETYPE_PROPERTIES" = "truetype:interpreter-version=40";
      "FONTCONFIG_FILE" = "/etc/fonts/fonts.conf";
    };
  };

  home-manager =
    { pkgs, ... }:
    {
      fonts.fontconfig.enable = true;

      home.packages = with pkgs; [
        corefonts # Microsoft Fonts
        vista-fonts # More Microsoft Fonts
        noto-fonts
        noto-fonts-cjk-sans # Japanese, Korean, Chinese, etc
        noto-fonts-color-emoji
        self'.packages.pragmata-pro
        self'.packages.pragmata-pro-nf
      ];
    };

}
