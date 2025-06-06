#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/gb-screen.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/gb-screen.sh
##    https://davoudarsalani.ir

xrandr_output="$(xrandr)"

scr_1_name="$(printf '%s\n' "$xrandr_output" | \grep -iw 'connected' | \grep -i  'primary'              | awk '{print $1}')"
scr_2_name="$(printf '%s\n' "$xrandr_output" | \grep -iw 'connected' | \grep -iv 'primary' | sed '1q;d' | awk '{print $1}')"
scr_3_name="$(printf '%s\n' "$xrandr_output" | \grep -iw 'connected' | \grep -iv 'primary' | sed '2q;d' | awk '{print $1}')"

scr_1_res_total="$(printf '%s\n' "$xrandr_output" | \grep "^$scr_1_name" | awk '{print $4}')"  ## 1366x768+1920+0
scr_1_res="$(printf '%s\n' "$scr_1_res_total" | cut -d '+' -f 1)"  ## 1366x768
scr_1_x="$(printf '%s\n' "$scr_1_res" | cut -d 'x' -f 1)"  ## 1366
scr_1_y="$(printf '%s\n' "$scr_1_res" | cut -d 'x' -f 2)"  ## 768
scr_1_x_offset="$(printf '%s\n' "$scr_1_res_total" | sed "s/${scr_1_res}+//" | cut -d '+' -f 1)"  ## 1920
scr_1_y_offset="$(printf '%s\n' "$scr_1_res_total" | sed "s/${scr_1_res}+//" | cut -d '+' -f 2)"  ## 0

scr_2_res_total="$(printf '%s\n' "$xrandr_output" | \grep "^$scr_2_name" | awk '{print $3}')"
scr_2_res="$(printf '%s\n' "$scr_2_res_total" | cut -d '+' -f 1)"
scr_2_x="$(printf '%s\n' "$scr_2_res" | cut -d 'x' -f 1)"
scr_2_y="$(printf '%s\n' "$scr_2_res" | cut -d 'x' -f 2)"
scr_2_x_offset="$(printf '%s\n' "$scr_2_res_total" | sed "s/${scr_2_res}+//" | cut -d '+' -f 1)"
scr_2_y_offset="$(printf '%s\n' "$scr_2_res_total" | sed "s/${scr_2_res}+//" | cut -d '+' -f 2)"

scr_3_res_total="$(printf '%s\n' "$xrandr_output" | \grep "^$scr_3_name" | awk '{print $3}')"
scr_3_res="$(printf '%s\n' "$scr_3_res_total" | cut -d '+' -f 1)"
scr_3_x="$(printf '%s\n' "$scr_3_res" | cut -d 'x' -f 1)"
scr_3_y="$(printf '%s\n' "$scr_3_res" | cut -d 'x' -f 2)"
scr_3_x_offset="$(printf '%s\n' "$scr_3_res_total" | sed "s/${scr_3_res}+//" | cut -d '+' -f 1)"
scr_3_y_offset="$(printf '%s\n' "$scr_3_res_total" | sed "s/${scr_3_res}+//" | cut -d '+' -f 2)"

scr_all_res="$(printf '%s\n' "$xrandr_output" | \grep -iw 'current' | awk '{print $8 "" $9 "" $10}' | tr -d ',')"                    ## <--,
scr_all_x="$(printf '%s\n' "$xrandr_output"   | \grep -iw 'current' | awk '{print $8 "" $9 "" $10}' | tr -d ',' | cut -d 'x' -f 1)"  ## <--|-- NOTE do NOT replace " with ' in awk
scr_all_y="$(printf '%s\n' "$xrandr_output"   | \grep -iw 'current' | awk '{print $8 "" $9 "" $10}' | tr -d ',' | cut -d 'x' -f 2)"  ## <--'

screens_count="$(xrandr --listmonitors | sed '1q;d' | awk '{print $NF}')"
## OR <--,-- wc -l < <(printf '%s\n' "$xrandr_output" | \grep -iw connected | \grep '[0-9]\{3,4\}x[0-9]\{3,4\}')
##       '-- awesome-client 'return screen.count()' | awk '{print $NF}'

# scr_1_brightness="$(printf '%02d\n' "$(( "$(< /sys/devices/pci0000:00/0000:00:02.0/drm/card0/card0-"$scr_1_name"/intel_backlight/brightness)" * 200 / 187 / 2 ))")"
## OR:
# "$(xbacklight | cut -d '.' -f 1)"
