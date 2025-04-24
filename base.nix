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

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      # "libtiff-4.0.3-opentoonz"
      "qbittorrent-4.6.4"
    ];
    packageOverrides = pkgs: {
      nur = import (
        builtins.fetchTarball {
          # Get the revision by choosing a version from https://github.com/nix-community/NUR/commits/master
          url = "https://github.com/nix-community/NUR/archive/d46254dd3f4953aede636c8938ded8b27b791730.tar.gz";
          # Get the hash by running `nix-prefetch-url --unpack <url>` on the above url
          sha256 = "0s1vik0kawm33njw72x6nz072mymg93dwsjq9aq1rrar9k4wddsx";
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
