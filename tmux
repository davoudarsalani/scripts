#!/usr/bin/env bash
source $HOME/scripts/gb

title="${0##*/}"
heading "$title"

main_items=( "list sessions" "attch to the last session" "attach to s specific session" "kill a specific session" "kill tmux" )
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    "list sessions" ) tmux list-sessions ;;
    "attch to the last session" ) tmux attach ;;
    "attach to s specific session" ) get_input "Session name" && session_name="$input"
                                     tmux attach -t "$session_name" ;;
    "kill a specific session" ) get_input "Session name" && session_name="$input"
                                tmux kill-session -t "$session_name" ;;
    "kill tmux" ) tmux kill-server ;;
esac

exit
