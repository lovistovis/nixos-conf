{ pkgs, config, username, hostname, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  path = builtins.toString ./.;
in {
  imports = [
    ./global.nix
    ("${home-manager}/nixos")
    ("${path}/hosts/${hostname}/base.nix")
  ];

  networking.hostName = hostname;

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "libtiff-4.0.3-opentoonz"
    ];
    packageOverrides = pkgs: {
      nur = import (
        builtins.fetchTarball {
          # Get the revision by choosing a version from https://github.com/nix-community/NUR/commits/master
          url = "https://github.com/nix-community/NUR/archive/186d65571fdd7c6a1e0793e571bd9081dbef2633.tar.gz";
          # Get the hash by running `nix-prefetch-url --unpack <url>` on the above url
          sha256 = "015qvy4la51afn65qpradfi82jzr15r2g2g6hzbbzy9j8rwhpqps";
        }
      ) {
        inherit pkgs;
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "libvirtd" ]; # Enable ‘sudo’ for the user.
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
