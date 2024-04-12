{ pkgs }:
pkgs.writeShellScriptBin "tmux-create" ''
read -r -p "> "
mkdir $REPLY
tmux-sessionizer ./$REPLY
''
