{
  inputs,
  lib,
  config,
  pkgs,
  my,
  ...
}: let
  wallpaper = ../../wallpapers/galaxy-red.png;
in {
  wayland.windowManager.sway = with {
    mod = "Mod4";
    term = "alacritty -e zsh -c ${pkgs.tmux}/bin/tmux";
  }; {
    enable = true;
    config = {
      modifier = mod;
      terminal = term;
      menu = "j4-dmenu-desktop";
      input = {
        "*" = {
          xkb_layout = "se";
        };
        "type:touchpad" = {
          dwt = "disabled";
          tap = "enabled";
          middle_emulation = "enabled";
        };
      };
      bars = [
        {
          command = "${pkgs.waybar}/bin/waybar";
        }
      ];
      colors = {
        unfocused = with config.lib.stylix.colors.withHashtag; {
          border = lib.mkForce base01;
          childBorder = lib.mkForce base01;
        };
      };
    };
    extraConfig = ''
      workspace "1" output primary

      gaps inner 5

      bindsym ${mod}+Shift+w sticky toggle

      bindsym ${mod}+Shift+s exec 'grim -g "$(slurp)" - | wl-copy'

      bindsym ${mod}+Control+l exec 'swaylock --image ${wallpaper}'

      # Brightness
      bindsym XF86MonBrightnessDown exec 'brightnessctl set 1%-'
      bindsym ${mod}+F3 exec 'brightnessctl set 1'
      bindsym XF86MonBrightnessUp exec 'brightnessctl set +1%'
      bindsym ${mod}+F4 exec 'brightnessctl set 100%'

      # Volume
      bindsym XF86AudioRaiseVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'
      bindsym XF86AudioLowerVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%'
      bindsym XF86AudioMute exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'

      # To find window class ids use either
      # swaymsg -t get_tree | grep app_id
      # for wayland or
      # wmctrl -lx
      # for xwayland apps. Use "app_id" for
      # wayland apps and "class" for xwayland apps

      assign [app_id="firefox"] 2
      assign [class="vesktop"] 3
      assign [app_id="org.pulseaudio.pavucontrol"] 10
      assign [app_id=".blueman-manager-wrapped"] 10

      # exec ${pkgs.tmux}/bin/tmux start-server # avoid the wait for restoring sessions
      exec --no-startup-id swaymsg 'workspace 1; exec --no-startup-id ${term}'
      exec --no-startup-id firefox
      exec --no-startup-id vesktop
      exec --no-startup-id pavucontrol
      exec --no-startup-id blueman-manager
    '';
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
          modules-left = ["sway/workspaces" "sway/mode"];
          modules-center = ["sway/window"];
          modules-right = ["network" "disk" "memory" "temperature" "battery" "clock" "tray"];

          "sway/workspaces" = {
            disable-scroll = true;
            disable-mouse = true;
            all-outputs = true;
          };

          "network" = {
            interval = 1;
            format = "{ifname}";
            format-wifi = "{essid} ({signalStrength}%)";
            format-ethernet = "{ipaddr}/{cidr}";
            format-disconnected = "";
          };

          "disk" = {
            interval = 5;
            format = "{free}";
          };

          "memory" = {
            interval = 5;
            format = "{avail}GiB";
          };

          "temperature" = {
            thermal-zone = 1;
            interval = 5;
          };

          "battery" = {
            interval = 5;
            format-charging = "{capacity}% {time} chr";
            format-discharging = "{capacity}% {time} bat";
            format-full = "{capacity}% max";
          };

          "clock" = {
            interval = 1;
            tooltip = true;
            format = "{:%H:%M:%S}";
            tooltip-format = "{:%Y-%m-%d}";
          };
        };
      };
    };
  };
}
