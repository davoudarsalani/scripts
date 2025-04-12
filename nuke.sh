#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/nuke.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/nuke.sh
##    https://davoudarsalani.ir

## https://revelry.co/terminal-workflow-fzf/
## https://github.com/junegunn/fzf/wiki/examples

source ~/main/scripts/gb.sh

IFS=$'\n'
if (( UID > 0 )); then
    readarray -t processes < <(ps -f -u "$UID")
else
    readarray -t processes < <(ps -ef)
fi

fzf__title=''
process="$(pipe_to_fzf "${processes[@]}")" && wrap_fzf_choice "$process" || exit 37

process="$(printf '%s\n' "$process" | awk '{print $2}')"

kill_prompt="$(get_single_input "kill ${process}?")" && printf '\n'
case "$kill_prompt" in
    y ) [ "$process" ] && printf '%s\n' "$process" | xargs -ro kill -9 ;;
esac
