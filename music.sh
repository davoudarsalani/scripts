#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/music.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/music.sh
##    https://davoudarsalani.ir


source ~/main/scripts/utils.sh
source ~/main/scripts/utils-audacious.sh

function no_such_dir {
    msgc 'ERROR' "no such directory as <span color=\"${gruvbox_orange}\">~/main/music/${directory}</span>" ~/main/configs/themes/delete-w.png
    exit
}

function update_audacious {
    ~/main/scripts/awesome-widgets.sh audacious
}

title="$(basename "$0")"

readarray -t directories < <(find ~/main/music -mindepth 1 -maxdepth 1 -type d | sort)

directory="$(pipe_to_rofi --header "$title" "${directories[@]##*/}")" || exit 37

[ -d ~/main/music/"$directory" ] || no_such_dir

turn_on_shuffle; sleep 0.1
clear_playlist ; sleep 0.1

msgn 'playing' "<span color=\"${gruvbox_orange}\">${directory}</span>" ~/main/configs/themes/musical-note-w.png

## NOTE
##   - do NOT add cut -c 3- (it would open multiple error boxes
##     saying 'Error reading *****. No such file or directory')
##   - `-maxdepth 1` not needed here
readarray -t files < <(find ~/main/music/"$directory" -mindepth 1 -type f -iname '*.mp3' | sort)
audacious -E "${files[@]}"
update_audacious
