#!/usr/bin/env bash

## last modified: 1400-09-10 21:53:49 +0330 Wednesday

## https://github.com/junegunn/fzf/wiki/Examples

source "$HOME"/scripts/gb
source "$HOME"/scripts/gb-color

title="${0##*/}"
heading "$title"

directory="$(choose_directory)" || exit 37

cd "$directory"  ## TODO find how to pass $directory to rg down below before fzf instead of cding

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
     --header "rg in ${PWD/$HOME/\~}" \
     --bind "Return:reload:$RG {q} || true" --phony --query "$INITIAL_QUERY"

exit
