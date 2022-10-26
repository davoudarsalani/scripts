#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/mint
##    https://davoudarsalani.ir

## @last-modified 1401-07-28 14:51:58 +0330 Thursday

source "$HOME"/scripts/gb

case "$1" in
    audio_levels )
        source "$HOME"/scripts/gb-audio
        [ "$vol_mute_status" == 'yes' ] && vol_on_off=':OF'
        [ "$mic_mute_status" == 'no' ] && mic_on_off=':ON'
        [ "$mon_mute_status" == 'no' ] && mon_on_off=':ON'
        printf '%s%s %s%s %s%s\n' "$vol_level" "$vol_on_off" "$mic_level" "$mic_on_off" "$mon_level" "$mon_on_off" ;;
    cpu_temp )
        ## exceptionally used sensors (only for mint)
        temps="$(sensors | \grep '^Core' | awk '{print $3}' | sed 's/+\([0-9]\+\).*/\1/g' | xargs)"

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
        printf '%s %s\n' "$eth_conn" "$wf_conn" ;;
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
