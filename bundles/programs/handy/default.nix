_: {
  home-manager = {
    lib,
    pkgs,
    ...
  }: let
    package = pkgs.symlinkJoin {
      inherit (pkgs.handy) meta;
      name = "${lib.getName pkgs.handy}-wrapped-${lib.getVersion pkgs.handy}";
      paths = [pkgs.handy];
      preferLocalBuild = true;
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram $out/bin/handy \
          --suffix PATH : ${lib.makeBinPath [pkgs.wtype]}
      '';
    };
  in {
    systemd.user.services.handy = {
      Unit = {
        Description = "Handy speech-to-text";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Service.ExecStart = "${lib.getExe' package "handy"} --start-hidden";
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
