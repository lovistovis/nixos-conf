{
  pkgs,
  config,
  my,
}:
with config.lib.stylix.colors; let
  rgb = color: "#${color}";
in ''
  set $mod Mod4
  set $term alacritty -e zsh -c "tmux"
  set $menu j4-dmenu-desktop --dmenu="${pkgs.tofi}/bin/tofi" --term="alacritty"

  # -- appearance --
  gaps outer 10
  gaps inner 5
  smart_gaps on
  smart_borders on

  default_border pixel 2
  default_floating_border pixel 2

  client.focused          ${rgb base03} ${rgb base03} ${rgb base06} ${rgb base03} ${rgb base03}
  client.unfocused        ${rgb base01} ${rgb base01} ${rgb base05} ${rgb base01} ${rgb base01}
  client.focused_inactive ${rgb base01} ${rgb base01} ${rgb base05} ${rgb base01} ${rgb base01}

  # -- input --
  exec_always --no-startup-id setxkbmap se

  input type:touchpad {
    tap enabled
    natural_scroll enabled
    middle_emulation disabled
    dwt disabled
  }

  # -- env --
  exec_always --no-startup-id ${pkgs.xorg.xrdb}/bin/xrdb -merge <(echo "Xcursor.size: 32")
  exec_always --no-startup-id ${pkgs.xorg.xsetroot or pkgs.xorg.xset}/bin/xset r rate 300 50

  # -- core bindings --
  bindsym $mod+Return exec $term
  bindsym $mod+d exec $menu
  bindsym $mod+f fullscreen toggle
  bindsym $mod+Shift+space floating toggle
  bindsym $mod+Shift+s exec --no-startup-id "${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy"
  bindsym $mod+Shift+q kill
  bindsym $mod+Shift+w sticky toggle
  bindsym $mod+Shift+e exec --no-startup-id i3-msg exit
  bindsym $mod+Shift+l exec --no-startup-id "${pkgs.i3lock}/bin/i3lock"

  # -- focus movement --
  bindsym $mod+Left focus left
  bindsym $mod+Right focus right
  bindsym $mod+Up focus up
  bindsym $mod+Down focus down

  # -- brightness --
  bindsym $mod+F3 exec --no-startup-id "${pkgs.brightnessctl}/bin/brightnessctl set 1"
  bindsym $mod+F4 exec --no-startup-id "${pkgs.brightnessctl}/bin/brightnessctl set 100%"

  # -- media keys --
  bindsym --release XF86AudioRaiseVolume  exec --no-startup-id "${pkgs.wireplumber}/bin/wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 1%+"
  bindsym --release XF86AudioLowerVolume  exec --no-startup-id "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"
  bindsym --release XF86AudioMute         exec --no-startup-id "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
  bindsym --release XF86AudioMicMute      exec --no-startup-id "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
  bindsym --release XF86MonBrightnessUp   exec --no-startup-id "${pkgs.brightnessctl}/bin/brightnessctl -e4 -n2 set 1%+"
  bindsym --release XF86MonBrightnessDown exec --no-startup-id "${pkgs.brightnessctl}/bin/brightnessctl -e4 -n2 set 1%-"

  # -- mouse drag / resize (built into i3 via floating_modifier) --
  floating_modifier $mod

  # -- workspaces --
  bindsym $mod+1 workspace number 1
  bindsym $mod+2 workspace number 2
  bindsym $mod+3 workspace number 3
  bindsym $mod+4 workspace number 4
  bindsym $mod+5 workspace number 5
  bindsym $mod+6 workspace number 6
  bindsym $mod+7 workspace number 7
  bindsym $mod+8 workspace number 8
  bindsym $mod+9 workspace number 9
  bindsym $mod+0 workspace number 10

  bindsym $mod+Shift+1 move container to workspace number 1
  bindsym $mod+Shift+2 move container to workspace number 2
  bindsym $mod+Shift+3 move container to workspace number 3
  bindsym $mod+Shift+4 move container to workspace number 4
  bindsym $mod+Shift+5 move container to workspace number 5
  bindsym $mod+Shift+6 move container to workspace number 6
  bindsym $mod+Shift+7 move container to workspace number 7
  bindsym $mod+Shift+8 move container to workspace number 8
  bindsym $mod+Shift+9 move container to workspace number 9
  bindsym $mod+Shift+0 move container to workspace number 10

  # -- window assignments --
  # To find window classes use `xprop | grep WM_CLASS`
  assign [class="firefox"] workspace number 2
  assign [class="vesktop"] workspace number 3
  assign [class="Pavucontrol"] workspace number 10
  assign [class="Blueman-manager"] workspace number 10
  assign [class="Iwgtk"] workspace number 10

  for_window [class="firefox"] focus
  for_window [class="vesktop"] focus
  for_window [class="Pavucontrol"] focus
  for_window [class="Blueman-manager"] focus
  for_window [class="Iwgtk"] focus

  for_window [floating] border pixel 2

  # -- autostart --
  exec --no-startup-id waybar
  exec --no-startup-id "alacritty -e zsh -c \"tmux a -t ${my.username}\""
  exec --no-startup-id firefox
  exec --no-startup-id pavucontrol
  exec --no-startup-id blueman-manager
  exec --no-startup-id iwgtk
  # exec --no-startup-id vesktop
  # exec --no-startup-id steam -silent
''
