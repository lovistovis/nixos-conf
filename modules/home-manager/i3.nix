{
  inputs,
  lib,
  config,
  pkgs,
  my,
  ...
}:
with config.lib.stylix.colors; let
  rgb = color: "#${color}";

  mod = "Mod4";
  term = "alacritty -e zsh -c ${pkgs.tmux}/bin/tmux";
  menu = "${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --dmenu=\"${pkgs.rofi}/bin/rofi -dmenu\"";
  lock = "${pkgs.i3lock}/bin/i3lock";
  screenshot = "${pkgs.maim}/bin/maim -s | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png";
in {
  home.sessionVariables = {
    GDK_SCALE = "1";
    XCURSOR_SIZE = "32";
  };

  xsession.windowManager.i3 = {
    enable = true;

    config = {
      modifier = mod;
      terminal = term;
      menu = menu;

      gaps = {
        inner = 5;
        outer = 10;
      };

      colors = {
        unfocused = {
          border = lib.mkForce "${rgb base01}";
        };
      };

      window.titlebar = false;
      floating.titlebar = false;

      floating.modifier = mod;

      keybindings = let
        m = mod;
      in
        {
          "${m}+Return" = "exec ${term}";
          "${m}+d" = "exec ${menu}";
          "${m}+f" = "fullscreen toggle";
          "${m}+Shift+space" = "floating toggle";
          "${m}+Shift+s" = "exec --no-startup-id ${screenshot}";
          "${m}+Shift+q" = "kill";
          "${m}+Shift+w" = "sticky toggle";
          "${m}+Shift+e" = "exit";
          "${m}+Shift+l" = "exec --no-startup-id ${lock}";

          "${m}+Left" = "focus left";
          "${m}+Right" = "focus right";
          "${m}+Up" = "focus up";
          "${m}+Down" = "focus down";

          "${m}+F3" = "exec --no-startup-id brightnessctl set 1";
          "${m}+F4" = "exec --no-startup-id brightnessctl set 100%";

          "XF86AudioRaiseVolume" = "exec --no-startup-id wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 1%+";
          "XF86AudioLowerVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-";
          "XF86AudioMute" = "exec --no-startup-id wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioMicMute" = "exec --no-startup-id wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          "XF86MonBrightnessUp" = "exec --no-startup-id brightnessctl -e4 -n2 set 1%+";
          "XF86MonBrightnessDown" = "exec --no-startup-id brightnessctl -e4 -n2 set 1%-";
        }
        // (builtins.listToAttrs (map (i: {
          name = "${m}+${toString (
            if i == 10
            then 0
            else i
          )}";
          value = "workspace number ${toString i}";
        }) (builtins.genList (x: x + 1) 10)))
        // (builtins.listToAttrs (map (i: {
          name = "${m}+Shift+${toString (
            if i == 10
            then 0
            else i
          )}";
          value = "move container to workspace number ${toString i}";
        }) (builtins.genList (x: x + 1) 10)));

      assigns = {
        "2" = [{class = "^firefox$";}];
        "3" = [{class = "^vesktop$";}];
        "10" = [
          {class = "^Pavucontrol$";}
          {class = "^Blueman-manager$";}
          {class = "^iwgtk$";}
        ];
      };

      startup = [
        {
          command = "${pkgs.feh}/bin/feh --bg-fill ~/nixos-conf/wallpapers/galaxy-red.png";
          always = true;
          notification = false;
        }
        {
          command = "setxkbmap se";
          always = true;
          notification = false;
        }
        {
          command = "alacritty -e zsh -c \"tmux a -t ${my.username}\"";
          always = false;
          notification = false;
        }
        {
          command = "firefox";
          always = false;
          notification = false;
        }
        {
          command = "pavucontrol";
          always = false;
          notification = false;
        }
        {
          command = "blueman-manager";
          always = false;
          notification = false;
        }
        {
          command = "iwgtk";
          always = false;
          notification = false;
        }
        # command = "vesktop";
        # command = "steam -silent";
      ];
    };
  };

  services = {
    picom = {
      enable = true;
      backend = "glx";
      vSync = true;
    };

    polybar = {
      enable = true;
      package = pkgs.polybar.override {
        i3Support = true;
        pulseSupport = true;
      };

      script = "polybar mainbar &";

      settings = {
        "bar/mainbar" = {
          width = "100%";
          height = 10;
          bottom = true;
          wm-restack = "i3";

          modules-left = "workspaces";
          modules-center = "xwindow";
          modules-right = "pulseaudio network temperature filesystem memory battery date tray";

          tray-position = "right";
          tray-padding = 2;

          font-0 = "monospace:size=9;2";

          border-size = 0;
          padding = 0;
        };

        "module/workspaces" = {
          type = "internal/i3";
          pin-workspaces = true;
          strip-wsnumbers = false;

          label-focused = "%index%";
          label-focused-padding = 2;
          label-focused-background = rgb base0D;

          label-unfocused = "%index%";
          label-unfocused-padding = 2;
          label-unfocused-background = "transparent";

          label-urgent = "%index%";
          label-urgent-padding = 2;
          label-urgent-background = rgb base0E;
        };

        "module/xwindow" = {
          type = "custom/script";
          exec = "${pkgs.xtitle}/bin/xtitle -s | ${pkgs.gnused}/bin/sed -u -E 's/ — Mozilla Firefox( Private Browsing)?$//; s/^(.{100}).+/\\1…/'";
          tail = true;
        };

        "module/network" = {
          type = "internal/network";
          interface-type = "wireless";
          interval = 1;
          format-connected = "<label-connected>";
          label-connected = "%essid% (%signal%%)";
          format-disconnected = "";
          click-left = "alacritty -e zsh -c 'sudo nmtui'";
        };

        "module/temperature" = {
          type = "internal/temperature";
          thermal-zone = 1;
          interval = 5;
          format = "<label>";
          label = "%temperature-c%";
        };

        "module/filesystem" = {
          type = "internal/fs";
          interval = 5;
          mount-0 = "/";
          label-mounted = "%free% 🖴";
          click-left = "qdirstat";
        };

        "module/memory" = {
          type = "internal/memory";
          interval = 5;
          label = "%gb_free%GiB 🎟";
          click-left = "alacritty -e zsh -c htop";
        };

        "module/battery" = {
          type = "internal/battery";
          battery = "BAT0";
          adapter = "AC";
          interval = 5;

          format-full = "<label-full>";
          label-full = "%percentage%%";

          format-charging = "<label-charging>";
          label-charging = "%percentage%% %time% chr";

          format-discharging = "<label-discharging>";
          label-discharging = "%percentage%% %time% bat";

          # format-icons = ["" "" "" "" ""]
          ramp-capacity-0 = "";
          ramp-capacity-1 = "";
          ramp-capacity-2 = "";
          ramp-capacity-3 = "";
          ramp-capacity-4 = "";
        };

        "module/pulseaudio" = {
          type = "internal/pulseaudio";

          format-volume = "<label-volume>";
          label-volume = "%percentage%% ";

          format-muted = "<label-muted>";
          label-muted = " ";

          click-left = "pavucontrol";
        };

        "module/date" = {
          type = "internal/date";
          interval = 1;
          date = "%H:%M:%S";
          date-alt = "%Y-%m-%d";
          format = "<label>";
          label = "%date%";
          click-left = "firefox https://youtube.com/@GLITCH";
        };
      };
    };
  };

  programs = {
    alacritty.settings.font.size = lib.mkForce 9.5;
  };
}
