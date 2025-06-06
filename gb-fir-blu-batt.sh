#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/gb-fir-blu-batt.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/gb-fir-blu-batt.sh
##    https://davoudarsalani.ir

## firewall
firewall_status="$(sudo ufw status | \grep -i status | awk '{print $NF}')"

## bluetooth
bluetooth_status="$(rfkill list | \grep -iA 1 bluetooth | xargs | awk '{print $NF}')"
def_ctrlr_mac="$(bluetoothctl list | \grep -i default | awk '{print $2}')"
headset_mac="$(bluetoothctl devices | \grep 'Headset$' | awk '{print $2}')"

## battery
read -a batt_info < <(acpi)  ## Battery 0: Charging, 1%, charging at zero rate - will never fully charge.
[ "${batt_info[0]}" ] && {
    battery_status="${batt_info[2]//,/}"  ## Charging  ## OR cat /sys/class/power_supply/BAT1/status
    battery_level="${batt_info[3]//%,/}"  ## 28        ## OR cat /sys/class/power_supply/BAT1/capacity
    battery_rem="${batt_info[4]%:*}"      ## 12:47 OR charging
}
battery_temp="$(acpi -t | awk '{print $4}' | cut -d '.' -f 1)"
