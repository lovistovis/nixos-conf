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
      powerManagement.finegrained = true;
      open = false;
      nvidiaSettings = true;

      prime = {
        #sync.enable = true;

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

  #services.systemd-lock-handler.enable = false;

  powerManagement.enable = true;

  services = {
    xserver = {
      videoDrivers = [ "nvidia" "modsetting" ];
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
      implementation = "dbus";
    };
  };

  time.hardwareClockInLocalTime = true;
}
