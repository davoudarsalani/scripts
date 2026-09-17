#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/rg.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/rg.sh
##    https://davoudarsalani.ir


## https://github.com/junegunn/fzf/wiki/Examples

source ~/main/scripts/helps.sh
source ~/main/scripts/utils.sh
source ~/main/scripts/utils-color.sh

title="$(basename "$0")"

function get_opt {
    local options

    options="$(getopt --longoptions 'help,case-sensitive,exclude-static,directory:' --options 'hced:' --alternative -- "$@")"
    eval set -- "$options"
    while true; do
        case "$1" in
            -h|--help )
                rg_help ;;
            -c|--case-sensitive )
                case_sensitive='--case-sensitive' ;;

            ## to exclude static and staticfiles
            ## found in django projects
            -e|--exclude-static )
                exclude_static=true ;;

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
exclude_static=false

get_opt "$@"
heading "$title"

[ "$directory" ] || {
    directory="$(select_directory)" 2>/dev/null || exit 37
}

## TODO find how to pass $directory to RG in JUMP_1 instead of cding
cd "$directory" || exit


header="rg in $(to_tilda "$PWD")"
file_types=(
    'css'
    'html'
    'js'
    'json'
    'markdown'
    'py'
    'rust'
    'sh'
    'toml'
    'yaml'
)
all='all'
main_items="$(pipe_to_fzf --multi --header "$header" "$all" "${file_types[@]}")" && wrap_fzf_choice "$main_items" || exit 37

if echo "$main_items" | \grep -q "^$all$"; then
    ## do nothing
    :
else
    ## append selected types to RG
    while IFS= read -r item; do
        RG+=" --type $item"
    done <<< "$main_items"
fi


[ "$case_sensitive" ]         && RG+=" $case_sensitive"
[ "$exclude_static" == true ] && RG+=" --glob '!static/**' --glob '!staticfiles/**'"

## JUMP_1
INITIAL_QUERY=''
eval "$RG '$INITIAL_QUERY'" | \
    fzf --preview 'eval head -n 100000 {-1} 2>/dev/null | \
                   eval "\rg $RG_MATCH_FLAGS" {q} 2>/dev/null' \
        --header "$header" \
        --bind "Return:reload:$RG {q} || true" --phony --query "$INITIAL_QUERY"
