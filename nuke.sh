#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/nuke.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/nuke.sh
##    https://davoudarsalani.ir


source ~/main/scripts/utils.sh

if (( UID > 0 )); then
    readarray -t processes < <(ps -f -u "$UID" --no-headers)
else
    readarray -t processes < <(ps -ef --no-headers)
fi

process="$(pipe_to_fzf "${processes[@]}")" && wrap_fzf_choice "$process" || exit 37

process="$(awk '{print $2}' <<< "$process")"

kill_prompt="$(get_input "kill ${process}?")"

case "$kill_prompt" in
    y ) if [ "$process" ] && [ "$process" -ne 0 ]; then
            ## prefer normal kill first
            kill "$process" || kill -9 "$process"
        fi ;;
esac
