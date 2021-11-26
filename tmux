#!/usr/bin/env bash

## last modified: 1400-09-02 23:12:01 +0330 Tuesday

source "$HOME"/scripts/gb

title="${0##*/}"
heading "$title"

function choose_session {  ## NOTE do NOT use local for variables
    session="$(pipe_to_fzf "${sessions[@]}")" && wrap_fzf_choice "$session" || exit 37  ## 2: 4 windows (created Sat Jul 10 09:43:05 2021)
    session="${session%%:*}"  ## 2
}

main_items=( 'list sessions' 'attch to the last session' 'attach to s specific session' 'kill a specific session' 'kill tmux' )
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

readarray -t sessions < <(tmux list-sessions)

case "$main_item" in
    'list sessions' ) printf '%s\n' "${sessions[@]}" ;;
    'attch to the last session' ) tmux attach ;;
    'attach to s specific session' ) choose_session
                                     tmux attach -t "$session" ;;
    'kill a specific session' ) choose_session
                                tmux kill-session -t "$session" ;;
    'kill tmux' ) tmux kill-server ;;
esac

exit
