{ pkgs }:
pkgs.writeShellScriptBin "tmux-start" ''
tmux-store restore
${pkgs.tmux}/bin/tmux
''
