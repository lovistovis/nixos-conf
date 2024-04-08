# symlink to /etc/nixos/configuration.nix

{ config, lib, pkgs, ... }:
let
  username = "mogos";
  hostname = "nixbox-hp";
in
{
  imports =
    [ # Include the results of the hardware scan.
      # { _module.args = { inherit username hostname; }; }
      ./hardware-configuration.nix
      (import "/home/${username}/nixos-conf/base.nix" )#{ inherit username ; })
    ];
}
