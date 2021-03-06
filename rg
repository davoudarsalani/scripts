#!/usr/bin/env bash
source $HOME/scripts/gb

## https://github.com/junegunn/fzf/wiki/Examples

[ "$1" ] && {
    if [ "$1" == "s" ]; then
        cd $HOME/scripts
    elif [ "$1" == "l" ]; then
        cd $HOME/linux
    # else
    #     red "Wrong arg" && exit

    fi ;}

main_items=( "all" "bash" "python" )
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    all )    RG_PREF="rg               --sort path --hidden --files-with-matches --no-messages --color=always --smart-case -g '!{.git,kaddy,*venv*}/*'" ;;
    bash )   RG_PREF="rg --type-not py --sort path --hidden --files-with-matches --no-messages --color=always --smart-case -g '!{.git,kaddy,*venv*}/*'" ;;
    python ) RG_PREF="rg --type     py --sort path --hidden --files-with-matches --no-messages --color=always --smart-case -g '!{.git,kaddy,*venv*}/*'" ;;
esac

INITIAL_QUERY=""
CMD="$RG_PREF '$INITIAL_QUERY'" fzf \
--preview 'eval $HIGHLIGHT {-1} 2>/dev/null \
| rg --colors 'match:bg:green' --colors 'match:fg:black' --pretty {q}' \
--bind "Return:reload:$RG_PREF {q} || true" --phony --query "$INITIAL_QUERY"

exit
