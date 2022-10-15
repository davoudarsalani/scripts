#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/mint
##    https://davoudarsalani.ir

## @last-modified 1401-07-20 10:04:40 +0330 Wednesday

source "$HOME"/scripts/gb

case "$1" in
    audio_levels )
        source "$HOME"/scripts/gb-audio
        printf '%s %s %s\n' "$vol_level" "$mic_level" "$mon_level" ;;
    vol_30 )
        source "$HOME"/scripts/gb-audio
        pactl set-sink-volume "$def_sink_index" 30% ;;
    cpu_temp )
        temps="$(sensors | \grep '^Core' | awk '{print $3}' | sed 's/+\([0-9]\+\).*/\1/g' | xargs)"  ## exceptionally used sensors (only for sony)
        cpu_count="$(wc -l < <(sed 's/ /\n/' <<< "$temps"))"

        (( cpu_count < 2 )) && if_one_cpu=" [${cpu_count} CPU ONLY]"

        (( total_temp="${temps// /+}" ))
        (( average="total_temp / cpu_count" ))

        printf '%s°%s\n' "$average" "$if_one_cpu" ;;
    idle )
        source "$HOME"/scripts/gb-calculation
        weekday="$(get_datetime 'jweekday')"
        current_date="$(get_datetime 'jymd')"
        current_datetime="$(get_datetime 'jymdhms')"

        idle_file=/tmp/idle-"$current_date"
        (( idle_secs="$(xprintidle) / 1000" ))
        perc="$(float_pad "${idle_secs}*100/3600" 1 2)"

        printf '%s\t%s\t%s\n' "$current_datetime" "$weekday" "$perc" >> "$idle_file"
        printf '%s\n' "$perc" ;;
    network )
        source "$HOME"/scripts/gb-network
        printf '%s  %s\n' "$eth_conn" "$wf_conn" ;;
    firefox_whatsapp )
        firefox --new-tab 'https://web.whatsapp.com' ;;
    if_uget )
        while true; do
            if [ ! "$(pgrep 'uget-gtk')" ]; then
                printf '>> started <<\n'
                uget-gtk 2>/dev/null &
            else
                printf 'running\n'
            fi
            sleep 60
        done ;;
esac
