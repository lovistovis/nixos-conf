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
  };

  programs = {
    alacritty.settings.font.size = lib.mkForce 9.5;
  };
}
