{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, makeWrapper
, alsa-lib
, at-spi2-atk
, at-spi2-core
, cairo
, cups
, dbus
, expat
, fontconfig
, freetype
, gtk3
, libGL
, libdrm
, libglvnd
, libxkbcommon
, mesa
, nspr
, nss
, pango
, systemd
, wayland
, xorg
, zlib
}:

let
  sources = lib.importJSON ./../sources.json;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "dawn-launcher";
  version = sources.version;

  src = fetchurl {
    # Stable, first-party dawn.gg endpoint. It 302-redirects to a
    # short-lived, pre-signed Cloudflare R2 URL; curl (used internally by
    # fetchurl) follows that redirect on its own. The pinned hash below,
    # not the URL, is what makes this reproducible -- the signed URL
    # itself is never stored anywhere and is re-resolved on every build.
    url = "https://dawn.gg/api/launcher/download?platform=linux-amd64&format=tarball";
    hash = sources.hash;
    name = "dawn-launcher-${sources.version}-linux-amd64.tar.gz";
  };

  nativeBuildInputs = [ autoPatchelfHook makeWrapper ];

  # Best-guess runtime deps for a Kotlin Compose Multiplatform desktop
  # app shipping a bundled JRE + Skia renderer. This list is a starting
  # point, not verified against the actual binary -- see the README
  # note below on iterating on it.
  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gtk3
    libGL
    libdrm
    libglvnd
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemd
    wayland
    xorg.libX11
    xorg.libXcomposite
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXtst
    xorg.libxcb
    zlib
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/opt/dawn-launcher" "$out/bin"

    # jpackage-style app-image layout: bin/, lib/, and a bundled
    # runtime/ sit inside one top-level directory in the tarball.
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
