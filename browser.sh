#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/browser.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/browser.sh
##    https://davoudarsalani.ir


source ~/main/scripts/utils.sh

title="$(basename "$0")"

case "$1" in
    firefox )
        ff_items=( 'new page' 'new tab' 'private' )
        ff_item="$(pipe_to_rofi --header "$title" --subheader "$1" "${ff_items[@]}")" || exit 37

        case "$ff_item" in
            'new page' )
                firefox &>/dev/null & ;;
            'new tab' )
                firefox --new-tab 'https://www.google.com' &>/dev/null & ;;
            private )
                firefox --private-window &>/dev/null & ;;
        esac ;;
    chromium )
        chr_items=( 'new page' 'private' )
        chr_item="$(pipe_to_rofi --header "$title" --subheader "$1" "${chr_items[@]}")" || exit 37

        case "$chr_item" in
            'new page' )
                chromium &>/dev/null & ;;
            private )
                chromium --incognito &>/dev/null & ;;
        esac ;;
esac
