{ config, lib, pkgs, ... }:
let
  my-sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "hyprland_kath";
    themeConfig = {
      Background = toString /etc/nixos/wallpaper.png; # This theme also accepts videos
    };
  };
in
{
  virtualisation = {
    docker.enable = true;
    libvirtd.enable = true;
  };

  networking = {
    wireless.iwd = {
      enable = true;
      settings = {
        Network = {
          EnableIPv6 = true;
        };
        Settings = {
          AutoConnect = true;
        };
        General = {
          EnableNetworkConfiguration = true;
        };
      };
    };
    proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    pam.services.hyprlock = {};
  };

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

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    config = {
      common.default = [ "gtk" ];
      hyprland.default = [ "gtk" "hyprland" ];
    };
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  services = {
    flatpak.enable = true;
    dbus = {
      implementation = "broker";
    };
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        package = pkgs.kdePackages.sddm;
        extraPackages = with pkgs; [
          kdePackages.qtmultimedia
        ];
        theme = "sddm-astronaut-theme";
        settings = {
          Theme = {
            Current = "sddm-astronaut-theme";
          };
        };
      };
      defaultSession = "hyprland";
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
  };

  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
      Disable = "Handsfree";
    };
  };

  programs = {
    virt-manager.enable = true;
    hyprland = {
      enable = true;
      xwayland.enable = true;
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
    iwgtk
    exfat
    grim
    slurp
    htop-vim
    wl-clipboard
    j4-dmenu-desktop
    my-sddm-astronaut
  ];

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
    libappindicator-gtk2
    libdbusmenu-gtk2
    libindicator-gtk2
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
