{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, expat
, fontconfig
, freetype
, glib
, libglvnd
, libx11
, libxcb
, libxcomposite
, libxdamage
, libxext
, libxfixes
, libxi
, libxkbcommon
, libxrandr
, libxrender
, libxtst
, mesa
, nspr
, nss
, pango
, systemd
, wayland
, zlib
}:

let
  sources = lib.importJSON ./../sources.json;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "dawn-launcher";
  version = sources.version;

  src = fetchurl {
    url = "https://dawn.gg/api/launcher/download?platform=linux-amd64&format=tarball";
    hash = sources.hash;
    name = "dawn-launcher-${sources.version}-linux-amd64.tar.gz";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

  buildInputs = [
    stdenv.cc.cc.lib
    alsa-lib
    atk
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    glib
    libglvnd
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemd
    wayland
    zlib
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxi
    libxrandr
    libxrender
    libxtst
    libxcb
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/opt/dawn-launcher" "$out/bin"

    shopt -s dotglob nullglob
    entries=(*/)
    if [ "''${#entries[@]}" -eq 1 ]; then
      cp -r "''${entries[0]}"* "$out/opt/dawn-launcher/"
    else
      cp -r ./* "$out/opt/dawn-launcher/"
    fi
    shopt -u dotglob nullglob

    launcher_bin=$(find "$out/opt/dawn-launcher" -maxdepth 2 -type f -executable | head -n1)
    if [ -z "$launcher_bin" ]; then
      echo "installPhase: couldn't find the launcher executable -- inspect" >&2
      echo "the extracted layout ($out/opt/dawn-launcher) and fix this phase." >&2
      exit 1
    fi

    makeWrapper "$launcher_bin" "$out/bin/dawn-launcher" \
      --chdir "$out/opt/dawn-launcher"

    runHook postInstall
  '';

  meta = {
    description = "Dawn - Minecraft launcher/client (unofficial packaging of the upstream Linux tarball)";
    homepage = "https://dawn.gg";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "dawn-launcher";
  };
})
