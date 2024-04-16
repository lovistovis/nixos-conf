{ pkgs }:
pkgs.writeShellScriptBin "tmux-create" ''
clear="\033[0m"
bold_blue="\033[34;1;1m"
echo "hello"
#sleep 0.1


selected=$(find ~/ ~/projects ~/experiments -mindepth 0 -maxdepth 0 -type d | ${pkgs.fzf}/bin/fzf)
tput cup $(tput lines) 0 

prompt_str="  directory name: "
len=''${#prompt_str}
((count = COLUMNS - len))
echo $count
line=$(printf '─%.0s' $(eval echo {1..$count}))
#echo $line
echo -e "$prompt_str\033[30;1;1m$line"
read -r -p "$bold_blue> \033[37;1;1m"

echo $clear
cd $selected
mkdir $REPLY
tmux-sessionizer ./$REPLY
''
