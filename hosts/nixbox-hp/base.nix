{ config, pkgs, ... }: {
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
      timeoutStyle = "hidden";
      # default = "2";
      splashImage = null;
      extraEntries = ''
        menuentry "UbuntuManual" {
          insmod search_fs_uuid
          search --set=root --fs-uuid 48d5e96d-cd77-476b-8aa3-4eb0218caa25
          configfile "/boot/grub/grub.cfg"
        }
        menuentry "WindowsManual" {
          insmod part_gpt
          insmod fat
          insmod search_fs_uuid
          insmod chain
          search --set=root --fs-uuid 0CB0-93CB 
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
    };
  };

  programs = {
    light.enable = true;
    dconf.enable = true;
    # xss-lock.enable = true;
    zsh.shellAliases = {
      mount-windows = "if [ ! -d /mnt/windows ]; then sudo mkdir /mnt/windows; fi; sudo mount -t ntfs3 /dev/nvme0n1p3 /mnt/windows";
      mount-sd = "if [ ! -d /mnt/sd ]; then sudo mkdir /mnt/sd; fi; sudo mount -t exfat /dev/mmcblk0 /mnt/sd";
    };
  };

  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
       governor = "powersave";
       turbo = "never";
    };
    charger = {
       governor = "performance";
       turbo = "auto";
    };
  };

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-compute-runtime
        mesa.drivers
      ];
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;

      prime = {
        # sync.enable = true;

        offload = {
          enable = true;
          enableOffloadCmd = true;
        };

        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  powerManagement.enable = true;

  services = {
    xserver = {
      videoDrivers = [ "nvidia" ];
      deviceSection = ''
        Option "TearFree" "true"
        Option "SwapbuffersWait" "true"
        Option "DPI" "2"
      '';
      dpi = 80;
    };
    thermald.enable = true;
    blueman = {
      enable = true;
    };
    logind = {
      extraConfig = ''
        HandlePowerKey=suspend
        HandleLidSwitch=ignore
        HandleLidSwitchExternalPower=ignore
        IdleAction=suspend-then-hibernate
        IdleActionSec=1m
        HibernateDelaySec=5m
      '';
    };
    dbus = {
      implementation = "broker";
    };
    pipewire = {
      enable = false;
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      xdg-desktop-portal-gtk
    ];
  };

  time.hardwareClockInLocalTime = true;
}
