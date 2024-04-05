{ config, lib, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  hostname = "nixbox-hp";
in
{
  imports =
    [
    # <home-manager/nixos>
      ./global.nix
      (import "${home-manager}/nixos")
      (import "/home/mogos/.dotfiles/nixos/hosts/${hostname}/base.nix")
    ];

  networking.hostName = hostname;

  nixpkgs.config = {
    allowUnfree = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mogos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  home-manager.useGlobalPkgs = true;
  home-manager.backupFileExtension = "back";
  home-manager.users.mogos = {
    home.stateVersion = import ./version.nix;

    imports = [
      ./desktop.nix
      (import "/home/mogos/.dotfiles/nixos/hosts/${hostname}/desktop.nix")
    ];
  };

  system.stateVersion = import ./version.nix;
}
