#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/rg.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/rg.sh
##    https://davoudarsalani.ir

## https://github.com/junegunn/fzf/wiki/Examples

source ~/main/scripts/gb.sh
source ~/main/scripts/gb-color.sh

title="${0##*/}"

function display_help {
    source ~/main/scripts/.help.sh
    rg_help
}

function get_opt {
    local options

    options="$(getopt --longoptions 'help,case-sensitive,directory:' --options 'hcd:' --alternative -- "$@")"
    eval set -- "$options"
    while true; do
        case "$1" in
            -h|--help )
                display_help ;;
            -c|--case-sensitive )
                case_sensitive='--case-sensitive' ;;
            -d|--directory )
                shift
                directory="$1" ;;
            -- )
                break ;;
        esac
        shift
    done
}

case_sensitive=''

get_opt "$@"
heading "$title"

[ "$directory" ] || {
    directory="$(select_directory)" 2>/dev/null || exit 37
}
cd "$directory" || exit  ## TODO find how to pass $directory to RG in JUMP_1 instead of cding

fzf__title="rg in $(to_tilda "$PWD")"
main_item="$(pipe_to_fzf 'all' 'bash' 'python' 'html')" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    bash )
        RG+=' --type-not py' ;;
    python )
        RG+=' --type py' ;;
    html )
        RG+=' --type html' ;;
esac

RG+=" $case_sensitive"

## JUMP_1
INITIAL_QUERY=''
eval "$RG '$INITIAL_QUERY'" | sed "s#$HOME#~#" | \
    fzf --preview 'eval cat {-1} 2>/dev/null | \
                   eval "\rg $RG_MATCH_FLAGS" {q} 2>/dev/null' \
        --header "rg in $(to_tilda "$PWD")" \
        --bind "Return:reload:$RG {q} || true" --phony --query "$INITIAL_QUERY"
