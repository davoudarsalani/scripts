#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/awesome-apps.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/awesome-apps.sh
##    https://davoudarsalani.ir

case "$1" in
    audacious )
        audacious &>/dev/null & ;;
    blueman_applet )
        blueman-applet &>/dev/null & ;;
    blueman_manager )
        blueman-manager &>/dev/null & ;;
    chromium )
        chromium &>/dev/null & ;;
    dbgate )
        ## added this just to make sure dbgate is going to launch
        ## because it takes a few seconds to load
        msgn 'opening dbgate'

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
        if [ "$(pgrep 'tmux')" ]; then
            "$terminal" -e 'tmux new' &>/dev/null &
        else
            "$terminal" -e 'tmux new -s 1' &>/dev/null &
        fi ;;
    terminal_torsocks )
        torsocks "$terminal" &>/dev/null & ;;
    thunar )
        if [ -d ~/main/downloads/ ]; then
            thunar ~/main/downloads/ &>/dev/null &
        else
            thunar &>/dev/null &
        fi
        ;;
    uget )
        uget-gtk &>/dev/null & ;;
    visual-studio-code )
        code --disable-gpu &>/dev/null & ;;
    vlc )
        vlc &>/dev/null & ;;
    xreader )
        xreader &>/dev/null & ;;
esac
