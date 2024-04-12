{ pkgs }:
pkgs.writeShellScriptBin "auto-restore" ''
if [ "$(tmux list-clients)" = "" ]; then
  ${pkgs.tmux}/bin/tmux run '${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/restore.sh' # auto restore
fi
''
