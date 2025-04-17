#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/awesome-power.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/awesome-power.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh

## options match ones in power.sh
case "$1" in
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
