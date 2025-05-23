#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/gb-network.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/gb-network.sh
##    https://davoudarsalani.ir

## also have a look at --,--> nmcli -c no --terse --fields DEVICE,CONNECTION,STATE dev status
##                       '--> nmcli -c no -t device

## ethernet
read -a eth_info < <(nmcli -c no device | \grep 'ethernet')                ## enp4s0f1 ethernet connected CAB
[ "$eth_info" ] && {
    eth_devc="${eth_info[0]}"                                              ## enp4s0f1
    eth_state="${eth_info[2]}"                                             ## connected
    ## ^^ OR: "$(ip -o link show | \grep "$eth_devc" | awk '{print $9}')"  ## UP
    eth_conn="${eth_info[-1]}"                                             ## CAB
    eth_ip="$(ip addr show "$eth_devc" | \grep 'inet ' | awk '{print $2}')"
    eth_mac="$(ip addr show "$eth_devc" | \grep 'link/ether' | awk '{print $2}')"  ## OR cat /sys/class/net/$eth_devc/address
}

## wifi
read -a wf_info < <(nmcli -c no device | \grep 'wifi[^-]')                 ## wlp3s0 wifi connected LTE
[ "$wf_info" ] && {
    wf_devc="${wf_info[0]}"                                                ## wlp3s0
    wf_state="${wf_info[2]}"                                               ## connected
    ## ^^ OR: "$(ip -o link show | \grep "$wf_devc" | awk '{print $9}')"   ## UP
    wf_conn="${wf_info[-1]}"                                               ## LTE
    wf_ip="$(ip addr show "$wf_devc" | \grep 'inet ' | awk '{print $2}')"
    wf_mac="$(ip addr show "$wf_devc" | \grep 'link/ether' | awk '{print $2}')"  ## OR cat /sys/class/net/$wf_devc/address
}

## vpn
read -a vpn_info < <(nmcli -c no device | \grep 'tun')                     ## tun0 tun connected RRR
[ "$vpn_info" ] && {
    vpn_devc="${vpn_info[0]}"                                              ## tun0
    vpn_state="${vpn_info[2]}"                                             ## connected
    ## ^^ OR: "$(ip -o link show | \grep "$vpn_devc" | awk '{print $9}')"  ## UP
    vpn_conn="${vpn_info[-1]}"                                             ## RRR
    vpn_ip="$(ip addr show "$vpn_devc" | \grep 'inet ' | awk '{print $2}')"
    vpn_mac="$(ip addr show "$vpn_devc" | \grep 'link/ether' | awk '{print $2}')"
}

desired_eth_ip='192.168.200.1/24'
