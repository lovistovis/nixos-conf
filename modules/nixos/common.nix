{ pkgs, inputs, ... }:
{
  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      inputs.nur.overlays.default
    ];
  };

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    curl
    htop
    iwgtk
    exfat
  ];

  programs = {
    zsh.enable = true;
    dconf.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  location.provider = "geoclue2";

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

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

  hardware.bluetooth.settings = {
    General = {
      Experimental = true;
      Disable = "Handsfree";
    };
  };

  services = {
    gnome.gnome-keyring.enable = true;
    automatic-timezoned.enable = true;
    printing.enable = true;
    flatpak.enable = true;
    # compton.enable = true;

    pipewire = {
      enable = true;
      pulse.enable = true;
    };

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
  };

  system.stateVersion = "25.05";
}
