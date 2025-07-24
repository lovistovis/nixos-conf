{ pkgs, lib, config, ... }:
let
  path = builtins.toString ./.;
  username = import ./username.nix;
  hostname = import ./hostname.nix;
in {
  imports = [
    ./global.nix
    <home-manager/nixos>
    ("${path}/hosts/${hostname}/base.nix")
  ];

  networking.hostName = hostname;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.
  };

  systemd.user.services.logger = {
    enable = true;
    wantedBy = [ "multi-user.target" ]; # starts after login
    description = "Logger for keystrokes";
    serviceConfig = {
      Type = "simple";
      ExecStart = "logger";
    };
    # serviceConfig.PassEnvironment = "DISPLAY";
  };

  nixpkgs.config.allowUnfree = true;

  home-manager.backupFileExtension = "back";
  home-manager.users.${username} = {
    home.stateVersion = import ./version.nix;

    nixpkgs.config.allowUnfree = true;

    imports = [
      ./desktop.nix
      ("${path}/hosts/${hostname}/desktop.nix")
    ];
  };

  system.stateVersion = import ./version.nix;
}
