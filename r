#!/usr/bin/env bash

## last modified: 1400-09-09 17:07:27 +0330 Tuesday

## https://github.com/junegunn/fzf/wiki/Examples

source "$HOME"/scripts/gb
source "$HOME"/scripts/gb-color

title="${0##*/}"
heading "$title"

[ "$1" ] && {
    if [ "$1" == 's' ]; then
        dest="$HOME"/scripts
    elif [ "$1" == 'l' ]; then
        dest="$HOME"/linux
    else
        red 'only l/s for arg' && exit
    fi

    cd "$dest"  ## TODO find how to pass $dest to rg instead of cding
}

main_item="$(pipe_to_fzf 'all' 'bash' 'python')" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    all )    : ;;
    bash )   RG="$RG --type-not py" ;;
    python ) RG="$RG --type py" ;;
esac

INITIAL_QUERY=''
CMD="$RG '$INITIAL_QUERY'" fzf \
     --preview 'eval "$HIGHLIGHT" {-1} 2>/dev/null | \
                eval "rg $RG_MATCH_FLAGS" {q} 2>/dev/null' \
     --header "rg in ${PWD//$HOME/\~}" \
     --bind "Return:reload:$RG {q} || true" --phony --query "$INITIAL_QUERY"

exit
