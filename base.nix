{ pkgs, config, username, hostname, ... }:
let
  path = builtins.toString ./.;
in {
  imports = [
    ./global.nix
    <home-manager/nixos>
    ("${path}/hosts/${hostname}/base.nix")
  ];

  networking.hostName = hostname;

  nixpkgs.config.allowUnfree = true;

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
    #serviceConfig.PassEnvironment = "DISPLAY";
  };

  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "back";
  home-manager.users.mogos = {
    home.stateVersion = import ./version.nix;

    imports = [
      ./desktop.nix
      ("${path}/hosts/${hostname}/desktop.nix")
    ];
  };

  system.stateVersion = import ./version.nix;
}
