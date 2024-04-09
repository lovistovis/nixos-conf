{ pkgs }:
pkgs.writeShellScriptBin "tmux-start" ''
#tmux-store restore
${pkgs.tmux}/bin/tmux
${pkgs.tmux}/bin/tmux souce-file ~/.config/tmux/tmux.conf
''
