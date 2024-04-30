# Interface for creating a directory in any path searched by tmux-sessionizer and opening it.
# The directory name prompt is engineered to look like fzf.
{ pkgs }:
pkgs.writeShellScriptBin "tmux-create" ''
clear="\033[0m"
bold_dark_gray="\033[30;1;1m"
bold_blue="\033[34;1;1m"
bold_white="\033[37;1;1m"

if [[ $# -eq 1 ]]; then
    selected=$1
else
    root_paths=$(echo "${import ../raw/search-paths.nix}" | xargs -I {} bash -c "realpath {}")
    selected=$(echo -e "$root_paths" | xargs -I {} find {} -mindepth 0 -maxdepth 0 -type d | ${pkgs.fzf}/bin/fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

tput cup $(tput lines) 0 

prompt_str="  Directory Name: "
len=''${#prompt_str}
((count = COLUMNS - len - 1)) # -1 to leave a gap just before the terminal edge
line=$(printf '─%.0s' $(eval echo {1..$count}))

echo -e "$prompt_str$bold_dark_gray$line"
echo -en "$bold_blue> $bold_white"
read -r -p ""
echo $clear

if [[ -z $REPLY ]]; then
    exit 0
fi

cd $selected
mkdir $REPLY
echo $(realpath ./$REPLY)
tmux-sessionizer $(realpath ./$REPLY)
''
