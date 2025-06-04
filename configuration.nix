# symlink to /etc/nixos/configuration.nix

{ pkgs, config, lib, ... }:
let
  username = "mogos";     # TODO: Customize
  hostname = "nixbox-hp"; # Mapped to a dir in ./hosts
in
{
  imports =
    [
      ./hardware-configuration.nix
      (import "/home/${username}/nixos-conf/base.nix" {
        inherit pkgs config username hostname;
      })
      # ./cachix.nix
    ];
}
