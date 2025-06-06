#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/network.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/network.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh
source ~/main/scripts/gb-network.sh

title="${0##*/}"

function display_help {
    source ~/main/scripts/.help.sh
    network_help
}

function add_desired_ip_to_ethernet {
    source ~/main/scripts/gb-network.sh
    sudo ip address add "$desired_eth_ip" broadcast + dev "$eth_devc"
}

function prompt {
    for _ in "$@"; {
        case "$1" in
            -i )
                ip="${ip:-"$(get_input 'ip')"}" ;;
            -d )
                device="${device:-"$(get_input 'device (e.g. eth0)')"}" ;;
            -c )
                connection="${connection:-"$(get_input 'connection (e.g. MOB)')"}" ;;
            -s )
                ssid="${ssid:-"$(get_input 'ssid')"}" ;;
            -p )
                password="${password:-"$(get_input 'password')"}" ;;
        esac
        shift
    }
}

function get_opt {
    local options

    options="$(getopt --longoptions 'help,ip:,device:,connection:,ssid:,password:' --options 'hi:d:c:s:p:' --alternative -- "$@")"
    eval set -- "$options"
    while true; do
        case "$1" in
            -h|--help )
                display_help ;;
            -i|--ip )
                shift
                ip="$1" ;;
            -d|--device )
                shift
                device="$1" ;;
            -c|--connection )
                shift
                connection="$1" ;;
            -s|--ssid )
                shift
                ssid="$1" ;;
            -p|--password )
                shift
                password="$1" ;;
            -- )
                break ;;
        esac
 shift
    done
}

get_opt "$@"
heading "$title"

main_items=( 'all' 'status + ip + mac address' 'available wifi access points' "connect $eth_devc" "disconnect $eth_devc" "connect $wf_devc" "disconnect $wf_devc" 'up ethernet/wifi connection' 'down ethernet/wifi connection' 'turn wifi on' 'turn wifi off' 'network controllers' 'stored passwords (root only)' 'nearby wifi networks' 'add ip to a device' "add "$desired_eth_ip" to $eth_devc" 'delete all ips' 'enable NetworkManager' 'disable NetworkManager' 'connect to a new wifi network' 'help' )
fzf__title=''
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    all )
        nmcli connection show && accomplished ;;  ## OR find /sys/class/net -mindepth 1 -maxdepth 1 | sort
    'status + ip + mac address' )
        nmcli device
printf '%s\n' "------------------------------
status:
$(ip link show dev ${eth_devc})
$(ip link show dev ${wf_devc})

ip:
${eth_devc} ${eth_ip}
${wf_devc}      ${wf_ip}
${vpn_devc}     ${vpn_ip}
mac address:
${eth_devc} ${eth_mac}
${wf_devc}      ${wf_mac}
${vpn_devc}     ${vpn_mac}" && accomplished ;;
    'available wifi access points' )
        nmcli device wifi list && accomplished ;;
    "connect $eth_devc" )
        nmcli device connect "$eth_devc" && accomplished ;;        ## OR sudo ip link set "$eth_devc" up
    "disconnect $eth_devc" )
        nmcli device disconnect "$eth_devc" && accomplished ;;  ## OR sudo ip link set "$eth_devc" down
    "connect $wf_devc" )
        nmcli device connect "$wf_devc" && accomplished ;;          ## OR sudo ip link set "$wf_devc" up
    "disconnect $wf_devc" )
        nmcli device disconnect "$wf_devc" && accomplished ;;    ## OR sudo ip link set "$wf_devc" down
    'up ethernet/wifi connection' )
        prompt -c
        nmcli connection up "$connection" && accomplished ;;
    'down ethernet/wifi connection' )
        prompt -c
        nmcli connection down "$connection" && accomplished ;;
    'turn wifi on' )
        nmcli radio wifi on && accomplished ;;
    'turn wifi off' )
        nmcli radio wifi off && accomplished ;;
    'network controllers' )
        lspci -nnk | \grep -iA2 net && accomplished ;;
    'stored passwords (root only)' )
        \grep -iH '^psk=' /etc/NetworkManager/system-connections/* && accomplished ;;
    'nearby wifi networks' )
        nmcli device wifi list && accomplished ;;
    'add ip to a device' )
        prompt -i -d
        sudo ip address add "$ip" broadcast + dev "$device" && accomplished ;;
    "add $desired_eth_ip to $eth_devc" )
        add_desired_ip_to_ethernet && accomplished ;;
    'delete all ips' )
        prompt -d
        ip address flush dev "$device" && accomplished ;;
    'enable NetworkManager' )
        sudo systemctl enable NetworkManager && accomplished ;;
    'disable NetworkManager' )
        sudo systemctl disable NetworkManager && accomplished ;;
    'connect to a new wifi network' )
        prompt -s -p
        sudo nmcli device wifi connect "$ssid" password "$password" && accomplished ;;
    help )
        display_help ;;
esac
