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
## ▲ ▼
down_icon="<span color=\"${gruvbox_blue_d}\">⮟</span>"
up_icon="<span color=\"${gruvbox_purple_d}\">⮝</span>"

total_color_low="$gruvbox_gray_d"
total_color_medium="$gruvbox_gray_d"
total_color_high="$gruvbox_purple"
total_color_ultRRRigh="$gruvbox_red"

diff_color_low="$gruvbox_fg"
diff_color_medium="$gruvbox_fg"
diff_color_high="$gruvbox_blue"
diff_color_ultRRRigh="$gruvbox_green"

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

for adapter in 'wifi' 'ethernet'; {
    case "$adapter" in
        wifi )
            device_name="$wf_devc"
            adapter_state="$wf_state"
            ;;
        ethernet )
            device_name="$eth_devc"
            adapter_state="$eth_state"
            ;;
    esac

    [ "$adapter_state" == 'connected' ] || continue

    ## get total last
    down_total_last="$(redis-cli GET "awesome_widget__${adapter}_down")"  ## 19410508
    up_total_last="$(  redis-cli GET "awesome_widget__${adapter}_up")"    ## 19410508
    ##
    [ "$down_total_last" ] || down_total_last=0
    [ "$up_total_last"   ] || up_total_last=0


    ## get total now
    ## NOTE do NOT " -> ' in awk
    _totals_now="$(\grep "$device_name" /proc/net/dev | awk '{print "down_total_now="$2, "up_total_now="$10}')"
    eval "$_totals_now"  ## 19410509 789384


    ## save for our next read
    ## (in bytes, before converting them)
    redis-cli SET "awesome_widget__${adapter}_down" "$down_total_now" || msgn 'ERROR saving down_total_now'
    redis-cli SET "awesome_widget__${adapter}_up"   "$up_total_now"   || msgn 'ERROR saving up_total_now'

    ## ---
    ## set total color

    if   (( down_total_now < "$K"     )); then down_total_color="$total_color_low"        ## is B
    elif (( down_total_now < "$M"     )); then down_total_color="$total_color_low"        ## is K
    elif (( down_total_now < "$M_400" )); then down_total_color="$total_color_low"        ## is below 400M
    elif (( down_total_now < "$M_700" )); then down_total_color="$total_color_medium"     ## is below 700M
    elif (( down_total_now < "$G"     )); then down_total_color="$total_color_high"       ## is below 1G
    else                                       down_total_color="$total_color_ultRRRigh"  ## is 1G or higher
    fi

    if   (( up_total_now < "$K"     )); then up_total_color="$total_color_low"        ## is B
    elif (( up_total_now < "$M"     )); then up_total_color="$total_color_low"        ## is K
    elif (( up_total_now < "$M_400" )); then up_total_color="$total_color_low"        ## is below 400M
    elif (( up_total_now < "$M_700" )); then up_total_color="$total_color_medium"     ## is below 700M
    elif (( up_total_now < "$G"     )); then up_total_color="$total_color_high"       ## is below 1G
    else                                     up_total_color="$total_color_ultRRRigh"  ## is 1G or higher
    fi

    ## ---
    ## convert total

    down_total_conv="<span color=\"${down_total_color}\">$(convert_byte "$down_total_now" 1 1)</span>"  ## 4.32G
    up_total_conv="<span color=\"${up_total_color}\">$(convert_byte "$up_total_now" 1 1)</span>"  ## 4.32G

    ## ---
    ## calculate diff

    ## devided by network_refresh_interval
    ## to get average for 1 second
    (( down_diff="(down_total_now - down_total_last) / network_refresh_interval" ))  ## 1341440
    (( up_diff="(up_total_now - up_total_last) / network_refresh_interval" ))        ## 1341440

    ## ---
    ## set diff color

    if   (( down_diff < "$K"     )); then down_diff_color="$diff_color_low"        ## is B
    elif (( down_diff < "$K_400" )); then down_diff_color="$diff_color_low"        ## is below 400K
    elif (( down_diff < "$K_700" )); then down_diff_color="$diff_color_medium"     ## is below 700K
    elif (( down_diff < "$M"     )); then down_diff_color="$diff_color_high"       ## is below 1M
    else                                  down_diff_color="$diff_color_ultRRRigh"  ## is M or G
    fi

    if   (( up_diff < "$K"     )); then up_diff_color="$diff_color_low"        ## is B
    elif (( up_diff < "$K_400" )); then up_diff_color="$diff_color_low"        ## is below 400K
    elif (( up_diff < "$K_700" )); then up_diff_color="$diff_color_medium"     ## is below 700K
    elif (( up_diff < "$M"     )); then up_diff_color="$diff_color_high"       ## is below 1M
    else                                up_diff_color="$diff_color_ultRRRigh"  ## is M or G
    fi

    ## ---
    ## convert diff

    down_diff_conv="<span color=\"${down_diff_color}\">$(convert_byte "$down_diff" 1 1)</span>"  ## 1.31M
    up_diff_conv="<span color=\"${up_diff_color}\">$(convert_byte "$up_diff" 1 1)</span>"  ## 1.31M

    ## ---

    diff_text+=" | ${down_icon} ${down_diff_conv}  ${up_icon} ${up_diff_conv}"  ## 317K 2.31M
    total_text+=" | ${down_icon} ${down_total_conv}  ${up_icon} ${up_total_conv}"  ## 4.32G 4.32G
}

## remove leading ' | '
diff_text="${diff_text# | }"
total_text="${total_text# | }"

set_widget 'nw_connection' 'markup' "$connection_text"
set_widget 'nw_down_up'    'markup' "$diff_text"
set_widget 'nw_total'      'markup' "$total_text"
