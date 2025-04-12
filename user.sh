#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/user.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/user.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh
source ~/main/scripts/gb-color.sh

title="${0##*/}"

function display_help {
    source ~/main/scripts/.help.sh
    user_help
}

function prompt {
    for _ in "$@"; {
        case "$1" in
            -g ) group="${group:-"$(get_input 'group')"}" ;;
        esac
        shift
    }
}

function get_opt {
    local options

    options="$(getopt --longoptions 'help,group:' --options 'hg:' --alternative -- "$@")"
    eval set -- "$options"
    while true; do
        case "$1" in
            -h|--help )
                display_help ;;
            -g|--group )
                shift
                group="$1" ;;
            -- )
                break ;;
        esac
        shift
    done
}

get_opt "$@"
heading "$title"

main_items=( 'info' 'create group' "add nnnn to a group" "remove nnnn from a group" 'change login name' 'how to useradd' 'help' )
fzf__title=''
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    info )
        printf 'User/ID:\t\t%s/%s\n' "$(id -un)" "$(id -u)"  ## OR $EUID (for user ID)
        printf 'Groups:\t\t\t%s\n' "$(groups "$(id -un)")"
        printf 'Groups IDs:\t\t%s\n' "$(id -G)"
        printf 'Effective group ID:\t%s\n' "$(id -g)" && accomplished ;;
    'create group' )
        prompt -g
        sudo groupadd -r "$group" && accomplished ;;
    "add nnnn to a group" )
        prompt -g
        sudo gpasswd -a nnnn "$group" && accomplished ;;
    "remove nnnn from a group" )
        prompt -g
        sudo gpasswd -d nnnn "$group" && accomplished ;;
    'change login name' )
        red_blink 'Use tty logged in as root'
        printf 'Syntax: usermod -l NEWNAME OLDNAME\n' ;;
    'how to useradd' )
        printf '%s\t\t%s\n' "$(yellow 'Syntax:')" 'useradd -m -g <initial_group> -G <additional_groups> -s <login_shell> <username> (-m creates the user home directory as /home/<username>)'
        printf '%s\t\t%s\n' "$(yellow 'e.g.:')" 'useradd -m -g users -G wheel,data,autologin -s /bin/bash/ jack' && accomplished ;;
    help )
        display_help ;;
esac
