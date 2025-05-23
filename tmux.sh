#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/tmux.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/tmux.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh

title="${0##*/}"
heading "$title"

function choose_session {  ## NOTE do NOT use local for variables
    fzf__title=''
    session="$(pipe_to_fzf "${sessions[@]}")" && wrap_fzf_choice "$session" || exit 37  ## 2: 4 windows (created Sat Jul 10 09:43:05 2021)
    session="${session%%:*}"  ## 2
}

main_items=( 'list sessions' 'attch to the last session' 'attach to s specific session' 'kill a specific session' 'kill tmux' )
fzf__title=''
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

readarray -t sessions < <(tmux list-sessions)

case "$main_item" in
    'list sessions' )
        printf '%s\n' "${sessions[@]}" ;;
    'attch to the last session' )
        tmux attach ;;
    'attach to s specific session' )
        choose_session
        tmux attach -t "$session" ;;
    'kill a specific session' )
        choose_session
        tmux kill-session -t "$session" ;;
    'kill tmux' )
        tmux kill-server ;;
esac
