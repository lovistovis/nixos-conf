# symlink to /etc/nixos/configuration.nix

{ pkgs, config, lib, ... }:
let
  username = (import "/home/mogos/nixos-conf/username.nix");
in
{
  imports = [
    ./hardware-configuration.nix
    (import "/home/${username}/nixos-conf/base.nix" {
      inherit pkgs lib config;
    })
  ];
}
