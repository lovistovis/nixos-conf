{ config, pkgs, ... }: {
  boot.loader = {
    timeout = 1;
    efi = {
      canTouchEfiVariables = true;
    };
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
      timeoutStyle = "countdown";
      default = "saved";
      splashImage = null;
    };
  };

  programs = {
    light.enable = true;
    dconf.enable = true;
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
        mesa
      ];
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = true;
      nvidiaSettings = true;

      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };

        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  powerManagement.enable = true;

  services = {
    xserver = {
      videoDrivers = [ "modesetting" "nvidia" ];
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
    logind.settings.Login = {
      HandlePowerKey = "suspend";
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
    };
  };

  time.hardwareClockInLocalTime = true;
}
