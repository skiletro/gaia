set quiet := true

export NH_FLAKE := justfile_directory()
RUNNER := `sh -c "command -v gamemoderun > /dev/null && echo gamemoderun || echo"`
[private]
_nix := require("nix")
[private]
_nh := require("nh")
[private]
_git := require("git")

#
#
# Internal Recipes

# default recipe
[no-exit-message]
[private]
default:
    just -l -u

[no-exit-message]
[private]
_:
    $EDITOR ./.justfile

[no-exit-message]
[private]
_m message:
    echo -e "\e[35m>\e[0m {{ message }}..."

# formats the repo
[no-exit-message]
[private]
_format: (_m "formatting code")
    nix fmt

# stages all changes
[no-exit-message]
[private]
_stage: (_m "staging commits")
    git add .

[linux]
[no-exit-message]
[private]
_build goal *args:
    echo -e "\e[35m>\e[0m {{ goal }}ing configuration..."
    {{ RUNNER }} nh os {{ goal }} -- {{ args }}

[macos]
[no-exit-message]
[private]
_build goal *args:
    nh darwin {{ goal }} -- {{ args }}

[no-exit-message]
[private]
_builder goal *args: _format _stage (_build goal args)

[linux]
[no-exit-message]
[private]
_gc:
    echo -e "\e[35m>\e[0m garbage collect the Nix store..."
    nh clean all -K 1d

[macos]
[no-exit-message]
[private]
_gc:
    echo -e "\e[35m>\e[0m garbage collect the Nix store..."
    nix store --gc --print-roots | egrep -v "^(/nix/var|/run/\w+-system|\{libproc)"

#
#
# Build Recipes

[doc("build and switch to the generation")]
[group("rebuild")]
[no-exit-message]
switch *args: (_builder "switch" args)

[doc("build and update bootloader with new generation")]
[group("rebuild")]
[linux]
[no-exit-message]
boot *args: (_builder "boot" args)

[doc("build the generation")]
[group("rebuild")]
[no-exit-message]
build *args: (_builder "build" args)

[doc("build and test the generation")]
[group("rebuild")]
[linux]
[no-exit-message]
test *args: (_builder "test" args)

[doc("build a package")]
[group("package")]
[no-exit-message]
pkg pkg:
    nix build .#{{ pkg }}

#
#
# Housekeeping Recipes

[doc("update flake inputs and package sources")]
[group("housekeeping")]
[no-exit-message]
update: update-inputs update-sources

[doc("update flake inputs")]
[group("housekeeping")]
[no-exit-message]
update-inputs *input: (_m "updating flake inputs")
    nix flake update {{ input }} --refresh

[doc("update package sources")]
[group("housekeeping")]
[no-exit-message]
update-sources: (_m "updating nvfetcher sources")
    nvfetcher -c ./pkgs/nvfetcher.toml -o ./pkgs/_sources/

[doc("open up a repl with the flake imported")]
[group("housekeeping")]
[no-exit-message]
repl: (_builder "repl")

[doc("garbage collect and optimise the nix store")]
[group("housekeeping")]
[no-exit-message]
clean: _gc optimise

[doc("optimise the nix store")]
[group("housekeeping")]
[no-exit-message]
optimise: (_m "optimising nix store")
    nix store optimise

[doc("repair the nix store")]
[group("housekeeping")]
[no-exit-message]
repair: (_m "verifying nix store")
    nix-store --verify --check-contents --repair

[doc("edit secrets")]
[group("housekeeping")]
[no-exit-message]
secret:
    #!/usr/bin/env bash
    SOPS_AGE_KEY="$(ssh-to-age -private-key < "$HOME/.ssh/id_ed25519")"
    sops ./.secrets.yaml
