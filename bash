#!/usr/bin/env bash

## @last-modified 1400-10-28 23:18:16 +0330 Tuesday

source "$HOME"/scripts/gb

title="${0##*/}"
heading "$title"

main_items=( 'disable history temporarily' 'enable history' 'current tty' 'current session' 'paths' 'exports' )
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    'disable history temporarily' )
        set +o history && accomplished ;;
    'enable history' )
        set -o history && accomplished ;;
    'current tty' )
        printf '%s\n' "$XDG_VTNR" && accomplished ;;
    'current session' )
        printf '%s\n' "$XDG_SESSION_ID" && accomplished ;;
    paths )
        printf '%s\n' "$PATH" && accomplished ;;
    exports )
        export -p && accomplished ;;
esac
