#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/firewall.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/firewall.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh
source ~/main/scripts/gb-fir-blu-batt.sh

title="${0##*/}"

function display_help {
    source ~/main/scripts/.help.sh
    firewall_help
}

function update_firewall {
    ~/main/scripts/awesome-widgets.sh firewall
}

function prompt {
    for _ in "$@"; {
        case "$1" in
            -a ) app="${app:-"$(get_input 'application to allow')"}" ;;
        esac
        shift
    }
}

function get_opt {
    local options

    options="$(getopt --longoptions 'help,application:' --options 'ha:' --alternative -- "$@")"
    eval set -- "$options"
    while true; do
        case "$1" in
            -h|--help )
                display_help ;;
            -a|--application )
                shift
                app="$1" ;;
            -- )
                break ;;
        esac
        shift
    done
}

get_opt "$@"
heading "$title"

main_items=( 'status' 'turn on' 'turn off' 'enable' 'disable' 'allow outgoing' 'deny outgoing' 'allow incoming' 'deny incoming' 'allow application' 'allow kdeconnect' 'deny kdeconnect' 'help' )
fzf__title=''
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    status )
        sudo ufw status verbose && accomplished ;;
    'turn on' )
        sudo ufw enable  && update_firewall && accomplished ;;
    'turn off' )
        sudo ufw disable && update_firewall && accomplished ;;
    enable )
        sudo systemctl enable ufw && accomplished ;;
    disable )
        sudo systemctl disable ufw && accomplished ;;
    'allow outgoing' )
        sudo ufw default allow outgoing && accomplished ;;
    'deny outgoing' )
        sudo ufw default deny outgoing && accomplished ;;
    'allow incoming' )
        sudo ufw default allow incoming && accomplished ;;
    'deny incoming' )
        sudo ufw default deny incoming && accomplished ;;
    'allow application' )
        prompt -a
        sudo ufw allow "$app" && accomplished ;;
    'allow kdeconnect' )
        ## https://community.kde.org/KDEConnect
        action_now 'opening udp'
        sudo ufw allow 1714:1764/udp && accomplished
        action_now 'opening tcp'
        sudo ufw allow 1714:1764/tcp && accomplished
        accomplished 'Please reboot now.' ;;
    'deny kdeconnect' )
        action_now 'denying udp'
        sudo ufw deny 1714:1764/udp && accomplished
        action_now 'denying tcp'
        sudo ufw deny 1714:1764/tcp && accomplished
        accomplished 'Please reboot now.' ;;
    help )
        display_help ;;
esac
