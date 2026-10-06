{
  lib,
  rustPlatform,
  sources,
  pkg-config,
  makeWrapper,
  replaceVars,
  runCommand,
  writeText,
  fontconfig,
  dbus,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxrandr,
  libxkbcommon,
  vulkan-loader,
  wayland,
  xdg-utils,
  zenity,
  space-grotesk,
  pragmata-pro,
  # Standalone builds use Gaia's default Penumbra palette. The bundle overrides it.
  stylixColors ? {
    base00 = "181B1F";
    base01 = "24272B";
    base02 = "3E4044";
    base03 = "636363";
    base04 = "9E9E9E";
    base05 = "CECECE";
    base08 = "DF7F78";
    base0A = "9CA748";
    base0D = "61A3E6";
  },
  stylixFonts ? {
    sansSerif = {
      package = space-grotesk;
      name = "Space Grotesk";
    };
    monospace = {
      package = pragmata-pro;
      name = "PragmataPro Mono Liga";
    };
  },
  ...
}: let
  runtimeLibraries = [
    dbus
    libGL
    libx11
    libxcursor
    libxi
    libxrandr
    libxkbcommon
    vulkan-loader
    wayland
  ];
  rgb = hex: let
    color = lib.removePrefix "#" hex;
  in
    map (offset: lib.fromHexString (builtins.substring offset 2 color)) [0 2 4];
  rustColor = hex: "Color32::from_rgb(${lib.concatMapStringsSep ", " toString (rgb hex)})";
  brightness = hex: let
    channels = rgb hex;
  in
    2126
    * builtins.elemAt channels 0
    + 7152 * builtins.elemAt channels 1
    + 722 * builtins.elemAt channels 2;
  themeColors =
    lib.getAttrs [
      "base00"
      "base01"
      "base02"
      "base03"
      "base04"
      "base05"
      "base08"
      "base0A"
      "base0D"
    ]
    stylixColors;
  fontFaces = let
    fontConfig = writeText "photocraft-fonts.conf" ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
        <dir>${stylixFonts.sansSerif.package}/share/fonts</dir>
        <dir>${stylixFonts.monospace.package}/share/fonts</dir>
      </fontconfig>
    '';
    fontFiles =
      runCommand "photocraft-stylix-fonts" {
        nativeBuildInputs = [fontconfig];
        FONTCONFIG_FILE = fontConfig;
      } ''
        mkdir -p "$out"
        export XDG_CACHE_HOME="$TMPDIR/font-cache"
        select_font() {
          local pattern="$1:fontformat=TrueType:variable=false"
          ln -s "$(fc-match --format '%{file}' "$pattern")" "$out/$2"
          printf '%su32\n' "$(fc-match --format '%{index}' "$pattern")" > "$out/$2-index.rs"
        }
        select_font ${lib.escapeShellArg "${stylixFonts.sansSerif.name}:weight=regular"} sans-regular
        select_font ${lib.escapeShellArg "${stylixFonts.sansSerif.name}:weight=medium"} sans-medium
        select_font ${lib.escapeShellArg "${stylixFonts.sansSerif.name}:weight=semibold"} sans-semibold
        select_font ${lib.escapeShellArg "${stylixFonts.monospace.name}:weight=regular"} monospace
      '';
    face = name: "${fontFiles}/${name}";
    index = name: ''include!("${fontFiles}/${name}-index.rs")'';
  in {
    sansRegular = face "sans-regular";
    sansMedium = face "sans-medium";
    sansSemibold = face "sans-semibold";
    monospace = face "monospace";
    sansRegularIndex = index "sans-regular";
    sansMediumIndex = index "sans-medium";
    sansSemiboldIndex = index "sans-semibold";
    monospaceIndex = index "monospace";
  };
in
  rustPlatform.buildRustPackage {
    inherit (sources.photocraft) pname src;
    version = lib.removePrefix "v" sources.photocraft.version;
    cargoLock = sources.photocraft.cargoLock."Cargo.lock";

    patches = [
      ./remove-topbar-discord.patch
      (replaceVars ./stylix-theme.patch (
        lib.mapAttrs (_: rustColor) themeColors
        // fontFaces
        // {
          dark =
            if brightness stylixColors.base00 < brightness stylixColors.base05
            then "true"
            else "false";
        }
      ))
    ];

    nativeBuildInputs = [pkg-config makeWrapper];
    buildInputs = runtimeLibraries;

    # The workspace's default members do not include the desktop application.
    cargoBuildFlags = ["-p" "photocraft" "-p" "photocraft-cli"];
    cargoTestFlags = ["-p" "photocraft" "-p" "photocraft-cli"];

    postInstall = ''
      install -Dm644 packaging/linux/ai.storyteller.photocraft.desktop \
        "$out/share/applications/ai.storyteller.photocraft.desktop"
      install -Dm644 packaging/linux/ai.storyteller.photocraft.mime.xml \
        "$out/share/mime/packages/ai.storyteller.photocraft.xml"
      install -Dm644 packaging/linux/ai.storyteller.photocraft.metainfo.xml.in \
        "$out/share/metainfo/ai.storyteller.photocraft.metainfo.xml"
      substituteInPlace "$out/share/metainfo/ai.storyteller.photocraft.metainfo.xml" \
        --replace-fail '@VERSION@' "$version" \
        --replace-fail '@DATE@' '2026-10-05'
      mkdir -p "$out/share/icons"
      cp -R assets/app-icon/hicolor "$out/share/icons/"
      install -Dm644 LICENSE-MIT LICENSE-APACHE NOTICE \
        -t "$out/share/doc/photocraft"
    '';

    postFixup = ''
      # winit, wgpu, and RFD load display, graphics, and D-Bus libraries dynamically.
      wrapProgram "$out/bin/photocraft" \
        --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibraries}" \
        --prefix PATH : "${lib.makeBinPath [xdg-utils zenity]}"
    '';

    meta = {
      description = "Native image editor with layers and Photoshop document support";
      homepage = "https://github.com/storytold/photocraft";
      license = with lib.licenses; [mit asl20];
      mainProgram = "photocraft";
      platforms = lib.platforms.linux;
    };
  }
