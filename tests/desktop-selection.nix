{lib}: let
  select = import ../lib/desktop-selection.nix {inherit lib;};
  none = {
    mango.enable = false;
    niri.enable = false;
  };
  one = {
    mango.enable = true;
    niri.enable = false;
  };
  two = {
    mango.enable = true;
    niri.enable = true;
  };
in
  assert select.enabled none == [];
  assert select.default none == null;
  assert select.default one == "mango";
  assert select.default two == null;
  assert select.single one == "mango";
  assert !(builtins.tryEval (select.single none)).success;
  assert !(builtins.tryEval (select.single two)).success; true
