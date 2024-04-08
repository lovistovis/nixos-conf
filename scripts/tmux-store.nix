# Source: https://github.com/mislav/dotfiles/blob/d2af5900fce38238d1202aa43e7332b20add6205/bin/tmux-session
# Save and restore the state of tmux sessions and windows.
# TODO: persist and restore the state & position of panes.
{ pkgs, dotDir }:
pkgs.writeShellScriptBin "tmux-store" ''
set -e

dump() {
  local d=$'\t'
  ${pkgs.tmux}/bin/tmux list-windows -a -F "#S$\{d}#W$\{d}#{pane_current_path}"
}

save() {
  dump > "~/${dotDir}/.tmux-session"
  echo "saved to $(~/${dotDir}/)"
}

terminal_size() {
  stty size 2>/dev/null | awk '{ printf "-x%d -y%d", $2, $1 }'
}

session_exists() {
  ${pkgs.tmux}/bin/tmux has-session -t "$1" 2>/dev/null
}

add_window() {
  ${pkgs.tmux}/bin/tmux new-window -d -t "$1:" -n "$2" -c "$3"
}

new_session() {
  cd "$3" &&
  ${pkgs.tmux}/bin/tmux new-session -d -s "$1" -n "$2" $4
}

restore() {
  ${pkgs.tmux}/bin/tmux start-server
  local count=0
  local dimensions="$(terminal_size)"

  while IFS=$'\t' read session_name window_name dir; do
    if [[ -d "$dir" && $window_name != "log" && $window_name != "man" ]]; then
      if session_exists "$session_name"; then
        add_window "$session_name" "$window_name" "$dir"
      else
        new_session "$session_name" "$window_name" "$dir" "$dimensions"
        count=$(( count + 1 ))
      fi
    fi
  done < ~/${dotDir}/.tmux-session

  echo "restored $count sessions"
}

case "$1" in
save | restore )
  $1
  ;;
* )
  echo "valid commands: save, restore" >&2
  exit 1
esac
''
