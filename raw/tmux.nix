{ pkgs, config }: ''
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

set -as terminal-features ",alacritty*:RGB"

set -g base-index 1

set -g exit-empty off

CONFIG="${config.home.homeDirectory}/.config/tmux/tmux.conf"
bind-key r source-file $CONFIG
set-hook -g 'session-created' 'source-file $CONFIG' # Fixes C-a+a not working

bind-key C-f run-shell "tmux neww tmux-sessionizer"
bind-key C-c run-shell "tmux neww tmux-sessionizer ~/nixos-conf"
bind-key C-q run-shell "tmux neww tmux-sessionizer ~"

#set-hook -g 'session-closed' 'run "${pkgs.tmux}/bin/tmux send-keys C-a C-s"'
''
