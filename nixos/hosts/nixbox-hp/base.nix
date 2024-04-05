{ config, pkgs, ... }:
{
  boot.loader =  {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
    grub = {
      enable = true;
      devices = [ "nodev" ];
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

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

# services.xserver.videoDrivers = [ "nvidia" ];

# hardware.nvidia = {
  # modesetting.enable = true;

  # powerManagment.enable = false;

  # powerManagement.finegrained = false;

  # open = false;

  # nvidiaSettings = true;

  #  package = config.boot.kernelPackages.nvidiaPackages.stable;
  #};

  time.hardwareClockInLocalTime = true;
}
