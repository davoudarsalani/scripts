#!/usr/bin/env bash

## @last-modified 1400-09-27 21:07:08 +0330 Saturday

## https://github.com/junegunn/fzf/wiki/Examples

source "$HOME"/scripts/gb
source "$HOME"/scripts/gb-color

title="${0##*/}"
heading "$title"

cd "$(choose_directory)" 2>/dev/null || exit 37  ## TODO find how to pass $directory to RG in JUMP_1 instead of cding

main_item="$(pipe_to_fzf 'all' 'bash' 'python' "header=rg in ${PWD/$HOME/\~}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    bash )   RG+=' --type-not py' ;;
    python ) RG+=' --type py' ;;
esac

## JUMP_1
INITIAL_QUERY=''
eval "$RG '$INITIAL_QUERY'" | sed "s#$HOME#~#" | \
    fzf --preview 'eval "$HIGHLIGHT" {-1} 2>/dev/null | \
                   eval "rg $RG_MATCH_FLAGS" {q} 2>/dev/null' \
        --header "rg in ${PWD/$HOME/\~}" \
        --bind "Return:reload:$RG {q} || true" --phony --query "$INITIAL_QUERY"
