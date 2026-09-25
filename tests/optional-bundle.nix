{
  lib,
  bundleLib,
}: let
  wrap = import ../lib/optional-bundle.nix {
    inherit lib;
    root = ./fixtures/bundles;
  };
  eval = on:
    lib.evalModules {
      specialArgs = {inherit bundleLib;};
      modules = [
        {
          config._module.args.fromConfig = "works";
          options.fixture = {
            value = lib.mkOption {
              type = lib.types.int;
              default = 0;
            };
            functionValue = lib.mkOption {
              type = lib.types.int;
              default = 0;
            };
          };
        }
        (wrap ./fixtures/bundles/programs/sample/default.nix)
        (wrap ./fixtures/bundles/programs/with-args/default.nix)
        {
          gaia.programs.sample.enable = on;
          gaia.programs.with-args.enable = on;
        }
      ];
    };
in
  assert (eval false).config.fixture.value == 0;
  assert (eval false).config.fixture.functionValue == 0;
  assert !(eval false).config.gaia.programs.sample.enable;
  assert !(eval false).config.gaia.programs.with-args.enable;
  assert (eval true).config.fixture.value == 1;
  assert (eval true).config.fixture.functionValue == 1;
  assert (eval true).config.gaia.programs.sample.enable;
  assert (eval true).config.gaia.programs.with-args.enable;
  assert !(builtins.tryEval (wrap ./fixtures/bundles/programs/flat.nix {inherit bundleLib;})).success;
  assert !(builtins.tryEval (wrap ../bundles/programs/rio/default.nix {inherit bundleLib;})).success; true
