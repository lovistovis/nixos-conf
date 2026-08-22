{ pkgs, ... }:
{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = (with pkgs; [
    stdenv.cc.cc
    openssl
    libxcomposite
    libxtst
    libxrandr
    libxext
    libx11
    libxfixes
    libGL
    libva
    libxcb
    libxdamage
    libxshmfence
    libxxf86vm
    libelf

    # Required
    glib
    gtk2
    gtk3
    bzip2

    # Without these it silently fails
    libxinerama
    libxcursor
    libxrender
    libxscrnsaver
    libxi
    libsm
    libice
    nspr
    nss
    cups
    libcap
    SDL2
    libusb1
    dbus-glib
    ffmpeg

    # Only libraries are needed from those two
    libudev0-shim

    # Verified games requirements
    libxt
    libxmu
    libogg
    libvorbis
    SDL
    SDL2_image
    glew_1_10
    libidn
    tbb

    # Other things from runtime
    flac
    freeglut
    libjpeg
    libpng
    libpng12
    libsamplerate
    libmikmod
    libtheora
    libtiff
    pixman
    speex
    SDL_image
    SDL_ttf
    SDL_mixer
    SDL2_ttf
    SDL2_mixer
    libcaca
    libcanberra
    libgcrypt
    libvpx
    librsvg
    libxft
    libvdpau
    pango
    cairo
    atk
    gdk-pixbuf
    fontconfig
    freetype
    dbus
    alsa-lib
    expat

    # Needed for electron
    libdrm
    mesa
    libxkbcommon
  ]);
}
