{ pkgs, lib, config, ... }:
let
  path = toString ./.;
  username = import ./username.nix;
  hostname = import ./hostname.nix;
  stateVersion = "25.05";
in {
  imports = [
    ./global.nix
    <home-manager/nixos>
    ("${path}/hosts/${hostname}/base.nix")
  ];

  networking.hostName = hostname;

  # Define a user account. Don't forget to set a password with "passwd".
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ];
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = stateVersion;
  nixpkgs.config.allowUnfree = true;

  home-manager.backupFileExtension = "back";
  home-manager.users.${username} = {
    home.stateVersion = stateVersion;
    nixpkgs.config.allowUnfree = true;

    imports = [
      ./home.nix
      ("${path}/hosts/${hostname}/home.nix")
    ];
  };
}
