new FILE:
    cp bundles/blank.nix {{ FILE }}
    hx {{ FILE }} && echo "Saved :)" || rm {{ FILE }}

build:
    nix fmt
    git add .
    NH_FLAKE=. nh os build-vm && ./result/bin/run-eris-vm
    rm eris.qcow2
