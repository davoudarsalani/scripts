#!/usr/bin/env bash

## By Davoud Arsalani
##    https://github.com/davoudarsalani/scripts
##    https://github.com/davoudarsalani/scripts/blob/master/mount-umount.sh
##    https://raw.githubusercontent.com/davoudarsalani/scripts/master/mount-umount.sh
##    https://davoudarsalani.ir

source ~/main/scripts/gb.sh

title="${0##*/}"

function display_help {
    source ~/main/scripts/.help.sh
    mount_umount_help
}

function prompt {
    for _ in "$@"; {
        case "$1" in
            -d )
                device="${device:-"$(get_input 'device (e.g. /dev/sdc)')"}" ;;
            -n )
                name="${name:-"$(get_input 'name (e.g. nnnn)')"}" ;;
        esac
        shift
    }
}

function get_opt {
    local options

    options="$(getopt --longoptions 'help,device:,name:' --options 'hd:n:' --alternative -- "$@")"
    eval set -- "$options"
    while true; do
        case "$1" in
            -h|--help )
                display_help ;;
            -d|--device )
                shift
                device="$1" ;;
            -n|--name )
                shift
                name="$1" ;;
            -- )
                break ;;
        esac
        shift
    done
}

get_opt "$@"

case "$1" in
    mount )  ## {{{
        get_mountable_umountable
        [ "$mountable" ] || {
            msgn 'nothing to mount'
            exit
        }

        rofi__title="$title"
        rofi__subtitle="$1"
        mountable_item="$(pipe_to_rofi "${mountable[@]}")" || exit 37

        current_datetime="$(get_datetime 'jymdhms')"
        name="$(printf '%s\n' "$mountable_item" | awk '{print $1}')"  ## sdb1

        function msg_mount_successful {
            msgn "<span color=\"${gruvbox_orange}\">/dev/${name}</span> mounted at <span color=\"${gruvbox_orange}\">${dest_mount_dir}</span>"
        }

        function msg_mount_failed {
            local exit_stts fail_reason msg_text

            exit_stts="$1"
            if (( exit_stts == 1 )); then
                fail_reason='incorrect invocation or permissions'
            elif (( exit_stts == 2 )); then
                fail_reason='system error (out of memory, cannot fork, no more loop devices)'
            elif (( exit_stts == 4 )); then
                fail_reason='internal mount bug'
            elif (( exit_stts == 8 )); then
                fail_reason='user interrupt'
            elif (( exit_stts == 16 )); then
                fail_reason='problems writing or locking /etc/mtab'
            elif (( exit_stts == 32 )); then
                fail_reason='mount failure'
            elif (( exit_stts == 64 )); then
                fail_reason='some mount succeeded'
            else
                fail_reason='unknown reason'
            fi

            msg_text="$(printf "mounting <span color=\"%s\">/dev/%s</span> at <span color=\"%s\">%s</span>\n(%s)\n" "$gruvbox_orange" "$name" "$gruvbox_orange" "$dest_mount_dir" "$fail_reason")"
            msgc 'ERROR' "$msg_text" ~/main/configs/themes/alert-w.png
        }

        dest_mount_dir=/tmp/"$current_datetime"-"$name"
        [ -d "$dest_mount_dir" ] || mkdir -p "$dest_mount_dir"

        if \grep -q '^sr' <<< "$name"; then
            sudo mount /dev/"$name" "$dest_mount_dir"

            exit_status="$?"
            if (( exit_status == 0 )); then
                msg_mount_successful
            else
                msg_mount_failed "$exit_status"
            fi
        else
            sudo mount -o umask=000 /dev/"$name" "$dest_mount_dir"

            exit_status="$?"
            if (( exit_status == 0 )); then
                msg_mount_successful
            else
                msg_mount_failed "$exit_status"
            fi
        fi

        exit ;;  ## NOTE do NOT comment
    ## }}}
    umount )  ## {{{
        get_mountable_umountable
        [ "$umountable" ] || {
            msgn 'nothing to umount'
            exit
        }

        rofi__title="$title"
        rofi__subtitle="$1"
        umountable_item="$(pipe_to_rofi "${umountable[@]}")" || exit 37

        name="$(printf '%s\n' "$umountable_item" | awk '{print $1}')"

        function msg_umount_successful {
            msgn "<span color=\"${gruvbox_orange}\">/dev/${name}</span> umounted"
        }

        function msg_umount_failed {
            msgc 'ERROR' "umounting <span color=\"${gruvbox_orange}\">/dev/${name}</span>" ~/main/configs/themes/alert-w.png
        }

        sudo umount /dev/"$name" && msg_umount_successful || msg_umount_failed

        exit ;;  ## NOTE do NOT comment
    ## }}}
esac

heading "$title"

main_items=( 'udisksctl mount -b' 'udisksctl unmount -b' 'lsblk' 'blkid and lsblk -f' 'lsusb' 'lsmod (modules loaded)' 'lspci' 'mounted drives' 'kernel drivers' 'remount root partition' 'mountable' 'umountable' 'format usb device' 'cat /proc/mounts' 'help' )
fzf__title=''
main_item="$(pipe_to_fzf "${main_items[@]}")" && wrap_fzf_choice "$main_item" || exit 37

case "$main_item" in
    'udisksctl mount -b' )
        prompt -d
        sudo udisksctl mount -b "$device" && lsblk_full && accomplished "$device mounted" ;;
    'udisksctl unmount -b' )
        prompt -d
        sudo udisksctl unmount -b "$device" && lsblk_full && accomplished "$device umounted" ;;
    lsblk )
        lsblk_full && accomplished ;;
    'blkid and lsblk -f' )
        sudo blkid
        printf '\n'
        \lsblk -f && accomplished ;;
    lsusb )
        lsusb && accomplished ;;
    'lsmod (modules loaded)' )
        lsmod && accomplished ;;
    lspci )
        lspci && accomplished ;;
    'mounted drives' )
        printf '%s\n' "$(mounted_drives)" && accomplished ;;
    'kernel drivers' )
        lspci -k && accomplished ;;
    'remount root partition' )
        remount_prompt="$(get_single_input 'You sure?')" && printf '\n'
        case "$remount_prompt" in
            y ) mount -o remount,rw / && accomplished ;;
        esac ;;
    mountable )
        [ "$mountable" ] && printf '%s\n' "$mountable" && accomplished ;;
    umountable )
        [ "$umountable" ] && printf '%s\n' "$umountable" && accomplished ;;
    'format usb device' )
        prompt -d
        sleep 0.5
        sudo wipefs --all "$device" && accomplished
        printf '+-+-+-+-+-+-+-+-+\n'
        read -p '> Creating a new partition table (choose dos). Press any key to continue ...'
        sleep 5
        sudo cfdisk "$device" && accomplished
        sleep 0.5

        fzf__title=''
        filesystem="$(pipe_to_fzf 'ext4' 'vfat')" && wrap_fzf_choice "$filesystem" || exit 37

        device+=1  ## /dev/sdc1
        case "$filesystem" in
            ext4 )
                sudo mkfs.ext4 "$device" && accomplished ;;
            vfat )
                prompt -n
                sudo mkfs.vfat -n "$name" "$device" && accomplished ;;
        esac ;;
    'cat /proc/mounts' )
        cat /proc/mounts && accomplished ;;
    help )
        display_help ;;
esac
