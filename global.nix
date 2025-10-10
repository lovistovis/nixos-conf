{ config, lib, pkgs, ... }:
{
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  networking.networkmanager.enable = true;
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  security.polkit.enable = true;

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };

  fonts = {
    packages = with pkgs; [
      font-awesome
    ];
    fontconfig = {
      antialias = true;
    };
  };

  location.provider = "manual";
  location.latitude = 59.33;
  location.longitude = 18.06;

  services = {
    displayManager = {
      sddm.enable = true;
      defaultSession = "sway";
    };
    automatic-timezoned.enable = true;
    compton.enable = true;
    gnome.gnome-keyring.enable = true;
    xserver = {
      enable = true;
      xkb.layout = "se";
    };
    redshift = {
      enable = true;
      brightness = {
        day = "1";
        night = "1";
      };
      temperature = {
        day = 5500;
        night = 2700;
      };
    };
    printing.enable = true;
    pulseaudio.enable = true;
  };

  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
      Disable = "Handsfree";
    };
  };

  programs = {
    virt-manager.enable = true;
    sway = {
      enable = true;
      wrapperFeatures.gtk = true;
    };
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    zsh.enable = true;
  };

  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  environment.systemPackages = with pkgs; [
    vim        # Emergency editor
    wget       # Retrive guides
    efibootmgr # Change boot order
    exfat
    grim
    slurp
    htop-vim
    wl-clipboard
    mako
    j4-dmenu-desktop
  ];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = (with pkgs; [
    stdenv.cc.cc
    openssl
    xorg.libXcomposite
    xorg.libXtst
    xorg.libXrandr
    xorg.libXext
    xorg.libX11
    xorg.libXfixes
    libGL
    libva
    xorg.libxcb
    xorg.libXdamage
    xorg.libxshmfence
    xorg.libXxf86vm
    libelf

    # Required
    glib
    gtk2
    bzip2

    # Without these it silently fails
    xorg.libXinerama
    xorg.libXcursor
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXi
    xorg.libSM
    xorg.libICE
    gnome2.GConf
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
    xorg.libXt
    xorg.libXmu
    libogg
    libvorbis
    SDL
    SDL2_image
    glew110
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
    libappindicator-gtk2
    libdbusmenu-gtk2
    libindicator-gtk2
    libcaca
    libcanberra
    libgcrypt
    libvpx
    librsvg
    xorg.libXft
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
