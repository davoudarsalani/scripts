#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/power.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/power.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh

title="${0##*/}"

## options match ones in awesome-menu.sh
main_items=(
    'shutdown'
    'shutdown + clear clipboard'

    'reboot'
    'reboot + clear clipboard'

    'lock'
    'screen off'

    'quit awesome'
    'quit awesome + clear clipboard'
    'restart awesome'
)

rofi__title="$title"
# rofi__subtitle="$1"
main_item="$(pipe_to_rofi "${main_items[@]}")" || exit 37

case "$main_item" in
    shutdown )
        shutdown_now ;;
    'shutdown + clear clipboard' )
        greenclip_clear
        shutdown_now ;;

    reboot )
        reboot_now ;;
    'reboot + clear clipboard' )
        greenclip_clear
        reboot_now ;;

    lock )
        lock_now ;;
    'screen off' )
        turn_screen_off_now ;;

    'quit awesome' )
        quit_awesome_now ;;
    'quit awesome + clear clipboard' )
        greenclip_clear
        quit_awesome_now ;;
    'restart awesome' )
        restart_awesome_now ;;
esac
