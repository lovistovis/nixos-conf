{ inputs, pkgs, ... }:
let
  my-sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "hyprland_kath";
    themeConfig = {
      Background = toString /etc/nixos/wallpaper.png; # This theme also accepts videos
    };
  };
in
{
  environment.systemPackages = with pkgs; [
    grim
    slurp
    wl-clipboard
    wayland-utils
    my-sddm-astronaut
  ];

  services = {
    dbus = {
      implementation = "broker";
    };

    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        extraPackages = with pkgs; [
          kdePackages.qtmultimedia
        ];
        theme = "sddm-astronaut-theme";
        settings = {
          Theme = {
            Current = "sddm-astronaut-theme";
          };
        };
      };
    };
  };
}
