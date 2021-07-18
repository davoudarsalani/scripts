#!/usr/bin/env bash
source "$HOME"/scripts/gb

title="${0##*/}"
heading "$title"

main_items=( "list sessions" "attch to the last session" "attach to s specific session" "kill a specific session" "kill tmux" )
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

sessions=( "$(tmux list-sessions)" )  ## exceptionally the middle part is quoted because the lines contain spaces

case "$main_item" in
    "list sessions" ) echo "${sessions[@]}" ;;
    "attch to the last session" ) tmux attach ;;
    "attach to s specific session" ) session="$(pipe_to_fzf "${sessions[@]}")" && wrap_fzf_choice "$session" || exit 37  ## 2: 4 windows (created Sat Jul 10 09:43:05 2021)
                                     session="${session%%:*}"  ## 2
                                     tmux attach -t "$session_name" ;;
    "kill a specific session" ) session="$(pipe_to_fzf "${sessions[@]}")" && wrap_fzf_choice "$session" || exit 37  ## 2: 4 windows (created Sat Jul 10 09:43:05 2021)
                                session="${session%%:*}"  ## 2
                                tmux kill-session -t "$session" ;;
    "kill tmux" ) tmux kill-server ;;
esac

exit
