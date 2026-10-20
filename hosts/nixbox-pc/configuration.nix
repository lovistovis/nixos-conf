{
  lib,
  config,
  pkgs,
  my,
  ...
}: {
  powerManagement.enable = true;

  hardware = {
    # graphics = {
    #   enable = true;
    #   enable32Bit = true;
    #   extraPackages = with pkgs; [
    #     intel-compute-runtime
    #     mesa
    #   ];
    # };

    # nvidia = {
    #   modesetting.enable = true;
    #   powerManagement.enable = false;
    #   powerManagement.finegrained = false;
    #   open = true;
    #   nvidiaSettings = true;

    #   prime = {
    #     offload = {
    #       enable = true;
    #       enableOffloadCmd = true;
    #     };

    #     intelBusId = "PCI:0:2:0";
    #     nvidiaBusId = "PCI:1:0:0";
    #   };
    # };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  services = {
    desktopManager.plasma6.enable = true;
    # xserver = {
    #   videoDrivers = [ "modesetting" "nvidia" ];
    #   deviceSection = ''
    #     Option "TearFree" "true"
    #     Option "SwapbuffersWait" "true"
    #     Option "DPI" "2"
    #   '';
    #   dpi = 80;
    # };
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
}
