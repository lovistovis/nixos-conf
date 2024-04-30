{ pkgs, config }: ''
#set status-utf8 on
#set utf8 on

#set -g default-terminal "screen-256color"

set -g status-bg colour0
set -g status-fg white

unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

set -as terminal-features ",alacritty*:RGB"

set -g base-index 1

set -g exit-empty off

CONFIG="${config.home.homeDirectory}/.config/tmux/tmux.conf"
bind-key r source-file $CONFIG
set-hook -g 'session-created' 'source-file $CONFIG' # Fixes C-a+a not working

bind-key C-k kill-session
bind-key C-l run-shell "tmux neww tmux-delete"

bind-key C-d run-shell "tmux neww tmux-create"
bind-key C-f run-shell "tmux neww tmux-sessionizer"
bind-key C-q run-shell "tmux neww tmux-sessionizer ~"
bind-key C-m run-shell "tmux neww tmux-sessionizer ~/music"
bind-key C-c run-shell "tmux neww tmux-sessionizer ~/nixos-conf"
bind-key C-h run-shell "tmux neww tmux-sessionizer ~/nixos-conf/hosts/nixbox-hp"
bind-key C-p run-shell "tmux neww tmux-sessionizer ~/nixos-conf/hosts/nixbox-pc"
''
