#!/usr/bin/env bash

## @last-modified 1401-06-17 09:27:14 +0330 Thursday

## https://github.com/junegunn/fzf/wiki/Examples

source "$HOME"/scripts/gb
source "$HOME"/scripts/gb-color

title="${0##*/}"

function display_help {
    source "$HOME"/scripts/.help
    r_help
}

function get_opt {
    local options

    options="$(getopt --longoptions 'help,directory:' --options 'hd:' --alternative -- "$@")"
    eval set -- "$options"
    while true; do
        case "$1" in
            -h|--help )
                display_help ;;
            -d|directory-- )
                shift
                directory="$1" ;;
            -- )
                break ;;
        esac
        shift
    done
}

get_opt "$@"
heading "$title"

[ "$directory" ] || {
    directory="$(select_directory)" 2>/dev/null || exit 37
}
cd "$directory" || exit  ## TODO find how to pass $directory to RG in JUMP_1 instead of cding

main_item="$(pipe_to_fzf 'all' 'bash' 'python' 'html' "header=rg in ${PWD/$HOME/\~}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    bash )
        RG+=' --type-not py' ;;
    python )
        RG+=' --type py' ;;
    html )
        RG+=' --type html' ;;
esac

## JUMP_1
INITIAL_QUERY=''
eval "$RG '$INITIAL_QUERY'" | sed "s#$HOME#~#" | \
    fzf --preview 'eval "$HIGHLIGHT" {-1} 2>/dev/null | \
                   eval "rg $RG_MATCH_FLAGS" {q} 2>/dev/null' \
        --header "rg in ${PWD/$HOME/\~}" \
        --bind "Return:reload:$RG {q} || true" --phony --query "$INITIAL_QUERY"
