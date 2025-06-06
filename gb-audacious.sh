#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/gb-audacious.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/gb-audacious.sh
##    https://davoudarsalani.ir

length_in_seconds="$(audtool --current-song-length-seconds)" || length_in_seconds=0  ## 3304
length="$(audtool --current-song-length)"  ## 5:47

current_position_in_seconds="$(audtool --current-song-output-length-seconds)"  ## 369
current_position="$(audtool --current-song-output-length)"  ## 5:47

left_in_seconds="$(( "$length_in_seconds" - "$current_position_in_seconds" ))"  ## 187

position_in_playlist="$(audtool playlist-position)"  ## 3
playlist_length="$(audtool --playlist-length)"  ## 5

preamp="$(audtool equalizer-get-preamp | awk '{print $NF}')"  ## -2.10/0/etc

current_song="$(audtool --current-song-filename)"                   ## /home/nnnn/main/speech/pargar/007.mp3
current_song_base="$(audtool --current-song-tuple-data file-name)"  ## 007
current_song_dir="${current_song%/*}"                               ## /home/nnnn/main/speech/pargar
# ^^ OR current_song_dir="$(audtool --current-song-tuple-data file-path)"  ## ~/main/speech/pargar  ## throws error when used

formatted_title="$(audtool --current-song-tuple-data formatted-title)"  ## pargar - speech - 007
title="$(audtool --current-song-tuple-data title)"                      ## 007
album="$(audtool --current-song-tuple-data album)"                      ## speech
artist="$(audtool --current-song-tuple-data artist)"                    ## pargar
song_ext="$(audtool --current-song-tuple-data file-ext)"                ## mp3

shuffle_status="$(audtool --playlist-shuffle-status)"  ## on/off
play_status="$(audtool --playback-status)"  ## playing/paused

## NOTE if statement to void zero division error in JUMP_1
if (( length_in_seconds > 0 )); then
    bar_position="$(printf '%02d\n' "$(( "$current_position_in_seconds" * 100 / "$length_in_seconds" ))")"  ## <--,-- JUMP_1 19
                                                                                                            ##    |-- NOTE do NOT replace printf '%02d\n' with echo
                                                                                                            ##    '-- otherwise bar will not display amounts properly
else
    bar_position=0
fi
