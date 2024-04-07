''
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix

set -as terminal-features ",alacritty*:RGB"

set -g base-index 1

bind-key -r f run-shell "tmux neww tmux-sessionizer"
''
