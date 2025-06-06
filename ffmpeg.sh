#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/ffmpeg.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/ffmpeg.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh

title="${0##*/}"

function display_help {
    source ~/main/scripts/.help.sh
    ffmpeg_help
}

function prompt {
    for _ in "$@"; {
        case "$1" in
            -i )
                input_file="${input_file:-"$(get_input 'input file')"}" ;;
            -x )
                offset="${offset:-"$(get_input 'offset (e.g. 1.2 or -0.8)')"}" ;;
            -o )
                output="${output:-"$(get_input 'output file')"}" ;;
            -s )
                start="${start:-"$(get_input 'start time (e.g. 00:00:09)')"}" ;;
            -e )
                end="${end:-"$(get_input 'end time (e.g. 00:18:34)')"}" ;;
            -a )
                audio_input="${audio_input:-"$(get_input 'audio input file')"}" ;;
            -v )
                video_input="${video_input:-"$(get_input 'video input file')"}" ;;
            -t )
                time="${time:-"$(get_input 'time (e.g. 00:00:09)')"}" ;;
            -u )
                audio_stream="${audio_stream:-"$(get_input 'audio stream to keep (e.g. 1)')"}" ;;
            -c )
                if [ ! "$camera" ]; then
                    readarray -t cameras < <(find /dev/ -mindepth 1 -maxdepth 1 -iname '*video*' | sort)
                    fzf__title=''
                    camera="$(pipe_to_fzf "${cameras[@]}")" && wrap_fzf_choice "$camera" || exit 37
                fi
                ;;
            -f )
                sub_file="${sub_file:-"$(get_input 'subtitle file')"}" ;;
            -d )
                sub_index="${sub_index:-"$(get_input 'subtitle index (e.g. 0, 1, etc)')"}" ;;
        esac
        shift
    }
}

function get_opt {
    local options

    options="$(getopt --longoptions 'help,input-file:,offset:,output:,start:,end:,audio-input:,video-input:,time:,audio-stream:,camera:,subtitle-file:,subtitle-index:' \
                      --options 'hi:x:o:s:e:a:v:t:u:c:f:d:' \
                      --alternative -- "$@")"
    eval set -- "$options"
    while true; do
        case "$1" in
            -h|--help )
                display_help ;;
            -i|--input-file )
                shift
                input_file="$1" ;;
            -x|--offset )
                shift
                offset="$1" ;;
            -o|--output )
                shift
                output="$1" ;;
            -s|--start )
                shift
                start="$1" ;;
            -e|--end )
                shift
                end="$1" ;;
            -a|--audio-input )
                shift
                audio_input="$1" ;;
            -v|--video-input )
                shift
                video_input="$1" ;;
            -t|--time )
                shift
                time="$1" ;;
            -u|--audio-stream )
                shift
                audio_stream="$1" ;;
            -c|--camera )
                shift
                camera="$1" ;;
            -f|--subtitle-file )
                shift
                sub_file="$1" ;;
            -d|--subtitle-index )
                shift
                sub_index="$1" ;;
            -- )                  break ;;
        esac
        shift
    done
}

get_opt "$@"
heading "$title"

main_items=( 'embed subtitle' 'burn subtitle (increases size)' 'burn embedded subtitle (increases size)' 'sync audio' 'sync video' 'trim' 'convert' 'remove audio' 'replace audio' 'screenshot' 'negate' 'reverse' 'add 0.3 saturation' 'show streams' 'audio stream to keep' 'available cameras' 'live camera' 'help' )
fzf__title=''
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    'embed subtitle' )
        ## https://stackoverflow.com/questions/8672809/use-ffmpeg-to-add-text-subtitles
        prompt -i -f -o
        ffmpeg -i "$input_file" -i "$sub_file" -c:v copy -c:a copy -c:s mov_text "$output" 2>/dev/null && accomplished ;;
    'burn subtitle (increases size)' )
        ## https://stackoverflow.com/questions/8672809/use-ffmpeg-to-add-text-subtitles
        prompt -i -f -o
        ffmpeg -i "$input_file" -vf "subtitles=${sub_file}:force_style='FontSize=24,PrimaryColour=&H00f3f3&'" -c:a copy "$output" 2>/dev/null && accomplished ;;

        ## https://stackoverflow.com/questions/52338871/multicolor-text-in-ffmpeg
        ## "subtitles=${sub_file}:force_style='OutlineColour=&H80000000,BorderStyle=3,Outline=1,Shadow=0,MarginV=20,Borderstyle=4,BackColour=&H80000000,FontName=DejaVu Serif,FontSize=24,PrimaryColour=&H00f3f3&'"  ## here it should be 00f3f3 instead of f3f300 (why??)
        ## Format: Name,   Fontname    Fontsize    PrimaryColour   SecondaryColour OutlineColour   BackColour  Bold    Italic  Underline   StrikeOut   ScaleX  ScaleY    Spacing Angle   BorderStyle Outline Shadow  Alignment   MarginL MarginR MarginV Encoding
        ## Style:  Default Arial       20          &H00FFFFFF      &H000000FF      &H00000000      &H00000000  0       0       0           0           100     100       0       0       1           2       2       2           10      10      10      1
    'burn embedded subtitle (increases size)' )
        ## https://trac.ffmpeg.org/wiki/HowToBurnSubtitlesIntoVideo
        prompt -i -d -o
        ffmpeg -i "$input_file" -vf "subtitles=${input_file}:stream_index=${sub_index}:force_style='FontSize=24,PrimaryColour=&H00f3f3&'" -c:a copy "$output" 2>/dev/null && accomplished ;;

        ## https://stackoverflow.com/questions/52338871/multicolor-text-in-ffmpeg
        ## "subtitles=${sub_file}:force_style='OutlineColour=&H80000000,BorderStyle=3,Outline=1,Shadow=0,MarginV=20,Borderstyle=4,BackColour=&H80000000,FontName=DejaVu Serif,FontSize=24,PrimaryColour=&H00f3f3&'"  ## here it should be 00f3f3 instead of f3f300 (why??)
        ## Format: Name,   Fontname    Fontsize    PrimaryColour   SecondaryColour OutlineColour   BackColour  Bold    Italic  Underline   StrikeOut   ScaleX  ScaleY    Spacing Angle   BorderStyle Outline Shadow  Alignment   MarginL MarginR MarginV Encoding
        ## Style:  Default Arial       20          &H00FFFFFF      &H000000FF      &H00000000      &H00000000  0       0       0           0           100     100       0       0       1           2       2       2           10      10      10      1
    'sync audio' )
        prompt -i -x -o
        ffmpeg -i "$input_file" -itsoffset "$offset" -i "$input_file" -map 0:v -map 1:a -c copy -y "$output" 2>/dev/null && accomplished ;;
    'sync video' )
        prompt -i -x -o
        ffmpeg -i "$input_file" -itsoffset "$offset" -i "$input_file" -map 1:v -map 0:a -c copy -y "$output" 2>/dev/null && accomplished ;;
    trim )
        prompt -i -s -e -o
        ffmpeg -ss "$start" -i "$input_file" -to "$end" -c copy -y "$output" 2>/dev/null && accomplished ;;
    convert )
        prompt -i -o
        ffmpeg -i "$input_file" -q:a 1 -y "$output" 2>/dev/null && accomplished ;;
    'remove audio' )
        prompt -i -o
        ffmpeg -i "$input_file" -an -vcodec copy -y "$output" 2>/dev/null && accomplished ;;
    'replace audio' )
        prompt -a -v -o
        ffmpeg -i "$audio_input" -i "$video_input" -vcodec copy -acodec libmp3lame -y "$output" 2>/dev/null && accomplished ;;
    screenshot )
        prompt -i -t -o
        ffmpeg -ss "$time" -i "$input_file" -frames:v 1 -y "$output" 2>/dev/null && accomplished ;;
    negate )
        prompt -i -o
        ffmpeg -i "$input_file" -vf negate "$output" 2>/dev/null && accomplished ;;
    reverse )
        prompt -i -o
        ffmpeg -i "$input_file" -vf reverse "$output" 2>/dev/null && accomplished ;;
    'add 0.3 saturation' )
        prompt -i -o
        ffmpeg -i "$input_file" -vf eq=saturation=1.3 -c:a copy "$output" 2>/dev/null && accomplished ;;
    'show streams' )
        prompt -i
        printf 'Streams for %s:\n' "$input_file"
        ffmpeg -i "$input_file" 2>&1 | \grep -i 'Stream \#' | sed 's/^    //' 2>/dev/null && accomplished ;;
    'audio stream to keep' )
        prompt -i -u -o
        ffmpeg -i "$input_file" -map 0:0 -map 0:"$audio_stream" -c copy "$output" 2>/dev/null && accomplished ;;
    'available cameras' )
        available_cameras="$(find /dev/ -mindepth 1 -maxdepth 1 -iname '*video*' | sort)"
        printf '%s\n' "$available_cameras" ;;
    'live camera' )
        prompt -c
        ffplay "$camera" ;;
    help )
        display_help ;;
esac

## notes

## Add title:
# -metadata title='my title'

## Burn sub into a video
# ffmpeg -i <input> -vf subtitles=<subtitle> <output>

## Print connected webcams (requires ffmpeg) (https://trac.ffmpeg.org/wiki/Capture/Webcam):
# v4l2-ctl --list-devices

## Sync delayed audio (https://superuser.com/questions/982342/in-ffmpeg-how-to-delay-only-the-audio-of-a-mp4-video-without-converting-the-au)
# ffmpeg -i <input> -itsoffset -0.90 -i <input> -map 0:v -map 1:a -c copy <output>

## Sync delayed video (https://superuser.com/questions/982342/in-ffmpeg-how-to-delay-only-the-audio-of-a-mp4-video-without-converting-the-au)
# ffmpeg -i <input> -itsoffset -0.90 -i <input> -map 1:v -map 0:a -c copy <output>

## Trim video (https://stackoverflow.com/questions/18444194/cutting-the-videos-based-on-start-and-end-time-using-ffmpeg)
# ffmpeg -ss 00:00:03 -i <input> -to 00:04:00 -c copy <output>

## ╭────────────────────────┬───────────────────────────────────────────────╮
## │ Bitrate range (kbit/s) │ Option                                        │
## ├────────────────────────┼───────────────────────────────────────────────┤
## │ 320 CBR (non VBR)      │ -b:a 320k (NB this is 32KB/s, or its max)     │ ◄ [highest quelity]
## │ 220-260                │ -q:a 0    (NB this is VBR from 22 to 26 KB/s) │
## │ 190-250                │ -q:a 1                                        │
## │ 170-210                │ -q:a 2                                        │
## │ 150-195                │ -q:a 3                                        │
## │ 140-185                │ -q:a 4                                        │
## │ 120-150                │ -q:a 5                                        │
## │ 100-130                │ -q:a 6                                        │
## │ 80-120                 │ -q:a 7                                        │
## │ 70-105                 │ -q:a 8                                        │
## │ 45-85                  │ -q:a 9                                        │ ◄ [lowest quality]
## ├────────────────────────┴───────────────────────────────────────────────┤
## │ https://trac.ffmpeg.org/wiki/Encode/MP3                                │
## ╰────────────────────────────────────────────────────────────────────────╯
