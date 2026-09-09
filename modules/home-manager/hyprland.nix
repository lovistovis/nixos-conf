{
  inputs,
  lib,
  config,
  pkgs,
  my,
  ...
}: {
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    configType = "lua";
    extraConfig = import ../../config/hypr/hyprland-lua.nix {inherit pkgs config my;};
  };

  programs = {
    waybar = {
      enable = true;
      style = lib.mkAfter ''
        * {
          border: none;
          border-radius: 0;
          min-height: 0;
          font-size: 12px;
        }

        #workspaces button {
          background: transparent;
          min-width: 9px;
        }

        #workspaces button.focused {
          background: @base0D;
        }

        #workspaces button.urgent {
          background: @base0E;
        }
      '';
      settings = {
        mainBar = {
          layer = "top";
          position = "bottom";
          height = 10;
          modules-left = ["hyprland/workspaces"];
          modules-center = ["hyprland/window"];
          modules-right = ["pulseaudio" "network" "temperature" "disk" "memory" "battery" "clock" "tray"];

          "hyprland/workspaces" = {};

          "hyprland/window" = {
            format = "{title:.100}";
            rewrite = {
              "(.*) — Mozilla Firefox" = "$1";
              "(.*) — Mozilla Firefox Private Browsing" = "$1";
            };
          };

          "network" = {
            interval = 1;
            format = "{ifname}";
            format-wifi = "{essid} ({signalStrength}%)";
            format-ethernet = "{ipaddr}/{cidr}";
            format-disconnected = "";
            on-click = "alacritty -e zsh -c 'sudo nmtui'";
          };

          "temperature" = {
            thermal-zone = 1;
            interval = 5;
          };

          "disk" = {
            interval = 5;
            format = "{free} 🖴";
            on-click = "qdirstat";
          };

          "memory" = {
            interval = 5;
            format = "{avail}GiB 🎟";
            on-click = "alacritty -e zsh -c htop";
          };

          "battery" = {
            interval = 5;
            format-full = "{capacity}%";
            format-charging = "{capacity}% {time} chr";
            format-discharging = "{capacity}% {time} bat";
            format-icons = ["" "" "" "" ""];
          };

          "pulseaudio" = {
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = ["" "" ""];
            };
            on-click = "pavucontrol";
          };

          "clock" = {
            interval = 1;
            tooltip = true;
            format = "{:%H:%M:%S}";
            tooltip-format = "{:%Y-%m-%d}";
            on-click = "firefox https://youtube.com/@GLITCH";
          };
        };
      };
    };
  };

  services = {
    hyprpaper.settings.splash = false;

    mako = {
      enable = true;
      settings = {
        "actionable=true" = {
          anchor = "top-left";
        };
        actions = true;
        anchor = "top-right";
        default-timeout = 2000;
        ignore-timeout = true;
        icons = true;
      };
    };
  };
}
