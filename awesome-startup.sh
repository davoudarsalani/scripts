#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/awesome-startup.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/awesome-startup.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh

autorun_file=/tmp/autorun
[ -f "$autorun_file" ] && exit || touch "$autorun_file"

## tricks for the time when power saving screws audio
# printf '0\n' | sudo tee /sys/module/snd_hda_intel/parameters/power_save
# printf 'N\n' | sudo tee /sys/module/snd_hda_intel/parameters/power_save_controller
# sleep 2

# pulseaudio -k && \
# pulseaudio -D && \
# sleep .1
## previously (ditched after moving to SSD):
# pulseaudio --start &

start-pulseaudio-x11 || msgc "start-pulseaudio-x11 failed"

# source ~/main/scripts/gb-screen.sh
# xrandr --output  "$scr_1_name" --mode 1366x768 --rate 60 --primary
# xrandr --addmode "$scr_2_name" 1600x900
# xrandr --output  "$scr_2_name" --mode 1600x900 --rate 60 --right-of "$scr_1_name"
# xrandr --output  "$scr_2_name" --gamma .85:1:1.14  ## + custom mode (80 100 75)
# xrandr --output  "$scr_2_name" --gamma .65:1:.9    ## + standard mode

nm-applet &
greenclip daemon &
picom --daemon &  # --shadow-opacity=0

## key logger
# ~/main/scripts/.venv_keylogger/bin/python3 ~/main/scripts/.venv_keylogger/bin/keylogger \
# --log-file ~/main/configs/keylogs/keylog-"$(get_datetime 'jymd')" &


# source ~/main/scripts/gb-network.sh
# [ "$eth_ip" ] || {
#    add_desired_ip_to_ethernet
#    msgn "added <span color=\"${gruvbox_orange}\">${desired_eth_ip}</span> to <span color=\"${gruvbox_orange}\">${eth_devc}</span>"
# }


widgets=(
    # 'audio'
    # 'firewall'
    # 'bluetooth'
    # 'clipboard'
    # 'tor'
)

if [ "$widgets" ]; then
    for widget in "${widgets[@]}"; {
        ~/main/scripts/awesome-widgets.sh "$widget"
        sleep .1
    }
fi


declare -i desired_volume=30
while true; do
    source ~/main/scripts/gb-audio.sh
    pactl set-sink-volume "$def_sink_index" "${desired_volume}%"
    source ~/main/scripts/gb-audio.sh
    if (( vol_level == 30 )); then
        msgn "Volume set to $desired_volume"
        break
    fi
    msgc "Failed to set volume to $desired_volume"
    sleep 2
done
audacious ~/main/configs/sounds/login_mint.ogg &


msgn ' ' ' ' ~/main/configs/themes/ok-w.png
