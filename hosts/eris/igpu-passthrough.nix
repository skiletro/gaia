{
  pkgs,
  lib,
  config,
  ...
}:
let
  gpuIDs = [
    "1002:164e" # Graphics
    "1002:1640" # Audio
  ];
in
{
  boot = {
    initrd.kernelModules = [
      "vendor-reset"
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
    ];

    kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
      "vfio-pci.ids=${lib.concatStringsSep "," gpuIDs}"
    ];

    kernelModules = [ "kvmfr" ];

    extraModulePackages = with config.boot.kernelPackages; [
      vendor-reset
      kvmfr
    ];

    extraModprobeConfig = "options kvmfr static_size_mb=128";
  };

  virtualisation.libvirtd.qemu.verbatimConfig = ''
    cgroup_device_acl = [
      "/dev/null",
      "/dev/full",
      "/dev/zero",
      "/dev/random",
      "/dev/urandom",
      "/dev/ptmx",
      "/dev/kvm",
      "/dev/kqemu",
      "/dev/rtc",
      "/dev/hpet",
      "/dev/vfio/vfio",
      "/dev/net/tun",
      "/dev/vfio/1",
      "/dev/kvmfr0",
    ]
  '';

  environment = {
    etc = {
      "libvirt/roms/vbios_7800x3d.bin".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/isc30/ryzen-gpu-passthrough-proxmox/refs/heads/main/vbios_7800x3d.bin";
        sha256 = "sha256-cTj6jhPBFUwsjivWkevrQrIY1cTOVrya98pvBdKj4Y8=";
      };
      "libvirt/roms/AMDGopDriver_7800x3d.rom".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/isc30/ryzen-gpu-passthrough-proxmox/refs/heads/main/AMDGopDriver_7800x3d.rom";
        sha256 = "sha256-XyqrATdHkJ8on5ZBfTPmDApx8pZCFNG5Nv7iJBRgv7w=";
      };
    };

    systemPackages = [
      (pkgs.looking-glass-client.overrideAttrs (old: {
        nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
        # steam-run workaround for imgui `FontData is incorrect, or FontNo cannot be found.`
        # __NV_DISABLE_EXPLICIT_SYNC=1 workaround for https://github.com/NVIDIA/egl-wayland/issues/149
        postFixup = (old.postFixup or "") + ''
          mv $out/bin/looking-glass-client $out/bin/.looking-glass-client-real
          makeWrapper ${lib.getExe config.programs.steam.package.run} $out/bin/looking-glass-client \
            --add-flags "$out/bin/.looking-glass-client-real" \
            --set __NV_DISABLE_EXPLICIT_SYNC 1
        '';
      }))
    ];
  };

  services.udev.packages = [
    (pkgs.stdenv.mkDerivation {
      pname = "looking-glass-client-udev-rules";
      inherit (pkgs.looking-glass-client) version;
      src = pkgs.writeTextDir "/99-kvmfr.rules" ''
        SUBSYSTEM=="kvmfr", OWNER="root", GROUP="kvm", MODE="0660"
      '';

      nativeBuildInputs = [
        pkgs.udevCheckHook
      ];

      doInstallCheck = true;
      dontBuild = true;
      dontConfigure = true;

      installPhase = ''
        mkdir -p $out/lib/udev/rules.d
        cp $src/99-kvmfr.rules $out/lib/udev/rules.d/
      '';
    })
  ];
}
