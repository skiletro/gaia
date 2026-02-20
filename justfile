export NH_FLAKE := justfile_directory()
RUNNER := `sh -c "command -v gamemoderun > /dev/null && echo gamemoderun || echo"`

#
#
# Internal Recipes

# default recipe
[private]
default:
    @just -l -u

# formats the repo
[private]
_format:
    @echo -e "\e[35m>\e[0m formatting code..."
    @nix fmt

# stages all changes
[private]
_stage:
    @echo -e "\e[35m>\e[0m staging commits..."
    @git add .

[linux]
[private]
_build goal *args:
    @echo -e "\e[35m>\e[0m {{ goal }}ing configuration..."
    @{{ RUNNER }} nh os {{ goal }} -- {{ args }}

[macos]
[private]
_build goal *args:
    @nh darwin {{ goal }} -- {{ args }}

[private]
_builder goal *args: _format _stage (_build goal args)

#
#
# Build Recipes

# |      | build and switch to the generation
[group("rebuild")]
[linux]
[macos]
switch *args: (_builder "switch" args)

# |       | build and update bootloader with new generation
[group("rebuild")]
[linux]
boot *args: (_builder "boot" args)

# |      | build the generation
[group("rebuild")]
[linux]
[macos]
build *args: (_builder "build" args)

# |       | build and test the generation
[group("rebuild")]
[linux]
test *args: (_builder "test" args)

#
#
# Housekeeping Recipes

# |      | update flake inputs and packages sources
[group("housekeeping")]
[linux]
[macos]
update *input:
    @echo -e "\e[35m>\e[0m updating flake inputs..."
    @nix flake update {{ input }} --refresh
    @echo -e "\e[35m>\e[0m update nvfetcher sources..."
    @nvfetcher -c ./pkgs/nvfetcher.toml -o ./pkgs/_sources/

# |      | open up a repl with the flake already imported
[group("housekeeping")]
[linux]
[macos]
repl: (_builder "repl")

# |      | clean and optimise the nix store
[group("housekeeping")]
[linux]
[macos]
clean:
    @echo -e "\e[35m>\e[0m cleaning Nix store..."
    @nh clean all -K 1d
    @echo -e "\e[35m>\e[0m optimising Nix store..."
    @nix store optimise

# |      | repair the nix store
[group("housekeeping")]
[linux]
[macos]
repair:
    @echo -e "\e[35m>\e[0m verifying Nix store..."
    @nix-store --verify --check-contents --repair
