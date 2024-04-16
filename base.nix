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
      nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
        inherit pkgs;
      };
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
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
