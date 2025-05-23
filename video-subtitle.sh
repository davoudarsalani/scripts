#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/video-subtitle.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/video-subtitle.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh
source ~/main/scripts/gb-color.sh

trap 'width="$(tput cols)"' SIGWINCH

title="${0##*/}"

function display_help {
    source ~/main/scripts/.help.sh
    video_subtitle_help
}

function prompt {
    for _ in "$@"; {
        case "$1" in
            -d )
                dir="${dir:-"$(get_input 'directory')"}"
                [ -d "$dir" ] || {
                    red 'no such dir'
                    exit
                } ;;
        esac
        shift
    }
}

function get_opt {
    local options

    options="$(getopt --longoptions 'help,directory:' --options 'hd:' --alternative -- "$@")"
    eval set -- "$options"
    while true; do
        case "$1" in
            -h|--help )
                display_help ;;
            -d|--directory )
                shift
                dir="$1" ;;
            -- )
                break ;;
        esac
        shift
    done
}

get_opt "$@"
heading "$title"

main_items=( "replace ' ', ---, -_-, !, %, & and ," 'convert vtt to srt' 'change srt color to #f3f300' 'burn' 'remove TMPCOMMA and ----BURN' 'remove youtube ID' 'prepend random numbers' 'create 0-list' 'help' )
fzf__title=''
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    "replace ' ', ---, -_-, !, %, & and ," )
        replaced_en="$(get_single_input ' have you replaced .en.vtt with .vtt?')" && printf '\n'
        [ "$replaced_en" == 'y' ] || exit  ## NOTE do NOT remove

        prompt -d

        printf '\n'

        declare -i replaced_count=0
        readarray -t files < <(find "$dir" -mindepth 1 -maxdepth 1 | sort)
        for file in "${files[@]}"; {
            brown "→ $file"
            new_name="$(printf '%s\n' "$file" | \
                        sed -e 's/ /-/g' -e 's/\(---\|-_-\|-–-\|\%\|\!\)//g' -e 's/\&/and/g' -e 's/,/TMPCOMMA/g')"
            mv -nv "$file" "$new_name" && accomplished
            (( replaced_count++ ))
            line
        }
        printf '\n'
        blue "$replaced_count symbols replaced" ;;
    'convert vtt to srt' )
        prompt -d

        printf '\n'
        declare -i vtt_count=0
        readarray -t vtts < <(find "$dir" -mindepth 1 -maxdepth 1 -iname '*.vtt' | sort)
        for vtt in "${vtts[@]}"; {
            brown "→ $vtt"
            ffmpeg -i "$vtt" "${vtt%.vtt}".srt 2>/dev/null && accomplished
            (( vtt_count++ ))
            line
        }
        printf '\n'
        blue "$vtt_count vtts converted to srt" ;;
    'change srt color to #f3f300' )
        prompt -d

        printf '\n'
        declare -i srt_count=0
        readarray -t srts < <(find "$dir" -mindepth 1 -maxdepth 1 -iname '*.srt' | sort)
        for srt in "${srts[@]}"; {
            brown "→ $srt"
            sed -Ei '/(-->|^$|^[0-9][0-9]*$)/!s/^/<font color="#f3f300">/g' "$srt" && accomplished
            (( srt_count++ ))
            line
        }
        printf '\n'
        blue "$srt_count srts changed to #f3f300" ;;
    burn )
        prompt -d

        printf '\n'
        declare -i vid_count=0
        readarray -t vids < <(find "$dir" -mindepth 1 -maxdepth 1 -iname '*.mp4' | sort)
        for vid in "${vids[@]}"; {
            SECONDS=0
            already_burnt_count="$(wc -l < <(find "$dir" -mindepth 1 -maxdepth 1 -iname '*----BURN.mp4' | sort))"

            brown "→ $vid $(gray "(#"$(( "$already_burnt_count" + 1 ))")")"
            HandBrakeCLI -i "$vid" -o "${vid%.mp4}----BURN.mp4" --srt-file "${vid%.mp4}.srt" \
            --srt-codeset UTF-8 --srt-lang eng --srt-burn --encoder x264 --audio 1 2>/dev/null && {
                accomplished
            } || {
                red 'burn failed'
            }
            (( vid_count++ ))
            dur="$(convert_second "$SECONDS")"
            blue "Video burn duration: $dur"
            line
        }
        printf '\n'
        blue "$vid_count videos burned" ;;
    'remove TMPCOMMA and ----BURN' )
        prompt -d

        printf '\n'
        declare -i vids_count=0
        readarray -t rename_vids < <(find "$dir" -mindepth 1 -maxdepth 1 -iname '*.mp4' | sort)
        for rename_vid in "${rename_vids[@]}"; {
            brown "→ $rename_vid"
            new_name="$(printf '%s\n' "$rename_vid" | sed -e 's/TMPCOMMA/,/g;s/----BURN//g')"
            purple "$(mv -nv "$rename_vid" "$new_name")" && accomplished
            (( vids_count++ ))
            line
        }
        printf '\n'
        blue "$vids_count videos removed TMPCOMMA and ----BURN" ;;
    'remove youtube ID' )
        prompt -d

        printf '\n'
        declare -i burned_vid_count=0
        readarray -t burned_vids < <(find "$dir" -mindepth 1 -maxdepth 1 -iname '*.mp4' | sort)
        for burned_vid in "${burned_vids[@]}"; {
            brown "→ $burned_vid"
            new_name="$(printf '%s\n' "$burned_vid" | sed -e 's/.\{13\}mp4$/.mp4/')"
            purple "$(mv -nv "$burned_vid" "$new_name")" && accomplished
            (( burned_vid_count++ ))
            line
        }
        printf '\n'
        blue "$burned_vid_count youtube IDs removed" ;;
    'prepend random numbers' )
        declare -a rand_list

        prompt -d

        printf '\n'
        readarray -t rename_vids < <(find "$dir" -mindepth 1 -maxdepth 1 -iname '*.mp4' | sort)
        number_of_vids="${#rename_vids[@]}"

        ## create list and rand_list
        readarray -t list < <(seq "$number_of_vids")

        list_length="${#list[@]}"

        while [ "${list[0]}" ]; do  ## while array is full. no need to [@]
            (( rand_index="RANDOM % list_length" ))
            rand_member="${list[$rand_index]}"
            rand_list+=( "$rand_member" )
            unset "list[$rand_index]"
            readarray -t list < <(printf '%s\n' "${list[@]}")
            list_length="${#list[@]}"
        done

        ## prepend prefixes
        for ((i=0; i<"$number_of_vids"; i++)); {
            cur_vid="${rename_vids[$i]}"
            brown "→ $cur_vid"
            root="${cur_vid%/*}"
            base="${cur_vid##*/}"
            prefix="$(printf '%03d' "${rand_list[$i]}")"
            purple "$(mv -nv "$cur_vid" "${root}/${prefix}-${base}")" && accomplished
            line
        }
        printf '\n'
        blue "$i videos renamed randomly" ;;
    'create 0-list' )
        prompt -d
        find "$dir" -mindepth 1 -maxdepth 1 -iname '*.mp4' | sort | \
        sed -e 's/---/TMPPATTERN/g;s/--/TMPPATTERN/g;s/-/ /g;s/TMPPATTERN/ - /g' -e 's/\.mp4$//g' -e 's/^.\+\///g' > "$dir"/0-list.txt && accomplished ;;
    help )
        display_help ;;
esac
