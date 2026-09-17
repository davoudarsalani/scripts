#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/awesome-apps.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/awesome-apps.sh
##    https://davoudarsalani.ir


case "$1" in
    android-studio )
        android-studio &>/dev/null & ;;
    audacious )
        audacious &>/dev/null & ;;
    blueman-applet )
        blueman-applet &>/dev/null & ;;
    blueman-manager )
        blueman-manager &>/dev/null & ;;
    chromium )
        chromium &>/dev/null & ;;
    dbgate )
        ~/main/configs/sources/dbgate/dbgate-latest.AppImage &>/dev/null & ;;
    firefox )
        firefox &>/dev/null & ;;
    gedit )
        gedit &>/dev/null & ;;
    gimp )
        gimp &>/dev/null & ;;
    goldendict )
        goldendict &>/dev/null & ;;
    gparted )
        sudo gparted &>/dev/null & ;;
    gthumb )
        gthumb &>/dev/null & ;;
    keepass )
        keepass &>/dev/null & ;;
    libreoffice )
        libreoffice &>/dev/null & ;;
    simplescreenrecorder )
        simplescreenrecorder &>/dev/null & ;;
    sublime )
        subl &>/dev/null & ;;
    terminal )
        "$terminal" &>/dev/null & ;;
    terminal_tmux )
        if process_is_running 'tmux'; then
            "$terminal" -e 'tmux new' &>/dev/null &
        else
            "$terminal" -e 'tmux new -s 1' &>/dev/null &
        fi ;;
    terminal_torsocks )
        torsocks "$terminal" &>/dev/null & ;;
    thunar )
        dir_path=~/main/downloads
        if [ -d "$dir_path" ]; then
            thunar "$dir_path" &>/dev/null &
        else
            thunar &>/dev/null &
        fi ;;
    uget )
        uget-gtk &>/dev/null & ;;
    visual-studio-code )
        code --disable-gpu &>/dev/null & ;;
    vlc )
        vlc &>/dev/null & ;;
    xreader )
        xreader &>/dev/null & ;;
esac
