{
  lib,
  rustPlatform,
  sources,
  cacert,
  cmake,
  cubeb,
  pkg-config,
  makeWrapper,
  fontconfig,
  openssl,
  alsa-lib,
  libpulseaudio,
  udev,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  libxcb,
  libxkbcommon,
  wayland,
  vulkan-loader,
  ...
}: let
  runtimeLibraries = [
    alsa-lib
    libpulseaudio
    udev
    libGL
    libx11
    libxcursor
    libxi
    libxrandr
    libxcb
    libxkbcommon
    wayland
    vulkan-loader
  ];
in
  rustPlatform.buildRustPackage {
    inherit (sources.romp) pname src;
    version = lib.removePrefix "v" sources.romp.version;
    cargoLock = sources.romp.cargoLock."Cargo.lock";

    nativeBuildInputs = [
      cmake
      pkg-config
      makeWrapper
      rustPlatform.bindgenHook
    ];
    buildInputs =
      [
        cubeb
        fontconfig
        openssl
      ]
      ++ runtimeLibraries;
    nativeCheckInputs = [cacert];

    dontUseCmakeConfigure = true;

    env.LIBCUBEB_SYS_USE_PKG_CONFIG = "1";

    postPatch = ''
      substituteInPlace crates/romp-app/src/paths.rs \
        --replace-fail 'dir.join("shaders")' 'dir.join("../share/romp/shaders")'
    '';

    postInstall = ''
      mkdir -p $out/share/romp
      cp -r crates/romp-app/shaders $out/share/romp/
      install -Dm644 packaging/linux/romp.desktop $out/share/applications/romp.desktop
      install -Dm644 packaging/linux/romp.png $out/share/icons/hicolor/256x256/apps/romp.png
      install -Dm644 packaging/linux/io.github.rompemu.romp.metainfo.xml \
        $out/share/metainfo/io.github.rompemu.romp.metainfo.xml
    '';

    postFixup = ''
      for program in romp romp-runner; do
        wrapProgram $out/bin/$program \
          --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeLibraries}
      done
    '';

    meta = {
      description = "Native player for games from your RomM library";
      homepage = "https://github.com/RompEmu/RomP";
      license = lib.licenses.gpl3Plus;
      platforms = lib.platforms.linux;
      mainProgram = "romp";
    };
  }
