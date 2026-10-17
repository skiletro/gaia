{
  home-manager = {pkgs, ...}: let
    # the editor's font default sans is variable (inter)
    # use only the static fonts in the fhs env (dejavu, liberation, corefonts)
    unityFontconfig = pkgs.writeText "unity-fontconfig.conf" ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
        <dir>/usr/share/fonts</dir>
        <cachedir prefix="xdg">fontconfig-unity</cachedir>
        <alias binding="strong"><family>sans-serif</family><prefer><family>DejaVu Sans</family><family>Liberation Sans</family></prefer></alias>
        <alias binding="strong"><family>serif</family><prefer><family>DejaVu Serif</family><family>Liberation Serif</family></prefer></alias>
        <alias binding="strong"><family>monospace</family><prefer><family>DejaVu Sans Mono</family><family>Liberation Mono</family></prefer></alias>
        <alias binding="strong"><family>Arial</family><prefer><family>Liberation Sans</family></prefer></alias>
        <alias binding="strong"><family>Helvetica</family><prefer><family>Liberation Sans</family></prefer></alias>
      </fontconfig>
    '';
  in {
    home.packages = with pkgs; [
      # keep-sorted start
      alcom
      blender
      unityhub
      vrcx
      # keep-sorted end
      (writeShellScriptBin "unity-editor" ''
        export FONTCONFIG_FILE=${unityFontconfig}
        exec ${lib.getExe' unityhub.fhsEnv "unityhub-fhs-env"} \
          "$HOME/Unity/Hub/Editor/2022.3.22f1/Editor/Unity" \
          -force-vulkan "$@"
      '')
    ];
  };
}
