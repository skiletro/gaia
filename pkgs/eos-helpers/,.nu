#!/usr/bin/env nu

# Runs a package from nixpkgs.
# Shorthand for nix run nixpkgs#...
def --wrapped main [package?: string, ...args: string]: any -> nothing {
  if (($package | is-empty) or $package == "--help" or $package == "-h") {
    help main | print
    return
  }

  with-env { NIXPKGS_ALLOW_UNFREE: "1" } {
      nix run $"nixpkgs#($package)" --impure -- ...$args
  }
}
