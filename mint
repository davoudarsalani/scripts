#!/usr/bin/env bash

## last modified: 1400-09-02 23:12:01 Tuesday

source "$HOME"/scripts/gb

case "$1" in
    vol_level ) source "$HOME"/scripts/gb-audio
                states_initials="${vol_state::1}${mic_state::1}${mon_state::1}"  ## RSI
                indeces="${def_sink_index}${def_source_index}${def_source_mon_index}"  ## 010
                printf '%s  %s  %s\n' "$vol_level" "$states_initials" "$indeces" ;;
    vol_30 ) source "$HOME"/scripts/gb-audio
             pactl set-sink-volume "$def_sink_index" 30% ;;
    cpu_temp ) read -a temps < <(sensors | \grep '^Core' | awk '{print $3}' | sed 's/+\([0-9]\+\).*/\1/g')  ## exceptionally calculated in this way (only for sony)
               let total_temp="${temps// /+}"  ## no need to [@]
               length="${#temps[@]}"
               let average="$total_temp / $length"
               printf '%s\n' "${average}°" ;;
    idle ) source "$HOME"/scripts/gb-calculation
           weekday="$(get_datetime 'jweekday')"
           current_date="$(get_datetime 'jymd')"
           current_datetime="$(get_datetime 'jymdhms')"

           idle_file=/tmp/idle-"$current_date"
           let idle_secs="$(xprintidle) / 1000"
           perc="$(float_pad "${idle_secs}*100/3600" 1 2)"

           ## it's better to display perc as 0 if it is 0.00
           perc_is_zero="$(compare_floats "$perc" '=' 0)"
           [ "$perc_is_zero" == 'true' ] && perc=0

           printf '%s\t%s\t%s\n' "$current_datetime" "$weekday" "$perc" >> "$idle_file"
           printf '%s\n' "$perc" ;;
    network ) source "$HOME"/scripts/gb-network
              printf '%s   %s\n' "$eth_conn" "$wf_conn"

              ## ping and send messages if unsuccessful
              output="$(ping -c 1 4.2.2.4 2>&1)"
              [ "$(printf '%s\n' "$output" | \grep -i 'network is unreachable')" ] && {
                  for ((i=1; i<=10; i++)); {
                      msgn "$output"
                      sleep 0.1
                  }
              } ;;
    firefox_whatsapp ) firefox --new-tab 'https://web.whatsapp.com' ;;
    if_uget ) while true; do
                  if [ ! "$(pgrep 'uget-gtk')" ]; then
                      printf '%s\n' '>> started <<'
                      uget-gtk 2>/dev/null &
                  else
                      printf '%s\n' 'running'
                  fi
                  sleep 60
              done ;;
esac

exit
