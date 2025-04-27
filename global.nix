{ config, lib, pkgs, ... }:
{
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";
  services.automatic-timezoned.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  security.polkit.enable = true;

  # Select internationalisation properties.
  i18n = {
    defaultLocale = "en_US.UTF-8";
    # extraLocaleSettings = {
    #   LC_ALL = "en_US.UTF-8";
    # };
  };

  console = {
    font = "Lat2-Terminus16";
    # keyMap = "sv";
    useXkbConfig = true; # use xkb.options in tty.
  };

  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Configure keymap in X11
    xkb.layout = "se";
    # services.xserver.xkb.options = "eurosign:e,caps:escape";
  };

  services.displayManager = {
    sddm.enable = true;
    defaultSession = "sway";
  };

  fonts = {
    fontconfig = {
      antialias = true;
    };
  };

  services.gnome.gnome-keyring.enable = true;

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  programs.waybar.enable = true;

  location.provider = "manual";
  location.latitude = 59.33;
  location.longitude = 18.06;

  services.compton.enable = true;

  services.redshift = {
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

  programs.nix-ld.enable = true;

  # Sets up all the libraries to load
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
    gnome2.pango
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

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
      Disable = "Handsfree";
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim        # Emergency editor
    wget       # Retrive guides
    efibootmgr # Change boot order
    exfat      # Exfat fs support
    grim
    slurp
    htop-vim
    wl-clipboard
    mako
    j4-dmenu-desktop
  ];

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.zsh.enable = true;

  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];
}
