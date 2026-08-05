{ pkgs, config, username }: with config.lib.stylix.colors; let
  rgb = color: "rgb(${color})";
in ''
mod = "SUPER"
term = "alacritty -e zsh -c ${pkgs.tmux}/bin/tmux"
menu = "j4-dmenu-desktop --dmenu=${pkgs.tofi}/bin/tofi"

hl.monitor({
  output = "",
  mode = "highres",
  position = "auto",
  scale = 1,
})

hl.config({
  general = {
    gaps_out = 10,
    gaps_in = 5,
    col = {
      active_border = "${rgb base03}",
      inactive_border = "${rgb base01}",
    }
  },
  input = {
    kb_layout = "se",
    touchpad = {
      disable_while_typing = false,
      tap_to_click = true,
      middle_button_emulation = false,
    }
  },
  xwayland = {
    force_zero_scaling = true
  },
  decoration = {
    blur = {
      enabled = false
    }
  },
  animations = {
    enabled = false
  },
})

hl.env("GDK_SCALE", "1")
hl.env("XCURSOR_SIZE", "32")

hl.bind(mod .. "+ Return", hl.dsp.exec_cmd(term))
hl.bind(mod .. "+ D", hl.dsp.exec_cmd(menu))
hl.bind(mod .. "+ F", hl.dsp.window.fullscreen())
hl.bind(mod .. "+ SHIFT + Space", hl.dsp.window.float())
hl.bind(mod .. "+ SHIFT + S", hl.dsp.exec_cmd("grim -g '$(slurp)' - | wl-copy"))
hl.bind(mod .. "+ SHIFT + Q", hl.dsp.window.close())
hl.bind(mod .. "+ SHIFT + W", hl.dsp.window.pin())
hl.bind(mod .. "+ SHIFT + E", hl.dsp.exit())
hl.bind(mod .. "+ SHIFT + L", hl.dsp.exec_cmd("${pkgs.hyprlock}/bin/hyprlock"))

hl.bind(mod .. "+ left", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. "+ right", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. "+ up", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. "+ down", hl.dsp.focus({ direction = "d" }))

hl.bind(mod .. "+ F3", hl.dsp.exec_cmd("brightnessctl set 1"))
hl.bind(mod .. "+ F4", hl.dsp.exec_cmd("brightnessctl set 100%"))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 1%+"), { locked = true, repeating = true, description = "Raise volume" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"),      { locked = true, repeating = true, description = "Lower volume" })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true, description = "Mute audio" })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true, description = "Mute microphone" })
hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 1%+"),                  { locked = true, repeating = true, description = "Increase brightness" })
hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 1%-"),                  { locked = true, repeating = true, description = "Decrease brightness" })

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true, description = "Move window with the mouse" })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Resize window with the mouse" })

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i}), { description = "Focus workspace " .. i })
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), { description = "Move window to workspace " .. i })
end

-- exec-once = [
--   "waybar"
--   "alacritty -e zsh -c \"tmux a -t ${username}\""
--   "firefox"
--   "pavucontrol"
--   "blueman-manager"
--   "iwgtk"
--   # "vesktop"
--   # "steam -silent"
-- ];

-- To find window classes use either
-- hyprctl clients | grep class
-- for wayland or
-- wmctrl -lx
-- for xwayland apps.
hl.window_rule({ match = { class = "firefox" }, workspace = "2 silent" })
hl.window_rule({ match = { class = "vesktop" }, workspace = "3 silent" })
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol" }, workspace = "10 silent" })
hl.window_rule({ match = { class = "blueman-manager" }, workspace = "10 silent" })
hl.window_rule({ match = { class = "org.twosheds.iwgtk" }, workspace = "10 silent" })

hl.window_rule({ match = { float = true }, no_blur = true })

hl.on("hyprland.start", function () 
  hl.exec_cmd("waybar")
  hl.exec_cmd("alacritty -e zsh -c \"tmux a -t ${username}\"")
  hl.exec_cmd("firefox")
  hl.exec_cmd("pavucontrol")
  hl.exec_cmd("blueman-manager")
  hl.exec_cmd("iwgtk")
  -- hl.exec_cmd("vesktop")
  -- hl.exec_cmd("steam -silent")
end)
''
