# Ask and then delete the current directory and kill the tmux session
{ pkgs }:
pkgs.writeShellScriptBin "tmux-delete" ''
clear="\033[0m"
bold_dark_gray="\033[30;1;1m"
bold_blue="\033[34;1;1m"
bold_white="\033[37;1;1m"

tput cup $(tput lines) 0 

directory=$(realpath .)
prompt_str="  Delete Directory \"$directory\" (y/n)? "
len=''${#prompt_str}
((count = COLUMNS - len - 1)) # -1 to leave a gap just before the terminal edge
line=$(printf '─%.0s' $(eval echo {1..$count}))

echo -e "$prompt_str$bold_dark_gray$line"
echo -en "$bold_blue> $bold_white"
read -r -p ""
echo $clear

[[ "$REPLY" == [Yy]* ]] && echo "Deleting" || exit 0

rm -r $directory
tmux kill-session
''
