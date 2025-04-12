#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/browser.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/browser.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh

title="${0##*/}"

show_bookmarks=false

if [ "$show_bookmarks" == true ]; then
    readarray -t json_files < <(find ~/main/configs/cfg-firefox/ -mindepth 1 -maxdepth 1 -type f -iname 'bookmarks*.json' | sort)
    readarray -t bookmarks < <(jq -rM .'children[1].children' "${json_files[-1]}" | \grep '"uri"' | sed 's/^\s*"\(uri\|iconUri\)": "//;s/"$//' | \grep '^http' | sort)  ## NOTE keep \grep '^http' the last one
else
    bookmarks=()
fi

case "$1" in
    firefox )
        ff_items=( 'new page' 'new tab' 'private' "${bookmarks[@]}" )

        rofi__title="$title"
        rofi__subtitle="$1"
        ff_item="$(pipe_to_rofi "${ff_items[@]}")" || exit 37

        case "$ff_item" in
            'new page' )
                firefox &>/dev/null & ;;
            'new tab' )
                firefox --new-tab 'https://gitlab.com' &>/dev/null & ;;
            private )
                firefox --private-window &>/dev/null & ;;
            * )
                firefox "$ff_item" &>/dev/null & ;;
        esac ;;
    chromium )
        chr_items=( 'new page' 'private' "${bookmarks[@]}" )

        rofi__title="$title"
        rofi__subtitle="$1"
        chr_item="$(pipe_to_rofi "${chr_items[@]}")" || exit 37

        case "$chr_item" in
            'new page' )
                chromium &>/dev/null & ;;
            private )
                chromium --incognito &>/dev/null & ;;
            * )
                chromium "$chr_item" &>/dev/null & ;;
        esac ;;
esac
