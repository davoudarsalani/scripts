#!/usr/bin/env bash

## last modified: 1400-09-09 23:26:05 +0330 Tuesday

## https://github.com/junegunn/fzf/wiki/Examples

source "$HOME"/scripts/gb
source "$HOME"/scripts/gb-color

title="${0##*/}"

function display_help {
    source "$HOME"/scripts/.help
    r_help
}

function get_opts {
    local options="$(getopt --longoptions 'help,directory:' --options 'hd:' --alternative -- "$@")"
    eval set -- "$options"
    while true; do
        case "$1" in
            -h|--help )      display_help ;;
            -d|--directory ) shift; directory="$1" ;;
            -- )             break ;;
        esac
        shift
    done
}

get_opts "$@"
heading "$title"

cd "${directory:-.}"  ## TODO find how to pass $dest to rg down below before fzf instead of cding

main_item="$(pipe_to_fzf 'all' 'bash' 'python' 'help')" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    all )    : ;;
    bash )   RG="$RG --type-not py" ;;
    python ) RG="$RG --type py" ;;
    * ) display_help ;;
esac

INITIAL_QUERY=''
CMD="$RG '$INITIAL_QUERY'" fzf \
     --preview 'eval "$HIGHLIGHT" {-1} 2>/dev/null | \
                eval "rg $RG_MATCH_FLAGS" {q} 2>/dev/null' \
     --header "rg in ${PWD/$HOME/\~}" \
     --bind "Return:reload:$RG {q} || true" --phony --query "$INITIAL_QUERY"

exit
