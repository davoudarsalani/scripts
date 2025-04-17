#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/movie.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/movie.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh
source ~/main/scripts/gb-audacious.sh
source ~/main/scripts/gb-duration.sh

function no_such_file {
    msgc 'ERROR' "no such file as <span color=\"${gruvbox_orange}\">$(to_tilda "$movie_full_path")</span>" ~/main/configs/themes/alert-w.png
    exit
}

function success_moving {
    local text

    text="$(printf "moved to <span color=\"%s\">WATCHED</span>\n<span color=\"%s\">%s</span>\n" "$gruvbox_blue" "$gruvbox_orange" "$no_suffix")"
    msgn "$text" '' ~/main/configs/themes/delete-w.png
}

function error_moving {
    msgc 'ERROR' "moving <span color=\"${gruvbox_orange}\">${no_suffix}</span> to <span color=\"${gruvbox_blue}\">WATCHED</span>" ~/main/configs/themes/alert-w.png
    # exit  ## exceptionally commented
}

function success_removing {
    msgn 'removed' "<span color=\"${gruvbox_red}\"><b>${no_suffix}</b></span>" ~/main/configs/themes/delete-w.png
}

function error_removing {
    msgc 'ERROR' "removing <span color=\"${gruvbox_orange}\">${no_suffix}</span>" ~/main/configs/themes/alert-w.png
}

function if_empty {  ## JUMP_1 the same used in ~/main/scripts/speech.sh
    ## remove all commas
    local count="${1//,/}"

    ## check if count is an int
    [ "$count" -eq "$count" ] || {
        msgc 'ERROR' "<span color=\"${gruvbox_orange}\">${count}</span> is invalid count" ~/main/configs/themes/alert-w.png
        exit
    }

    (( count > 0 )) || {
        msgn 'nothing here'
        exit
    }
}

function if_no_dir {  ## JUMP_1
    local directory="$1"

    [ -d ~/main/movie/"$directory" ] || {
        msgc 'ERROR' "no such directory as <span color=\"${gruvbox_orange}\">~/main/movie/${directory}</span>" ~/main/configs/themes/alert-w.png
        exit
    }
}

separator=' - '
declare -a directories_plus_count movies_array

[ "$play_status" == 'playing' ] && continue_playing='true' || continue_playing='false'

[ "$1" ] || exit
[ "$1" == 'random' ] && title='random movie' || title='select movie'

readarray -t directories < <(find ~/main/movie -mindepth 1 -maxdepth 1 -type d | sort)

## get movie count in each directory and prepend it to the directory name
for tmp_directory in "${directories[@]}"; {
    movies_count="$(wc -l < <(find "$tmp_directory" -mindepth 1 -maxdepth 1 -type f ! -iname '*.srt'))"

    ## skip adding directories with 0 files
    # if (( movies_count == 0 )); then
    #     continue
    # fi

    directories_plus_count+=( "${movies_count}${separator}${tmp_directory##*/}" )
}

# title="${0##*/}"

rofi__title="$title"
# rofi__subtitle=''
directory="$(pipe_to_rofi "${directories_plus_count[@]}")" || exit 37

read count separator directory <<< "$directory"
## count     is 8
## separator is -
## directory is parger

if_empty "$count"  ## NOTE if_empty must precede if_no_dir (i.e. JUMP_2)
if_no_dir "$directory"  ## JUMP_2

find_movies_cmd='find ~/main/movie/"$directory" -mindepth 1 -maxdepth 1 -type f ! -iname "*.srt"'
case "$1" in
    random )
        movie="$(shuf -n 1 < <(eval "$find_movies_cmd"))"
        movie="${movie##*/}" ;;
    select )
        readarray -t movies < <(eval "$find_movies_cmd" | sort)
        for m in "${movies[@]}"; {
            duration_second="$(get_duration "$m" "seconds")"
            duration="$(get_duration "$m")"
            short_duration="$(shorten_duration "$duration")"
            short_duration_and_movie="$(printf '%-10s%s\n' "$short_duration" "${m##*/}")"

            ## __PRINTF_LEFT_ALIGN__
            movies_array+=( "$short_duration_and_movie" )
        }

        rofi__title="$directory"
        rofi__subtitle="${#movies_array[@]} movies"
        movie="$(pipe_to_rofi "${movies_array[@]}")" || exit 37

        ## remove duration from beginning
        movie="$(printf '%s\n' "$movie" | sed 's/^.\+ \+//')" ;;
    * )
        exit ;;  ## NOTE do NOT remove
esac

## play
no_suffix="${movie%.*}"

movie_full_path=~/main/movie/"$directory"/"$movie"

srt_full_path="${movie_full_path%.*}.srt"

[ -f "$movie_full_path" ] || no_such_file

msgn 'playing' "<span color=\"${gruvbox_orange}\">${no_suffix}</span>" ~/main/configs/themes/filmroll-w.png
vlc -f --play-and-exit -- "$movie_full_path" 2>/dev/null

## move to WATCHED or remove
what_to_dos=( 'move to WATCHED' 'remove' )

rofi__title="$no_suffix"
rofi__subtitle="What to do now?"
what_to_do="$(pipe_to_rofi "${what_to_dos[@]}")"  # || exit 37  ## the exit is exceptionally commented

case "$what_to_do" in
    'move to WATCHED' )
        watched_dir=~/main/movie/"$directory"/WATCHED

        [ -d "$watched_dir" ] || mkdir "$watched_dir"

        {
            mv "$movie_full_path" "$watched_dir"

            ## mv srt
            if [ -f "$srt_full_path" ]; then
                mv "$srt_full_path" "$watched_dir"
            fi

        } && success_moving || error_moving ;;
    remove )
        {
            rm "$movie_full_path"

            ## rm srt
            if [ -f "$srt_full_path" ]; then
                rm "$srt_full_path"
            fi
        } && success_removing || error_removing ;;
    # * )  ## NOTE keep commented
    #     exit ;;
esac

## play audacious if it was playing before the video was played
[ "$continue_playing" == 'true' ] && ~/main/scripts/awesome-widgets.sh audacious play_pause
