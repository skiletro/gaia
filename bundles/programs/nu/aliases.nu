# A nix shorthand.
# Expands spec shorthands, then runs nix with NIXPKGS_ALLOW_UNFREE set and
# --impure for run and shell, matching the old eos-helpers behaviour.
# run and shell go through nix-your-shell so the spawned shell is nushell,
# matching the behaviour of the wrapped `nix` command.
def --wrapped via-nix-your-shell [
  cmd: string,     # command to run, e.g. nix
  ...args: string, # arguments passed through
]: nothing -> nothing {
    if (which nix-your-shell | is-not-empty) {
        run-external nix-your-shell nu $cmd "--" ...$args
    } else {
        run-external $cmd ...$args
    }
}

def --wrapped n [
  sub: string,     # nix subcommand (run, shell, build)
  ...args: string, # specs and flags, passed straight through
]: nothing -> nothing {
    let specs = ($args | each {|a|
    if $a =~ '^gh:' {
      $"github:($a | str replace 'gh:' '' | str replace -a '/' '/')"
    } else if ($a =~ '^[.#-]' or $a =~ '^/' or $a =~ '^[a-z][a-z0-9_-]*:$' or ($a | path exists)) {
      $a
    } else {
      $"nixpkgs#($a)"
    }
  })

    match $sub {
        "r" => {
            with-env { NIXPKGS_ALLOW_UNFREE: "1" } {
        via-nix-your-shell nix run ...$specs --impure
      }
        }
        "s" => {
            with-env { NIXPKGS_ALLOW_UNFREE: "1" } {
        via-nix-your-shell nix shell ...$specs --impure
      }
        }
        "b" => {
            run-external nix build ...$specs
        }
    }
}
