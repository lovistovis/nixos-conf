{config}: ''
  unbind C-b
  set-option -g prefix C-a
  bind-key C-a send-prefix

  set -as terminal-features ",alacritty*:RGB"

  set -g base-index 1

  bind-key r source-file ${config.home.homeDirectory}/.config/tmux/tmux.conf

  bind-key C-f run-shell "tmux neww tmux-sessionizer"
  bind-key C-c run-shell "tmux neww tmux-sessionizer ~/nixos-conf"
  bind-key C-q run-shell "tmux neww tmux-sessionizer ~"
''
