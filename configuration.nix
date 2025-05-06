# symlink to /etc/nixos/configuration.nix

{ pkgs, config, lib, ... }:
let
  username = "nixos";     # TODO: Customize
  hostname = "wsl"; # Mapped to a dir in ./hosts
in
{
  imports =
    [
      # ./hardware-configuration.nix
      (import "/home/${username}/nixos-conf/base.nix" {
        inherit pkgs config username hostname;
      })
      # ./cachix.nix
      <nixos-wsl/modules>
    ];

  wsl.enable = true;
  wsl.defaultUser = "nixos";
}
