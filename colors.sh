#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/colors.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/colors.sh
##    https://davoudarsalani.ir


## https://misc.flogisoft.com/bash/tip_colors_and_formatting

source ~/main/scripts/utils.sh

title="$(basename "$0")"

function tput_color {
    for c; do
        printf '\e[48;5;%dm%03d' "$c" "$c"
    done
    printf '\e[0m \n'
}

heading "$title"

main_items=( 'all' '38;5;{0-255} (foreground)' '48;5;{0-255} (background)' 'tput setaf' )
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    all )
        for bg_ in 49 {40..47}; do  ## {40..47} {100..107} 49
            for fg_ in {30..37} 90; do  ## {30..37} {90..97} 39
                for attr in {0..4} 7 9; do
                    printf '\e[%d;%d;%dm %d;%d;%d \e[0m '  "$attr" "$bg_" "$fg_" "$attr" "$bg_" "$fg_"
                done
                printf '\n'
            done
            printf '\n'
        done
        printf '%s %s\n' "$(yellow Pattern:)" '\e[0;49;39m TEXT \e[0m' ;;
    '38;5;{0-255} (foreground)' )
        for fg_ in {0..255}; do
            printf '\e[38;5;%dm %03d \e[0m' "$fg_" "$fg_"
        done
        printf '\n'
        printf '%s %s\n' "$(yellow Pattern:)" '\e[38;5;39m TEXT \e[0m' ;;
    '48;5;{0-255} (background)' )
        for fg_ in {0..255}; do
            printf '\e[48;5;%dm %03d \e[0m' "$fg_" "$fg_"
        done
        printf '\n'
        printf '%s %s\n' "$(yellow Pattern:)" '\e[48;5;39m TEXT \e[0m' ;;
    'tput setaf' )
        ## https://unix.stackexchange.com/questions/269077/tput-setaf-color-table-how-to-determine-color-codes
        IFS=$' \t\n'
        tput_color {0..15}
        for ((i=0; i<6; i++)); do
            tput_color $(seq "$(( "$i" * 36 + 16 ))" "$(( "$i" * 36 + 51 ))")  ## NOTE do NOT change quotes
        done
        tput_color {232..255}
        printf '\n'
        printf '%s %s\n' "$(yellow Pattern:)" '$(tput bold)$(tput setaf 1) TEXT $(tput sgr 0)' ;;
esac
