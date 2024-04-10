{ pkgs, ... }:
let
  offload = import ./scripts/offload.nix { inherit pkgs; };
in
{
  programs = { };

  home.packages = with pkgs; [
    lshw
    offload
  ];
}
