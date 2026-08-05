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
    j4-dmenu-desktop
    my-sddm-astronaut
  ];

  programs = {
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      xwayland.enable = true;
    };
  };

  security = {
    pam.services.hyprlock = {};
  };

  services = {
    dbus = {
      implementation = "broker";
    };

    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        package = pkgs.kdePackages.sddm;
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
      defaultSession = "hyprland";
    };
  };

  xdg.portal = {
    enable = true;
    # xdgOpenUsePortal = true;
    # config = {
    #   common.default = [ "gtk" ];
    #   hyprland.default = [ "gtk" "hyprland" ];
    # };
    # extraPortals = with pkgs; [
    #   xdg-desktop-portal-hyprland
    #   xdg-desktop-portal-gtk
    # ];
  };
}
