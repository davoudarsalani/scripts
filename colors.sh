#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/colors.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/colors.sh
##    https://davoudarsalani.ir

## https://misc.flogisoft.com/bash/tip_colors_and_formatting

source ~/main/scripts/gb.sh

title="${0##*/}"

function tput_color {
    for c; {
        printf '\e[48;5;%dm%03d' "$c" "$c"
    }
    printf '\e[0m \n'
}

heading "$title"

fzf__title=''
main_item="$(pipe_to_fzf 'all' '38;5;{0-255} (foreground)' '48;5;{0-255} (background)' 'tput setaf')" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    all )
        for clbg in 49 {40..47}; {  ## {40..47} {100..107} 49
            for clfg in {30..37} 90; {  ## {30..37} {90..97} 39
                for attr in {0..4} 7 9; {
                    printf '\e[%s;%s;%sm %s;%s;%s \e[0m '  "$attr" "$clbg" "$clfg" "$attr" "$clbg" "$clfg"
                }
                printf '\n'
            }
            printf '\n'
        }
        printf '%s %s\n' "$(yellow Pattern:)" '\e[0;49;39m TEXT \e[0m' ;;
    '38;5;{0-255} (foreground)' )
        for clfg in {0..255}; {
            printf '\e[38;5;%dm %03d \e[0m' "$clfg" "$clfg"
        }
        printf '\n'
        printf '%s %s\n' "$(yellow Pattern:)" '\e[38;5;39m TEXT \e[0m' ;;
    '48;5;{0-255} (background)' )
        for clfg in {0..255}; {
            printf '\e[48;5;%dm %03d \e[0m' "$clfg" "$clfg"
        }
        printf '\n'
        printf '%s %s\n' "$(yellow Pattern:)" '\e[48;5;39m TEXT \e[0m' ;;
    'tput setaf' )
        ## https://unix.stackexchange.com/questions/269077/tput-setaf-color-table-how-to-determine-color-codes
        IFS=$' \t\n'
        tput_color {0..15}
        for ((i=0; i<6; i++)); {
            tput_color $(seq "$(( "$i" * 36 + 16 ))" "$(( "$i" * 36 + 51 ))")  ## NOTE do NOT change quotes
        }
        tput_color {232..255}
        printf '\n'
        printf '%s %s\n' "$(yellow Pattern:)" '$(tput bold)$(tput setaf 1) TEXT $(tput sgr 0)' ;;
esac
