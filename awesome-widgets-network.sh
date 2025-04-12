#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/awesome-widgets-network.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/awesome-widgets-network.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh
source ~/main/scripts/gb-calculation.sh
source ~/main/scripts/gb-network.sh

## ⮝ U+2B9D
## ⮟ U+2B9F
## ⮜ U+2B9C
## ⮞ U+2B9E
down_icon="<span color=\"${gruvbox_blue_d}\">⮟ </span>"
up_icon="<span color=\"${gruvbox_purple_d}\">⮝ </span>"

diff_text=''
total_text=''

## connection -----------------------

[ "$eth_conn" == '--'        ] && eth_conn='' || eth_conn=" $eth_conn"
[ "$wf_conn" == 'MCI'        ] && if_simcard="<span color=\"${gruvbox_orange}\"> SIM</span>"
[ "$wf_state" == 'connected' ] || if_wf_down="<span color=\"${gruvbox_red}\"> WiFi DOWN</span>"
[ "$vpn_info"                ] && vpn_conn="<span color=\"${gruvbox_gray_d}\"> ${vpn_conn}</span>"

connection_text="${wf_conn}${eth_conn}${if_simcard}${if_wf_down}${vpn_conn}"

## total and diff -----------------------
## https://www.adminsehow.com/2010/03/shell-script-to-show-network-speed/

for interface in 'wifi' 'ethernet'; {
    case "$interface" in
        wifi )
            device_name="$wf_devc"
            interface_state="$wf_state"
            ;;
        ethernet )
            device_name="$eth_devc"
            interface_state="$eth_state"
            ;;
    esac

    [ "$interface_state" == 'connected' ] || continue

    down_last_file=~/main/scripts/.last/network_"${interface}"_down
    up_last_file=~/main/scripts/.last/network_"${interface}"_up

    ## get last total down/up
    down_total_last="$(< "$down_last_file")" || down_total_last=0  ## 19410508  ## NOTE do NOT add 2>/dev/null
    up_total_last="$(<   "$up_last_file")"   || up_total_last=0    ## 19410508  ## NOTE do NOT add 2>/dev/null

    ## get down_total_now/up_total_now
    ## NOTE do NOT replace " with ' in awk
    totals_now="$(\grep "$device_name" /proc/net/dev | awk '{print "down_total_now="$2, "up_total_now="$10}')"
    eval "$totals_now"  ## 19410509 789384

    ## save down_total_now/up_total_now as last
    ## for our next read
    ## (in bytes, before converting them)
    printf '%s\n' "$down_total_now" > "$down_last_file"
    printf '%s\n' "$up_total_now"   > "$up_last_file"

    ## ---

    ## set color for down_total_now/up_total_now
    total_color_low="$gruvbox_gray_d"
    total_color_medium="$gruvbox_gray_d"
    total_color_high="$gruvbox_purple"
    total_color_ultRRRigh="$gruvbox_red"

    if   (( down_total_now < "$K"     )); then down_total_color="$total_color_low"        ## is B
    elif (( down_total_now < "$M"     )); then down_total_color="$total_color_low"        ## is K
    elif (( down_total_now < "$M_400" )); then down_total_color="$total_color_low"        ## is below 400M
    elif (( down_total_now < "$M_700" )); then down_total_color="$total_color_medium"     ## is below 700M
    elif (( down_total_now < "$G"     )); then down_total_color="$total_color_high"       ## is below 1G
    else                                       down_total_color="$total_color_ultRRRigh"  ## is 1G or higher
    fi
    down_total_conv="<span color=\"${down_total_color}\">$(convert_byte "$down_total_now" 1 1)</span>"  ## 4.32G

    if   (( up_total_now < "$K"     )); then up_total_color="$total_color_low"        ## is B
    elif (( up_total_now < "$M"     )); then up_total_color="$total_color_low"        ## is K
    elif (( up_total_now < "$M_400" )); then up_total_color="$total_color_low"        ## is below 400M
    elif (( up_total_now < "$M_700" )); then up_total_color="$total_color_medium"     ## is below 700M
    elif (( up_total_now < "$G"     )); then up_total_color="$total_color_high"       ## is below 1G
    else                                     up_total_color="$total_color_ultRRRigh"  ## is 1G or higher
    fi
    up_total_conv="<span color=\"${up_total_color}\">$(convert_byte "$up_total_now" 1 1)</span>"  ## 4.32G

    ## ---
    ## calculate down_diff/up_diff

    ## for n seconds (i.e. network_refresh_interval seconds)
    (( down_diff="down_total_now - down_total_last" ))  ## 1341440
    (( up_diff="up_total_now - up_total_last" ))        ## 1341440
    ##
    ## average for one second
    (( down_diff="down_diff / network_refresh_interval" ))
    (( up_diff="up_diff / network_refresh_interval" ))

    ## ---
    ## set color for down_diff/up_diff

    diff_color_low="$gruvbox_fg"
    diff_color_medium="$gruvbox_fg"
    diff_color_high="$gruvbox_blue"
    diff_color_ultRRRigh="$gruvbox_green"

    if   (( down_diff < "$K"     )); then down_diff_color="$diff_color_low"        ## is B
    elif (( down_diff < "$K_400" )); then down_diff_color="$diff_color_low"        ## is below 400K
    elif (( down_diff < "$K_700" )); then down_diff_color="$diff_color_medium"     ## is below 700K
    elif (( down_diff < "$M"     )); then down_diff_color="$diff_color_high"       ## is below 1M
    else                                  down_diff_color="$diff_color_ultRRRigh"  ## is M or G
    fi
    down_diff_conv="<span color=\"${down_diff_color}\">$(convert_byte "$down_diff" 1 1)</span>"  ## 1.31M

    if   (( up_diff < "$K"     )); then up_diff_color="$diff_color_low"        ## is B
    elif (( up_diff < "$K_400" )); then up_diff_color="$diff_color_low"        ## is below 400K
    elif (( up_diff < "$K_700" )); then up_diff_color="$diff_color_medium"     ## is below 700K
    elif (( up_diff < "$M"     )); then up_diff_color="$diff_color_high"       ## is below 1M
    else                                up_diff_color="$diff_color_ultRRRigh"  ## is M or G
    fi
    up_diff_conv="<span color=\"${up_diff_color}\">$(convert_byte "$up_diff" 1 1)</span>"  ## 1.31M

    ## ---

    diff_text+=" | ${down_icon}${down_diff_conv}  ${up_icon}${up_diff_conv}"  ## 317K 2.31M
    total_text+=" | ${down_icon}${down_total_conv}  ${up_icon}${up_total_conv}"  ## 4.32G 4.32G
}

## remove leading ' | '
diff_text="${diff_text# | }"
total_text="${total_text# | }"

set_widget 'nw_connection' 'markup' "$connection_text"
set_widget 'nw_down_up'    'markup' "$diff_text"
set_widget 'nw_total'      'markup' "$total_text"
