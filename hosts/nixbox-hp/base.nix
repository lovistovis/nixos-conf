{
  config,
  pkgs,
  ...
}: {
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      devices = ["nodev"];
      efiSupport = true;
      useOSProber = true;
      extraEntries = ''
             menuentry "UbuntuManual" {
               search --set=ubuntu --fs-uuid 4db76f03-619c-4f36-9c46-b22b1b095c44
               configfile "($ubuntu)/boot/grub/grub.cfg"
             }
             menuentry "WindowsManual" {
               insmod part_gpt
               insmod fat
               insmod search_fs_uuid
               insmod chain
               search --set=root --fs-uuid 4db76f03-619c-4f36-9c46-b22b1b095c44
               chainloader /EFI/Microsoft/Boot/bootmgfw.efi
             }
      '';
    };
  };

  programs = {
    light.enable = true;
    #xss-lock.enable = true;
  };

  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        intel-compute-runtime
      ];
    };
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      open = false;
      nvidiaSettings = true;

      prime = {
        sync.enable = true;

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

  #services.systemd-lock-handler.enable = false;

  powerManagement.enable = true;

  services = {
    xserver.videoDrivers = [ "nvidia" ];
    thermald.enable = true;
    blueman = {
      enable = true;
    };
    logind = {
      extraConfig = ''
        HandlePowerKey=suspend
        IdleAction=hybrid-sleep
        IdleActionSec=1m
      '';
    };
  };

  time.hardwareClockInLocalTime = true;
}
