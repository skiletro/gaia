#!/usr/bin/env nu

# Creates a shell from a list of nixpkgs.
# Shorthand for nix shell nixpkgs#{...}
def main [...packages: string]: any -> nothing {
  if ($packages | is-empty) {
    help main | print
    return
  }

  let specs = echo ...$packages | each { |pkg| $"nixpkgs#($pkg)"}
  with-env { NIXPKGS_ALLOW_UNFREE: "1" } {
    if (($specs | describe) == "list<string>") {
      nix shell ...$specs --impure
    } else {
      nix shell $specs --impure
    }
  }
}
