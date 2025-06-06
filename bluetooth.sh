#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/bluetooth.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/bluetooth.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh
source ~/main/scripts/gb-fir-blu-batt.sh

title="${0##*/}"

function update_bluetooth {
    ~/main/scripts/awesome-widgets.sh bluetooth
}

function get_mac {
    mac="$(get_input 'device mac address')"
}

heading "$title"

main_items=( 'status' 'blueman-manager' 'blueman-applet' 'turn on' 'turn off' 'controllers' 'controller information' 'select default controller' 'available/paired devices' 'device information' 'set pairable on/off' 'set discoverable on/off' 'pair with a device' 'trust/untrust a device' 'block/unblock a device' 'remove a device' 'connect/disconnect a device' 'configuration path' 'quit program' 'disable auto turning on' 'enable' 'disable' )
fzf__title=''
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    status )
        if [ "$bluetooth_status" == 'yes' ]; then
            printf 'Bluetooth is off\n' && update_bluetooth && accomplished
        else
            printf 'Bluetooth is on\n'  && update_bluetooth && accomplished
        fi ;;
    blueman-manager )
        blueman-manager 1>/dev/null &
        sleep 2
        update_bluetooth && accomplished ;;
    blueman-applet )
        blueman-applet 1>/dev/null 2>&1 &
        sleep 2
        update_bluetooth && accomplished ;;
    'turn on' )
        sudo rfkill unblock bluetooth && update_bluetooth && accomplished ;;
    'turn off' )
        sudo rfkill block bluetooth && update_bluetooth && accomplished ;;
    'available controllers' )
        bluetoothctl list && accomplished ;;
    'controller information' )
        bluetoothctl show "$def_ctrlr_mac" && accomplished ;;
    'select default controller' )
        mac="$(get_input 'mac address [!! or name]')"
        bluetoothctl select "$mac" && accomplished ;;
    'available/paired devices' )
        printf 'available:\t%s\n' "$(bluetoothctl devices)"
        printf 'paired:\t\t%s\n' "$(bluetoothctl paired-devices)" && accomplished ;;
    'device information' )
        get_mac
        bluetoothctl info "$mac" && accomplished ;;
    'set pairable on/off' )
    fzf__title=''
        set_pairable_item="$(pipe_to_fzf 'on' 'off')" && wrap_fzf_choice "$set_pairable_item" || exit 37

        case "$set_pairable_item" in
            on )
                bluetoothctl pairable on  && accomplished ;;
            off )
                bluetoothctl pairable off && accomplished ;;
        esac ;;
    'set discoverable on/off' )
    fzf__title=''
        set_discoverable_item="$(pipe_to_fzf 'on' 'off')" && wrap_fzf_choice "$set_discoverable_item" || exit 37

        case "$set_discoverable_item" in
            on )
                bluetoothctl discoverable on  && accomplished ;;
            off )
                bluetoothctl discoverable off && accomplished ;;
        esac ;;
    'pair with a device' )
        get_mac
        bluetoothctl pair "$mac" && accomplished ;;
    'trust/untrust a device' )
    fzf__title=''
        trust_item="$(pipe_to_fzf 'trust' 'nuntrust')" && wrap_fzf_choice "$trust_item" || exit 37

        case "$trust_item" in
            trust )
                get_mac
                bluetoothctl trust "$mac" && accomplished ;;
            untrust )
                get_mac
                bluetoothctl untrust "$mac" && accomplished ;;
        esac ;;
    'block/unblock a device' )
    fzf__title=''
        block_item="$(pipe_to_fzf 'block' 'unblock')" && wrap_fzf_choice "$block_item" || exit 37

        case "$block_item" in
            block )
                get_mac
                bluetoothctl block "$mac" && accomplished ;;
            unblock )
                get_mac
                bluetoothctl unblock "$mac" && accomplished ;;
        esac ;;
    'remove a device' )
        get_mac
        bluetoothctl remove "$mac" && accomplished ;;
    'connect/disconnect a device' )
    fzf__title=''
        connect_item="$(pipe_to_fzf 'connect' 'disconnect')" && wrap_fzf_choice "$connect_item" || exit 37

        case "$connect_item" in
            connect )
                get_mac
                bluetoothctl connect "$mac" && accomplished ;;
            disconnect )
                get_mac
                bluetoothctl connect "$mac" && accomplished ;;
        esac ;;
    'configuration path' )
        printf '/etc/bluetooth/main.conf\n' && accomplished ;;
    'quit program' )
        bluetoothctl quit && accomplished ;;
    'disable auto turning on' )
        gsettings set org.blueman.plugins.powermanager auto-power-on false && accomplished ;;
    enable )
        sudo systemctl enable bluetooth && accomplished ;;
    disable )
        sudo systemctl disable bluetooth && accomplished ;;
esac

## The default group the user must be a member of is lp. You can change it here: sudo "$editor" /etc/dbus-1/system.d/bluetooth.conf
## (https://wiki.archlinux.org/index.php/bluetooth)
