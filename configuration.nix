# symlink to /etc/nixos/configuration.nix

{ pkgs, config, lib, ... }:
let
  username = "mogos";     # TODO: Customize
  hostname = "nixbox-hp"; # Mapped to a dir in ./hosts
in
{
  imports =
    [ # Include the results of the hardware scan.
      # { _module.args = { inherit username hostname; }; }
      ./hardware-configuration.nix
      (import "/home/${username}/nixos-conf/base.nix" {
        inherit pkgs config username hostname;
      })
    ];
}
