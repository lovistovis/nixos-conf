{ pkgs, ... }:
let
  offload = import ./scripts/offload.nix { inherit pkgs; };
in
{
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
          modules-left = [ "hyprland/workspaces" ];
          modules-center = [ "hyprland/window" ];
          modules-right = [ "pulseaudio" "network" "temperature" "disk" "memory" "battery" "clock" "tray" ];

          "hyprland/workspaces" = { };

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

  gtk = {
    gtk4.theme = null;
  };

  home.packages = with pkgs; [
    lshw
    offload
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    configType = "hyprlang";
    settings = {
      "$mod" = "SUPER";
      "$term" = "alacritty -e zsh -c ${pkgs.tmux}/bin/tmux";
      "$menu" = "j4-dmenu-desktop --dmenu=${pkgs.tofi}/bin/tofi";
      bind = [
        "$mod, D, exec, $menu"
        "$mod, Return, exec, $term"
        "$mod, F, fullscreen"
        "$mod Shift, S, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod Shift, Q, killactive"
        "$mod Shift, Space, togglefloating"
        "$mod Shift, W, pin"
        "$mod Shift, E, exit"
        "$mod Ctrl, L, exec, ${pkgs.hyprlock}/bin/hyprlock"

        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        "$mod, F3, exec, brightnessctl set 1"
        "$mod, F4, exec, brightnessctl set 100%"
      ]
      ++ (
        builtins.concatLists (builtins.genList (i:
            let ws = i + 1;
            in [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspacesilent, ${toString ws}"
            ]
          )
          10)
       );
      bindel = [
        ", XF86MonBrightnessDown, exec, brightnessctl set 1%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set 1%+"

        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_SINK@ 1%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 1%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_SOURCE@ toggle"
      ];
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
      general = with config.lib.stylix.colors; let
          rgb = color: "rgb(${color})";
        in {
        gaps_out = 10;
        gaps_in = 5;
        "col.active_border" = lib.mkForce (rgb base03);
        "col.inactive_border" = lib.mkForce (rgb base01);
      };
      input = {
        kb_layout = "se";
        touchpad = {
          disable_while_typing = false;
          tap-to-click = true;
          middle_button_emulation = false;
        };
      };
      decoration = {
        blur = {
          enabled = false;
        };
      };
      animations.enabled = false;
      xwayland = {
        force_zero_scaling = true;
      };
      monitor = ", highres, auto, 1";
      env = [
        "GDK_SCALE,1"
        "XCURSOR_SIZE,32"
      ];
      exec-once = [
        "waybar"
        "alacritty -e zsh -c \"tmux a -t ${username}\""
        "firefox"
        "pavucontrol"
        "blueman-manager"
        "iwgtk"
        # "vesktop"
        # "steam -silent"
      ];
      # To find window classes use either
      # hyprctl clients | grep class
      # for wayland or
      # wmctrl -lx
      # for xwayland apps.
      windowrule = [
        "match:class firefox, workspace 2 silent"
        "match:class vesktop, workspace 3 silent"
        "match:class org.pulseaudio.pavucontrol, workspace 10 silent"
        "match:class .blueman-manager-wrapped, workspace 10 silent"
        "match:class org.twosheds.iwgtk, workspace 10 silent"

        "match:float true, no_blur on"
      ];
      ecosystem.no_update_news = true;
    };
  };


  services = {
    xidlehook = {
      enable = true;
      environment = {
        "sink_count" = "${pkgs.pulseaudio}/bin/pacmd list-sink-inputs | grep -c 'state: RUNNING'";
      };
      timers = [
        { # quiet-suspend-quick
          delay = 600;
          command = "if [ $sink_count -eq 0 ]; then ${pkgs.systemd}/bin/systemctl suspend; fi";
        }
        { # quiet-hibernate-quick
          delay = 600;
          command = "if [ $sink_count -eq 0 ]; then ${pkgs.systemd}/bin/systemctl hibernate; fi";
        }
        { # always-suspend-slow
          delay = 1800;
          command = "${pkgs.systemd}/bin/systemctl suspend";
        }
        { # always-hibernate-slow
          delay = 3600;
          command = "${pkgs.systemd}/bin/systemctl hibernate";
        }
      ];
    };
  };
}
