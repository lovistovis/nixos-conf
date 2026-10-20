{
  inputs,
  lib,
  pkgs,
  ...
}: {
  boot.loader = {
    timeout = 1;
    efi = {
      canTouchEfiVariables = true;
    };
    grub = {
      enable = true;
      devices = ["nodev"];
      efiSupport = true;
      useOSProber = true;
      timeoutStyle = "countdown";
      default = "saved";
      splashImage = lib.mkForce null;
    };
  };
}
