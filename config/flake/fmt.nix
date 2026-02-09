{ inputs, ... }:
{
  imports = [ inputs.treefmt-nix.flakeModule ];

  perSystem =
    { config, ... }:
    {
      formatter = config.treefmt.build.wrapper;

      treefmt = {
        flakeCheck = true;
        settings.global.excludes = [
          "*.age"
          "pkgs/_sources/generated.json"
          "pkgs/_sources/generated.nix"
        ];
        programs = {
          # keep-sorted start
          deadnix.enable = true;
          just.enable = true;
          keep-sorted.enable = true;
          nixfmt.enable = true;
          statix.enable = true;
          toml-sort.enable = true;
          # keep-sorted end
        };
      };
    };
}
